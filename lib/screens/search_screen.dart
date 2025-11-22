import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/establishment_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/auth_provider.dart';
import '../models/establishment.dart';
import '../models/user.dart';
import '../widgets/dietary_filter_chip.dart';
import '../widgets/mapbox_map_widget.dart';
import '../utils/translations.dart';
import '../theme/app_theme.dart';
import 'establishment_detail_screen.dart';
import 'premium_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  static final GlobalKey<_SearchScreenState> searchKey = GlobalKey<_SearchScreenState>();

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

enum SortOption {
  distance,
  rating,
  name,
  openFirst,
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<MapboxMapWidgetState> _mapKey = GlobalKey<MapboxMapWidgetState>();
  SortOption _sortOption = SortOption.distance;
  bool _showOnlyOpen = false;
  bool _showOnlyNearby = false;
  double _maxDistance = 10.0; // km
  final List<String> _searchHistory = [];
  bool _hasSearchText = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _searchController.addListener(() {
      setState(() {
        _hasSearchText = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    // TODO: Carregar histórico de SharedPreferences
  }

  void _saveToHistory(String query) {
    if (query.trim().isEmpty) return;
    setState(() {
      _searchHistory.remove(query.trim());
      _searchHistory.insert(0, query.trim());
      if (_searchHistory.length > 5) {
        _searchHistory.removeLast();
      }
    });
    // TODO: Salvar em SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<EstablishmentProvider>(
      builder: (context, establishmentProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            // Filtros Dietéticos (Agora Horizontal e Compacto)
            _buildFilters(establishmentProvider),
            const SizedBox(height: 4),
            
            // Filtros Rápidos e Categoria
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildQuickFiltersRow(establishmentProvider),
                ],
              ),
            ),
            
            // Mapa Expandido
            Expanded(
              child: _buildMap(establishmentProvider),
            ),
          ],
        );
      },
    );
  }

  // Helper para agrupar os filtros rápidos numa linha só
  Widget _buildQuickFiltersRow(EstablishmentProvider provider) {
     // Combinação de atalhos de categoria e filtros rápidos para economizar espaço
     return Row(
       children: [
         // Abertos e Próximos
         _buildQuickFilterChip(
            icon: Icons.access_time,
            label: Translations.getText(context, 'openNow'),
            isSelected: _showOnlyOpen,
            onTap: () {
              setState(() => _showOnlyOpen = !_showOnlyOpen);
              _applyFilters(provider);
            },
         ),
         const SizedBox(width: 8),
         _buildQuickFilterChip(
            icon: Icons.near_me,
            label: Translations.getText(context, 'nearby'),
            isSelected: _showOnlyNearby,
            onTap: () {
              setState(() => _showOnlyNearby = !_showOnlyNearby);
              _applyFilters(provider);
            },
         ),
         const SizedBox(width: 8),
         // Botão de Ordenação (Simplificado)
         Container(
           decoration: BoxDecoration(
             color: Colors.grey.shade100,
             borderRadius: BorderRadius.circular(20),
             border: Border.all(color: Colors.grey.shade300),
           ),
           child: PopupMenuButton<SortOption>(
              icon: const Icon(Icons.sort, size: 20, color: Colors.black87),
              tooltip: 'Ordenar',
              onSelected: (SortOption option) {
                setState(() => _sortOption = option);
                _applyFilters(provider);
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: SortOption.distance, child: Text(Translations.getText(context, 'sortByDistance'))),
                PopupMenuItem(value: SortOption.rating, child: Text(Translations.getText(context, 'sortByRating'))),
              ],
           ),
         ),
       ],
     );
  }

  IconData _getDietaryIcon(DietaryFilter filter) {
    final name = filter.name.toLowerCase();
    if (name.contains('gluten')) return Icons.grain;
    if (name.contains('lactose') || name.contains('aplv')) return Icons.water_drop;
    if (name.contains('vegan')) return Icons.spa;
    if (name.contains('vegetarian')) return Icons.eco;
    if (name.contains('seafood') || name.contains('fish')) return Icons.set_meal;
    if (name.contains('sugar')) return Icons.cookie_outlined;
    if (name.contains('egg')) return Icons.egg_outlined; // Check if available, else Icons.circle_outlined
    return Icons.no_food;
  }

  Widget _buildFilters(EstablishmentProvider provider) {
    return SizedBox(
      height: 124,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: DietaryFilter.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final filter = DietaryFilter.values[index];
          final isSelected = provider.selectedFilters.contains(filter);
          
          return GestureDetector(
            onTap: () {
              provider.toggleFilter(filter);
            },
            child: SizedBox(
              width: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryGreen : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade200,
                        width: 2,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _getDietaryIcon(filter),
                        color: isSelected ? Colors.white : AppTheme.primaryGreen,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    filter.getLabel(context),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryGreen : Colors.grey.shade700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickFilterChip({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.green : Colors.grey),
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Colors.green.shade50,
      checkmarkColor: Colors.green,
      labelStyle: TextStyle(
        color: isSelected ? Colors.green.shade700 : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  String _getSortLabel(BuildContext context) {
    switch (_sortOption) {
      case SortOption.distance:
        return Translations.getText(context, 'sortByDistance');
      case SortOption.rating:
        return Translations.getText(context, 'sortByRating');
      case SortOption.name:
        return Translations.getText(context, 'sortByName');
      case SortOption.openFirst:
        return Translations.getText(context, 'sortByOpenFirst');
    }
  }

  void _applyFilters(EstablishmentProvider provider) {
    setState(() {});
  }

  List<Establishment> _getFilteredAndSortedEstablishments(EstablishmentProvider provider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final isPremium = user?.isPremiumActive ?? false;
    
    List<Establishment> establishments = provider.filteredEstablishments;
    
    establishments = establishments.where((establishment) {
      if (establishment.premiumUntil != null) {
        final now = DateTime.now();
        if (now.isBefore(establishment.premiumUntil!)) {
          return isPremium;
        }
      }
      return true;
    }).toList();
    
    if (_showOnlyOpen) {
      establishments = establishments.where((e) => e.isOpen).toList();
    }
    
    if (_showOnlyNearby && provider.userPosition != null) {
      establishments = establishments.where((e) => e.distance <= _maxDistance).toList();
    }
    
    switch (_sortOption) {
      case SortOption.distance:
        establishments.sort((a, b) => a.distance.compareTo(b.distance));
        break;
      case SortOption.rating:
        establishments.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.name:
        establishments.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.openFirst:
        establishments.sort((a, b) {
          if (a.isOpen && !b.isOpen) return -1;
          if (!a.isOpen && b.isOpen) return 1;
          return a.distance.compareTo(b.distance);
        });
        break;
    }
    
    return establishments;
  }

  void openAdvancedFiltersFromHeader() {
    final provider = Provider.of<EstablishmentProvider>(context, listen: false);
    _showAdvancedFilters(context, provider);
  }

  void _showAdvancedFilters(BuildContext context, EstablishmentProvider provider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    final isPremium = user?.isPremiumActive ?? false;

    if (!isPremium) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.star, color: Colors.amber),
              SizedBox(width: 8),
              Text('Filtros Avançados'),
            ],
          ),
          content: const Text(
            'Os filtros avançados são exclusivos para usuários Premium.\n\n'
            'Torne-se Premium para acessar filtros por:\n'
            '• Tipo de restrição alimentar\n'
            '• Tipo de estabelecimento\n'
            '• Nível de selo (popular, intermediário, técnico)\n'
            '• Distância máxima\n'
            '• Avaliação mínima',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PremiumScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
              ),
              child: const Text('Tornar-se Premium'),
            ),
          ],
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AdvancedFiltersSheet(
        maxDistance: _maxDistance,
        onDistanceChanged: (value) {
          setState(() {
            _maxDistance = value;
          });
          _applyFilters(provider);
        },
        provider: provider,
      ),
    );
  }

  Widget _buildMap(EstablishmentProvider provider) {
    return Consumer<EstablishmentProvider>(
      builder: (context, provider, _) {
        final establishments = _getFilteredAndSortedEstablishments(provider);
        return MapboxMapWidget(
          key: _mapKey,
          mapStateKey: _mapKey,
          establishments: establishments,
          onMarkerTap: (establishment) {
            // Quando clica no marcador, mostrar modal com animação de baixo para cima
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => EstablishmentDetailScreen(
                establishment: establishment,
              ),
            );
          },
        );
      },
    );
  }
}

// Widget para filtros avançados (Premium)
class _AdvancedFiltersSheet extends StatefulWidget {
  final double maxDistance;
  final ValueChanged<double> onDistanceChanged;
  final EstablishmentProvider provider;

  const _AdvancedFiltersSheet({
    required this.maxDistance,
    required this.onDistanceChanged,
    required this.provider,
  });

  @override
  State<_AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<_AdvancedFiltersSheet> {
  late double _maxDistance;
  double? _minRating;
  Set<DietaryFilter> _selectedDietaryFilters = {};
  Set<String> _selectedCategories = {};
  Set<DifficultyLevel> _selectedDifficultyLevels = {};

  @override
  void initState() {
    super.initState();
    _maxDistance = widget.maxDistance;
    _selectedDietaryFilters = Set.from(widget.provider.selectedFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber.shade700, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Filtros Avançados (Premium)',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distância máxima
                  _buildDistanceFilter(),
                  const SizedBox(height: 24),
                  // Avaliação mínima
                  _buildRatingFilter(),
                  const SizedBox(height: 24),
                  // Tipo de restrição alimentar
                  _buildDietaryFilters(),
                  const SizedBox(height: 24),
                  // Tipo de estabelecimento
                  _buildCategoryFilters(),
                  const SizedBox(height: 24),
                  // Nível de selo
                  _buildDifficultyLevelFilters(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Botões de ação
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _maxDistance = 50.0;
                      _minRating = null;
                      _selectedDietaryFilters.clear();
                      _selectedCategories.clear();
                      _selectedDifficultyLevels.clear();
                    });
                  },
                  child: const Text('Limpar Filtros'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    widget.provider.setSelectedFilters(_selectedDietaryFilters);
                    widget.provider.setAdvancedFilters(
                      minRating: _minRating,
                      categories: _selectedCategories,
                      difficultyLevels: _selectedDifficultyLevels,
                      maxDistance: _maxDistance,
                    );
                    widget.onDistanceChanged(_maxDistance);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Aplicar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDistanceFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distância Máxima: ${_maxDistance.toStringAsFixed(1)} km',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _maxDistance,
          min: 1.0,
          max: 50.0,
          divisions: 49,
          label: '${_maxDistance.toStringAsFixed(1)} km',
          onChanged: (value) {
            setState(() => _maxDistance = value);
          },
        ),
      ],
    );
  }

  Widget _buildRatingFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Avaliação Mínima: ${_minRating?.toStringAsFixed(1) ?? 'Qualquer'}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _minRating ?? 0.0,
          min: 0.0,
          max: 5.0,
          divisions: 10,
          label: _minRating?.toStringAsFixed(1) ?? 'Qualquer',
          onChanged: (value) {
            setState(() => _minRating = value > 0 ? value : null);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => setState(() => _minRating = null),
              child: const Text('Qualquer'),
            ),
            TextButton(
              onPressed: () => setState(() => _minRating = 4.0),
              child: const Text('4+ estrelas'),
            ),
            TextButton(
              onPressed: () => setState(() => _minRating = 4.5),
              child: const Text('4.5+ estrelas'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDietaryFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Restrições Alimentares',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DietaryFilter.values.map((filter) {
            final isSelected = _selectedDietaryFilters.contains(filter);
            return FilterChip(
              label: Text(filter.getLabel(context)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDietaryFilters.add(filter);
                  } else {
                    _selectedDietaryFilters.remove(filter);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCategoryFilters() {
    final categories = [
      'Restaurante',
      'Padaria',
      'Confeitaria',
      'Hotel',
      'Pousada',
      'Lanchonete',
      'Café',
      'Mercado',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Estabelecimento',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDifficultyLevelFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nível de Selo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: DifficultyLevel.values.map((level) {
            final isSelected = _selectedDifficultyLevels.contains(level);
            return FilterChip(
              label: Text(level.getLabel(context)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDifficultyLevels.add(level);
                  } else {
                    _selectedDifficultyLevels.remove(level);
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}

