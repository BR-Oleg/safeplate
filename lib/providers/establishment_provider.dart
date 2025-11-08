import 'package:flutter/material.dart';
import 'dart:async';
import '../models/establishment.dart';
import '../services/firebase_service.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class EstablishmentProvider with ChangeNotifier {
  List<Establishment> _establishments = [];
  List<Establishment> _filteredEstablishments = [];
  Set<DietaryFilter> _selectedFilters = {};
  String _searchQuery = '';
  Position? _userPosition;
  bool _isLoading = false;
  StreamSubscription<List<Establishment>>? _establishmentsSubscription;
  
  // Filtros avançados (Premium)
  double? _minRating;
  Set<String> _selectedCategories = {};
  Set<DifficultyLevel> _selectedDifficultyLevels = {};
  double _maxDistance = 50.0;

  List<Establishment> get establishments => _establishments;
  List<Establishment> get filteredEstablishments => _filteredEstablishments;
  Set<DietaryFilter> get selectedFilters => _selectedFilters;
  String get searchQuery => _searchQuery;
  Position? get userPosition => _userPosition;
  bool get isLoading => _isLoading;
  double? get minRating => _minRating;
  Set<String> get selectedCategories => _selectedCategories;
  Set<DifficultyLevel> get selectedDifficultyLevels => _selectedDifficultyLevels;
  double get maxDistance => _maxDistance;

  EstablishmentProvider() {
    _loadEstablishments();
    _listenToEstablishments();
  }

  void _listenToEstablishments() {
    // Escutar mudanças em tempo real do Firestore
    _establishmentsSubscription = FirebaseService.establishmentsStream().listen(
      (firestoreEstablishments) {
        debugPrint('🔄 Atualização em tempo real: ${firestoreEstablishments.length} estabelecimentos do Firestore');
        
        // Atualizar estabelecimentos do Firestore na lista local
        final existingIds = _establishments.map((e) => e.id).toSet();
        
        // Atualizar estabelecimentos existentes ou adicionar novos
        for (final firestoreEstablishment in firestoreEstablishments) {
          final existingIndex = _establishments.indexWhere((e) => e.id == firestoreEstablishment.id);
          if (existingIndex >= 0) {
            // Atualizar existente (mantém dados mockados se não vier do Firestore)
            // Mas atualiza campos importantes como difficultyLevel
            final existing = _establishments[existingIndex];
            _establishments[existingIndex] = Establishment(
              id: firestoreEstablishment.id,
              name: firestoreEstablishment.name,
              category: firestoreEstablishment.category,
              latitude: firestoreEstablishment.latitude,
              longitude: firestoreEstablishment.longitude,
              distance: existing.distance, // Manter distância calculada
              avatarUrl: firestoreEstablishment.avatarUrl,
              difficultyLevel: firestoreEstablishment.difficultyLevel, // Atualizar dificuldade
              dietaryOptions: firestoreEstablishment.dietaryOptions,
              isOpen: firestoreEstablishment.isOpen,
              ownerId: firestoreEstablishment.ownerId,
              address: firestoreEstablishment.address,
              openingTime: firestoreEstablishment.openingTime,
              closingTime: firestoreEstablishment.closingTime,
              openingDays: firestoreEstablishment.openingDays,
              premiumUntil: firestoreEstablishment.premiumUntil,
            );
            debugPrint('🔄 Estabelecimento atualizado: ${firestoreEstablishment.name} (${firestoreEstablishment.id}) - Dificuldade: ${firestoreEstablishment.difficultyLevel}');
          } else {
            // Adicionar novo estabelecimento do Firestore
            _establishments.add(firestoreEstablishment);
            debugPrint('➕ Estabelecimento adicionado: ${firestoreEstablishment.name} (${firestoreEstablishment.id})');
          }
        }
        
        // Remover estabelecimentos que não existem mais no Firestore (mas manter mockados)
        // Não vamos remover, apenas atualizar
        
        _applyFilters();
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Erro ao escutar estabelecimentos: $error');
      },
    );
  }

  @override
  void dispose() {
    _establishmentsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadEstablishments() async {
    List<Establishment> firestoreEstablishments = [];
    
    try {
      // Tentar carregar do Firestore primeiro
      firestoreEstablishments = await FirebaseService.getAllEstablishments();
      debugPrint('📦 Carregados ${firestoreEstablishments.length} estabelecimentos do Firestore');
      if (firestoreEstablishments.isNotEmpty) {
        debugPrint('   IDs do Firestore: ${firestoreEstablishments.map((e) => '${e.name}(${e.id})').join(", ")}');
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao carregar estabelecimentos do Firestore: $e');
    }
    
    // Sempre inicializar dados mockados
    _initializeData();
    final mockCount = _establishments.length;
    debugPrint('📦 Carregados ${mockCount} estabelecimentos mockados');
    final mockIds = _establishments.map((e) => e.id).toSet();
    debugPrint('   IDs mockados: ${mockIds.join(", ")}');
    
    // Se houver estabelecimentos do Firestore, adicionar aos mockados (evitando duplicatas)
    if (firestoreEstablishments.isNotEmpty) {
      final existingIds = _establishments.map((e) => e.id).toSet();
      final newEstablishments = firestoreEstablishments.where((e) => !existingIds.contains(e.id)).toList();
      if (newEstablishments.isNotEmpty) {
        _establishments.addAll(newEstablishments);
        debugPrint('✅ ${newEstablishments.length} estabelecimentos do Firestore adicionados aos ${mockCount} mockados');
        debugPrint('   Novos IDs adicionados: ${newEstablishments.map((e) => '${e.name}(${e.id})').join(", ")}');
      } else {
        debugPrint('ℹ️ Todos os estabelecimentos do Firestore já existem nos mockados (duplicatas evitadas)');
      }
      debugPrint('   Total final: ${_establishments.length} estabelecimentos');
    } else {
      debugPrint('ℹ️ Nenhum estabelecimento do Firestore para adicionar');
    }
    
    _applyFilters();
    notifyListeners();
  }

  void _initializeData() {
    // Dados mockados no entorno do Aquário de São Paulo, Brasil
    // Coordenadas do Aquário: -23.5275, -46.7070
    _establishments = [
      Establishment(
        id: '1',
        name: 'Green Leaf Bistro',
        category: 'Restaurante',
        latitude: -23.5250,
        longitude: -46.7050,
        distance: 0.3,
        avatarUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=150&h=150&fit=crop',
        difficultyLevel: DifficultyLevel.popular,
        dietaryOptions: [DietaryFilter.vegan, DietaryFilter.celiac],
        isOpen: true,
      ),
      Establishment(
        id: '2',
        name: 'Hotel Azul',
        category: 'Hotel',
        latitude: -23.5300,
        longitude: -46.7080,
        distance: 0.5,
        avatarUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=150&h=150&fit=crop',
        difficultyLevel: DifficultyLevel.intermediate,
        dietaryOptions: [DietaryFilter.halal, DietaryFilter.lactoseFree],
        isOpen: true,
      ),
      Establishment(
        id: '3',
        name: 'Nutri Bakes',
        category: 'Padaria',
        latitude: -23.5240,
        longitude: -46.7100,
        distance: 0.7,
        avatarUrl: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=150&h=150&fit=crop',
        difficultyLevel: DifficultyLevel.technical,
        dietaryOptions: [
          DietaryFilter.celiac,
          DietaryFilter.vegan,
          DietaryFilter.nutFree
        ],
        isOpen: false,
      ),
      // Adicionar mais estabelecimentos para os filtros funcionarem
      Establishment(
        id: '4',
        name: 'Veggie Corner',
        category: 'Restaurante',
        latitude: -23.5280,
        longitude: -46.7040,
        distance: 0.4,
        avatarUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=150&h=150&fit=crop',
        difficultyLevel: DifficultyLevel.popular,
        dietaryOptions: [DietaryFilter.vegan, DietaryFilter.halal],
        isOpen: true,
      ),
      Establishment(
        id: '5',
        name: 'Celiac Bakery',
        category: 'Padaria',
        latitude: -23.5260,
        longitude: -46.7090,
        distance: 0.6,
        avatarUrl: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=150&h=150&fit=crop',
        difficultyLevel: DifficultyLevel.intermediate,
        dietaryOptions: [DietaryFilter.celiac, DietaryFilter.lactoseFree],
        isOpen: true,
      ),
      Establishment(
        id: '6',
        name: 'Nut-Free Cafe',
        category: 'Café',
        latitude: -23.5230,
        longitude: -46.7060,
        distance: 0.8,
        avatarUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=150&h=150&fit=crop',
        difficultyLevel: DifficultyLevel.popular,
        dietaryOptions: [DietaryFilter.nutFree, DietaryFilter.lactoseFree],
        isOpen: true,
      ),
      Establishment(
        id: '7',
        name: 'Halal Restaurant',
        category: 'Restaurante',
        latitude: -23.5290,
        longitude: -46.7055,
        distance: 0.5,
        avatarUrl: 'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?w=150&h=150&fit=crop',
        difficultyLevel: DifficultyLevel.intermediate,
        dietaryOptions: [DietaryFilter.halal],
        isOpen: true,
      ),
      Establishment(
        id: '8',
        name: 'Pure Vegan',
        category: 'Restaurante',
        latitude: -23.5220,
        longitude: -46.7085,
        distance: 0.9,
        avatarUrl: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?w=150&h=150&fit=crop',
        difficultyLevel: DifficultyLevel.technical,
        dietaryOptions: [DietaryFilter.vegan, DietaryFilter.celiac, DietaryFilter.nutFree],
        isOpen: false,
      ),
    ];
    _filteredEstablishments = List.from(_establishments);
    _requestLocation();
  }

  Future<void> _requestLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Serviço de localização desabilitado');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Permissão de localização negada');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Permissão de localização negada permanentemente');
        return;
      }

      _userPosition = await Geolocator.getCurrentPosition();
      _calculateDistances();
    } catch (e) {
      debugPrint('Erro ao obter localização: $e');
    }
  }

  void _calculateDistances() {
    if (_userPosition == null) return;

    final updatedEstablishments = _establishments.map((establishment) {
      final distance = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        establishment.latitude,
        establishment.longitude,
      );
      return Establishment(
        id: establishment.id,
        name: establishment.name,
        category: establishment.category,
        latitude: establishment.latitude,
        longitude: establishment.longitude,
        distance: distance / 1000, // Converter para km
        avatarUrl: establishment.avatarUrl,
        difficultyLevel: establishment.difficultyLevel,
        dietaryOptions: establishment.dietaryOptions,
        isOpen: establishment.isOpen,
        ownerId: establishment.ownerId,
        address: establishment.address,
        openingTime: establishment.openingTime,
        closingTime: establishment.closingTime,
        openingDays: establishment.openingDays,
      );
    }).toList();

    _establishments = updatedEstablishments;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void toggleFilter(DietaryFilter filter) {
    if (_selectedFilters.contains(filter)) {
      _selectedFilters.remove(filter);
    } else {
      _selectedFilters.add(filter);
    }
    _applyFilters();
  }

  void clearFilters() {
    _selectedFilters.clear();
    _applyFilters();
  }

  /// Adiciona um estabelecimento à lista local (sem recarregar do Firestore)
  void addEstablishment(Establishment establishment) {
    // Verificar se já existe (por ID)
    final existingIndex = _establishments.indexWhere((e) => e.id == establishment.id);
    if (existingIndex >= 0) {
      // Atualizar existente
      _establishments[existingIndex] = establishment;
      debugPrint('🔄 Estabelecimento atualizado: ${establishment.name} (${establishment.id})');
    } else {
      // Adicionar novo
      _establishments.add(establishment);
      debugPrint('➕ Estabelecimento adicionado: ${establishment.name} (${establishment.id})');
    }
    _applyFilters();
    notifyListeners();
  }

  Future<void> reloadEstablishments() async {
    await _loadEstablishments();
  }

  void setSelectedFilters(Set<DietaryFilter> filters) {
    _selectedFilters = filters;
    _applyFilters();
  }

  void setAdvancedFilters({
    double? minRating,
    Set<String>? categories,
    Set<DifficultyLevel>? difficultyLevels,
    double? maxDistance,
  }) {
    if (minRating != null) _minRating = minRating;
    if (categories != null) _selectedCategories = categories;
    if (difficultyLevels != null) _selectedDifficultyLevels = difficultyLevels;
    if (maxDistance != null) _maxDistance = maxDistance;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredEstablishments = _establishments.where((establishment) {
      // Filtro de busca
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = establishment.name.toLowerCase().contains(query);
        final matchesCategory =
            establishment.category.toLowerCase().contains(query);
        if (!matchesName && !matchesCategory) {
          return false;
        }
      }

      // Filtro de opções dietéticas
      // O estabelecimento deve ter TODOS os filtros selecionados (AND)
      if (_selectedFilters.isNotEmpty) {
        // Verificar se o estabelecimento tem TODOS os filtros selecionados
        final hasAllFilters = _selectedFilters.every(
          (filter) => establishment.dietaryOptions.contains(filter),
        );
        if (!hasAllFilters) {
          debugPrint('❌ ${establishment.name} não tem todos os filtros: ${_selectedFilters.map((f) => f.toString()).join(", ")}. Tem apenas: ${establishment.dietaryOptions.map((f) => f.toString()).join(", ")}');
          return false;
        }
        debugPrint('✅ ${establishment.name} tem todos os filtros: ${_selectedFilters.map((f) => f.toString()).join(", ")}');
      }

      // Filtros avançados (Premium)
      // Filtro por categoria
      if (_selectedCategories.isNotEmpty) {
        if (!_selectedCategories.contains(establishment.category)) {
          return false;
        }
      }

      // Filtro por nível de dificuldade
      if (_selectedDifficultyLevels.isNotEmpty) {
        if (!_selectedDifficultyLevels.contains(establishment.difficultyLevel)) {
          return false;
        }
      }

      // Filtro por distância máxima
      if (establishment.distance > _maxDistance) {
        return false;
      }

      // Filtro por avaliação mínima (será implementado quando tiver avaliações)
      // TODO: Implementar quando tiver sistema de avaliações

      return true;
    }).toList();

    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

