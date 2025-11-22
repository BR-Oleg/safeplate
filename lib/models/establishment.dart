import 'package:flutter/material.dart';
import '../utils/translations.dart';

class Establishment {
  final String id;
  final String name;
  final String category;
  final double latitude;
  final double longitude;
  final double distance; // em km
  final String avatarUrl;
  final DifficultyLevel difficultyLevel;
  final List<DietaryFilter> dietaryOptions;
  bool get isOpen {
    // Se tem horário e dias de funcionamento, calcular dinamicamente
    if (openingTime != null && closingTime != null && openingDays != null && openingDays!.isNotEmpty) {
      return calculateIsOpen(openingTime!, closingTime!, openingDays!);
    }
    // Se tem apenas horário, calcular baseado no horário
    if (openingTime != null && closingTime != null) {
      return calculateIsOpen(openingTime!, closingTime!);
    }
    // Senão, usar o valor salvo
    return _isOpen;
  }
  
  final bool _isOpen; // Valor salvo (usado como fallback)
  final String? ownerId; // ID do dono da empresa (se for empresa)
  final String? address; // Endereço completo
  final String? openingTime; // Horário de abertura (HH:mm)
  final String? closingTime; // Horário de fechamento (HH:mm)
  final List<int>? openingDays; // Dias da semana que está aberto (0=domingo, 1=segunda, ..., 6=sábado)
  final DateTime? premiumUntil; // Data até quando é exclusivo para Premium (null = disponível para todos)
  final TechnicalCertificationStatus certificationStatus;
  final DateTime? lastInspectionDate;
  final String? lastInspectionStatus;
  final bool isBoosted;
  final DateTime? boostExpiresAt;

  Establishment({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.distance,
    required this.avatarUrl,
    required this.difficultyLevel,
    required this.dietaryOptions,
    required bool isOpen,
    this.ownerId,
    this.address,
    this.openingTime,
    this.closingTime,
    this.openingDays,
    this.premiumUntil,
    this.certificationStatus = TechnicalCertificationStatus.none,
    this.lastInspectionDate,
    this.lastInspectionStatus,
    this.isBoosted = false,
    this.boostExpiresAt,
  }) : _isOpen = isOpen;

  factory Establishment.fromJson(Map<String, dynamic> json) {
    // Calcular isOpen baseado no horário e dias se disponível
    bool calculatedIsOpen = json['isOpen'] as bool? ?? true;
    final openingDays = json['openingDays'] != null 
        ? (json['openingDays'] as List<dynamic>).map((e) => e as int).toList()
        : null;
    if (json['openingTime'] != null && json['closingTime'] != null) {
      calculatedIsOpen = calculateIsOpen(
        json['openingTime'] as String,
        json['closingTime'] as String,
        openingDays,
      );
    }
    final lastInspectionDate = json['lastInspectionDate'] != null
        ? DateTime.parse(json['lastInspectionDate'] as String)
        : null;
    final lastInspectionStatus = json['lastInspectionStatus'] as String?;
    final isBoosted = json['isBoosted'] as bool? ?? false;
    final boostExpiresAt = json['boostExpiresAt'] != null
        ? DateTime.parse(json['boostExpiresAt'] as String)
        : null;
    
    return Establishment(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      avatarUrl: json['avatarUrl'] as String? ?? '',
      difficultyLevel: DifficultyLevel.fromString(json['difficultyLevel'] as String? ?? 'popular'),
      dietaryOptions: (json['dietaryOptions'] as List<dynamic>?)
              ?.map((e) => DietaryFilter.fromString(e as String))
              .toList() ??
          [],
      isOpen: calculatedIsOpen,
      ownerId: json['ownerId'] as String?,
      address: json['address'] as String?,
      openingTime: json['openingTime'] as String?,
      closingTime: json['closingTime'] as String?,
      openingDays: openingDays,
      premiumUntil: json['premiumUntil'] != null
          ? DateTime.parse(json['premiumUntil'] as String)
          : null,
      certificationStatus: TechnicalCertificationStatus.fromString(
        json['certificationStatus'] as String? ?? 'none',
      ),
      lastInspectionDate: lastInspectionDate,
      lastInspectionStatus: lastInspectionStatus,
      isBoosted: isBoosted,
      boostExpiresAt: boostExpiresAt,
    );
  }
  
  /// Calcula se o estabelecimento está aberto baseado no horário atual
  static bool calculateIsOpen(String openingTime, String closingTime, [List<int>? openingDays]) {
    try {
      final now = DateTime.now();
      final currentTime = TimeOfDay(hour: now.hour, minute: now.minute);
      // DateTime.weekday: 1=segunda, 2=terça, ..., 7=domingo
      // Converter para: 0=domingo, 1=segunda, ..., 6=sábado
      final currentDayOfWeek = now.weekday == 7 ? 0 : now.weekday;
      
      // Verificar se está aberto no dia da semana
      if (openingDays != null && openingDays.isNotEmpty) {
        if (!openingDays.contains(currentDayOfWeek)) {
          return false; // Não está aberto neste dia da semana
        }
      }
      
      final opening = _parseTime(openingTime);
      final closing = _parseTime(closingTime);
      
      if (opening == null || closing == null) return true;
      
      // Se o horário de fechamento é menor que o de abertura, significa que fecha no dia seguinte
      if (closing.hour < opening.hour || 
          (closing.hour == opening.hour && closing.minute < opening.minute)) {
        // Está aberto se está depois da abertura OU antes do fechamento
        return _isAfter(currentTime, opening) || _isBefore(currentTime, closing);
      } else {
        // Está aberto se está entre abertura e fechamento
        return _isAfter(currentTime, opening) && _isBefore(currentTime, closing);
      }
    } catch (e) {
      return true; // Em caso de erro, assume que está aberto
    }
  }
  
  static TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }
  
  static bool _isAfter(TimeOfDay time, TimeOfDay other) {
    if (time.hour > other.hour) return true;
    if (time.hour < other.hour) return false;
    return time.minute >= other.minute;
  }
  
  static bool _isBefore(TimeOfDay time, TimeOfDay other) {
    if (time.hour < other.hour) return true;
    if (time.hour > other.hour) return false;
    return time.minute <= other.minute;
  }

  Map<String, dynamic> toJson() {
    // isOpen já é calculado dinamicamente pelo getter
    return {
      'id': id,
      'name': name,
      'category': category,
      'latitude': latitude,
      'longitude': longitude,
      'distance': distance,
      'avatarUrl': avatarUrl,
      'difficultyLevel': difficultyLevel.toString(),
      'dietaryOptions': dietaryOptions.map((e) => e.toString()).toList(),
      'isOpen': isOpen, // Já calculado dinamicamente pelo getter
      'ownerId': ownerId,
      'address': address,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'openingDays': openingDays,
      'premiumUntil': premiumUntil?.toIso8601String(),
      'certificationStatus': certificationStatus.toString().split('.').last,
      'lastInspectionDate': lastInspectionDate?.toIso8601String(),
      'lastInspectionStatus': lastInspectionStatus,
      'isBoosted': isBoosted,
      'boostExpiresAt': boostExpiresAt?.toIso8601String(),
    };
  }
}

enum DifficultyLevel {
  popular,
  intermediate,
  technical;

  String getLabel(BuildContext? context) {
    if (context == null) {
      // Fallback sem contexto
      switch (this) {
        case DifficultyLevel.popular:
          return 'Popular';
        case DifficultyLevel.intermediate:
          return 'Intermediário';
        case DifficultyLevel.technical:
          return 'Técnico';
      }
    }
    
    final locale = Localizations.localeOf(context);
    final isPt = locale.languageCode == 'pt';
    final isEs = locale.languageCode == 'es';
    
    switch (this) {
      case DifficultyLevel.popular:
        return isPt ? 'Popular' : isEs ? 'Popular' : 'Popular';
      case DifficultyLevel.intermediate:
        return isPt ? 'Intermediário' : isEs ? 'Intermedio' : 'Intermediate';
      case DifficultyLevel.technical:
        return isPt ? 'Técnico' : isEs ? 'Técnico' : 'Technical';
    }
  }

  @Deprecated('Use getLabel(context) instead')
  String get label {
    switch (this) {
      case DifficultyLevel.popular:
        return 'Popular';
      case DifficultyLevel.intermediate:
        return 'Intermediário';
      case DifficultyLevel.technical:
        return 'Técnico';
    }
  }

  Color get color {
    switch (this) {
      case DifficultyLevel.popular:
        return Colors.green;
      case DifficultyLevel.intermediate:
        return Colors.blue;
      case DifficultyLevel.technical:
        return Colors.orange;
    }
  }

  static DifficultyLevel fromString(String value) {
    return DifficultyLevel.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => DifficultyLevel.popular,
    );
  }
}

enum TechnicalCertificationStatus {
  none,
  pending,
  scheduled,
  certified;

  String getLabel(BuildContext? context) {
    if (context == null) {
      switch (this) {
        case TechnicalCertificationStatus.none:
          return 'Sem certificação';
        case TechnicalCertificationStatus.pending:
          return 'Solicitada (pendente)';
        case TechnicalCertificationStatus.scheduled:
          return 'Agendada';
        case TechnicalCertificationStatus.certified:
          return 'Certificado';
      }
    }

    switch (this) {
      case TechnicalCertificationStatus.none:
        return Translations.getText(context!, 'certificationStatusNone');
      case TechnicalCertificationStatus.pending:
        return Translations.getText(context!, 'certificationStatusPending');
      case TechnicalCertificationStatus.scheduled:
        return Translations.getText(context!, 'certificationStatusScheduled');
      case TechnicalCertificationStatus.certified:
        return Translations.getText(context!, 'certificationStatusCertified');
    }
  }

  static TechnicalCertificationStatus fromString(String value) {
    return TechnicalCertificationStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => TechnicalCertificationStatus.none,
    );
  }
}

/// Helper para traduzir categorias de estabelecimentos
class CategoryTranslator {
  static String translate(BuildContext? context, String category) {
    if (context == null) {
      return category; // Fallback sem contexto
    }
    
    final categoryLower = category.toLowerCase().trim();
    
    // Mapear todas as variações possíveis de categorias
    // Restaurant / Restaurante
    if (categoryLower == 'restaurant' || 
        categoryLower == 'restaurante' || 
        categoryLower.contains('restaurant') || 
        categoryLower.contains('restaurante')) {
      return Translations.getText(context, 'categoryRestaurant');
    } 
    // Bakery / Padaria / Panadería
    else if (categoryLower == 'bakery' || 
             categoryLower == 'padaria' || 
             categoryLower == 'panadería' ||
             categoryLower == 'panaderia' ||
             categoryLower == 'confeitaria' ||
             categoryLower.contains('bakery') || 
             categoryLower.contains('padaria') || 
             categoryLower.contains('panadería') ||
             categoryLower.contains('panaderia') ||
             categoryLower.contains('confeitaria')) {
      return Translations.getText(context, 'categoryBakery');
    } 
    // Hotel / Pousada
    else if (categoryLower == 'hotel' || 
             categoryLower == 'pousada' || 
             categoryLower.contains('hotel') || 
             categoryLower.contains('pousada')) {
      return Translations.getText(context, 'categoryHotel');
    } 
    // Cafe / Café
    else if (categoryLower == 'cafe' || 
             categoryLower == 'café' || 
             categoryLower == 'cafe' ||
             categoryLower.contains('cafe') || 
             categoryLower.contains('café')) {
      return Translations.getText(context, 'categoryCafe');
    } 
    // Market / Mercado
    else if (categoryLower == 'market' || 
             categoryLower == 'mercado' || 
             categoryLower.contains('market') || 
             categoryLower.contains('mercado')) {
      return Translations.getText(context, 'categoryMarket');
    } 
    // Outro / Other
    else {
      // Se não encontrar correspondência, retornar a categoria original
      // ou tentar traduzir se já estiver em um idioma conhecido
      return category;
    }
  }
}

enum DietaryFilter {
  celiac,
  lactoseFree,
  aplv,
  eggFree,
  nutFree,
  oilseedFree,
  soyFree,
  sugarFree,
  diabetic,
  vegan,
  vegetarian,
  halal;

  String getLabel(BuildContext? context) {
    if (context == null) {
      // Fallback sem contexto
      switch (this) {
        case DietaryFilter.celiac:
          return 'Celíaco';
        case DietaryFilter.lactoseFree:
          return 'Sem Lactose';
        case DietaryFilter.aplv:
          return 'APLV';
        case DietaryFilter.eggFree:
          return 'Sem Ovo';
        case DietaryFilter.nutFree:
          return 'Sem Amendoim';
        case DietaryFilter.oilseedFree:
          return 'Sem Oleaginosas';
        case DietaryFilter.soyFree:
          return 'Sem Soja';
        case DietaryFilter.sugarFree:
          return 'Sem Açúcar';
        case DietaryFilter.diabetic:
          return 'Adequado para diabéticos';
        case DietaryFilter.vegan:
          return 'Vegano';
        case DietaryFilter.vegetarian:
          return 'Vegetariano';
        case DietaryFilter.halal:
          return 'Halal';
      }
    }
    
    // Usar o sistema de traduções
    switch (this) {
      case DietaryFilter.celiac:
        return Translations.getText(context, 'dietaryCeliac');
      case DietaryFilter.lactoseFree:
        return Translations.getText(context, 'dietaryLactoseFree');
      case DietaryFilter.aplv:
        return Translations.getText(context, 'dietaryAPLV');
      case DietaryFilter.eggFree:
        return Translations.getText(context, 'dietaryEggFree');
      case DietaryFilter.nutFree:
        return Translations.getText(context, 'dietaryNutFree');
      case DietaryFilter.oilseedFree:
        return Translations.getText(context, 'dietaryOilseedFree');
      case DietaryFilter.soyFree:
        return Translations.getText(context, 'dietarySoyFree');
      case DietaryFilter.sugarFree:
        return Translations.getText(context, 'dietarySugarFree');
      case DietaryFilter.diabetic:
        return Translations.getText(context, 'dietaryDiabetic');
      case DietaryFilter.vegan:
        return Translations.getText(context, 'dietaryVegan');
      case DietaryFilter.vegetarian:
        return Translations.getText(context, 'dietaryVegetarian');
      case DietaryFilter.halal:
        return Translations.getText(context, 'dietaryHalal');
    }
  }
  
  @Deprecated('Use getLabel(context) instead')
  String get label {
    switch (this) {
      case DietaryFilter.celiac:
        return 'Celíaco';
      case DietaryFilter.lactoseFree:
        return 'Sem Lactose';
      case DietaryFilter.aplv:
        return 'APLV';
      case DietaryFilter.eggFree:
        return 'Sem Ovo';
      case DietaryFilter.nutFree:
        return 'Sem Amendoim';
      case DietaryFilter.oilseedFree:
        return 'Sem Oleaginosas';
      case DietaryFilter.soyFree:
        return 'Sem Soja';
      case DietaryFilter.sugarFree:
        return 'Sem Açúcar';
      case DietaryFilter.diabetic:
        return 'Adequado para diabéticos';
      case DietaryFilter.vegan:
        return 'Vegano';
      case DietaryFilter.vegetarian:
        return 'Vegetariano';
      case DietaryFilter.halal:
        return 'Halal';
    }
  }

  static DietaryFilter fromString(String value) {
    return DietaryFilter.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => DietaryFilter.celiac,
    );
  }
}
