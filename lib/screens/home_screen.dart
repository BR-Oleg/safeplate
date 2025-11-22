import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/establishment_provider.dart';
import '../providers/locale_provider.dart';
import '../models/establishment.dart';
import '../models/user.dart';
import '../utils/translations.dart';
import '../theme/app_theme.dart';
import '../services/firebase_service.dart';
import 'search_screen.dart';
import 'login_screen.dart';
import 'favorites_screen.dart';
import 'business_dashboard_screen.dart';
import 'user_profile_screen.dart';
import 'leaderboard_screen.dart';
import 'notifications_screen.dart';

const String kOfficialWhatsAppGroupUrl =
    'https://chat.whatsapp.com/GRUPO_OFICIAL_PRATO_SEGURO';
const String kNationalFairUrl =
    'https://pratoseguro.com/feira'; // TODO: Atualizar para a URL oficial da feira

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum _SeasonalVariant { none, christmas, carnival }

class _HomeScreenState extends State<HomeScreen> {
  int get _initialIndex {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated ? 0 : 1; // Busca se logado, Login se não
  }

  Widget _buildFairBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade50,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 12,
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.event,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Translations.getText(context, 'homeFairTitle'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Translations.getText(context, 'homeFairDescription'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => _openNationalFair(context),
            child: Text(
              Translations.getText(context, 'homeFairButton'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopReviewersBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.purple.shade50,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 12,
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.purple.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Translations.getText(context, 'homeTopReviewersTitle'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Translations.getText(context, 'homeTopReviewersDescription'),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const LeaderboardScreen(),
                ),
              );
            },
            child: Text(
              Translations.getText(context, 'homeTopReviewersButton'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  int _selectedIndex = 0;
  final TextEditingController _homeSearchController = TextEditingController();
  final FocusNode _homeSearchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _selectedIndex = _initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybeShowHomeModals();
    });
  }

  @override
  void dispose() {
    _homeSearchController.dispose();
    _homeSearchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openWhatsAppGroup(BuildContext context) async {
    final uri = Uri.parse(kOfficialWhatsAppGroupUrl);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Translations.getText(context, 'homeWhatsAppGroupOpenError'),
          ),
        ),
      );
    }
  }

  Future<void> _maybeShowHomeModals() async {
    if (!mounted) return;
    final prefs = await SharedPreferences.getInstance();
    final appConfig = await FirebaseService.getGlobalAppConfig();
    await _maybeShowFairModal(prefs, appConfig);
    await _maybeShowWhatsAppModal(prefs, appConfig);
  }

  Future<void> _showHomePromoDialog({
    required String titleKey,
    required String descriptionKey,
    required String primaryLabelKey,
    required VoidCallback onPrimaryPressed,
    String? titleOverride,
    String? descriptionOverride,
    String? primaryLabelOverride,
    String? imageUrl,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final titleText = (titleOverride != null && titleOverride.trim().isNotEmpty)
            ? titleOverride
            : Translations.getText(dialogContext, titleKey);
        final descriptionText =
            (descriptionOverride != null && descriptionOverride.trim().isNotEmpty)
                ? descriptionOverride
                : Translations.getText(dialogContext, descriptionKey);
        final primaryLabelText =
            (primaryLabelOverride != null && primaryLabelOverride.trim().isNotEmpty)
                ? primaryLabelOverride
                : Translations.getText(dialogContext, primaryLabelKey);

        final descriptionWidget = Text(
          descriptionText,
        );

        Widget? imageWidget;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          imageWidget = ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          );
        }

        return AlertDialog(
          title: Text(titleText),
          content: imageWidget == null
              ? descriptionWidget
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    imageWidget,
                    const SizedBox(height: 12),
                    descriptionWidget,
                  ],
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(Translations.getText(dialogContext, 'close')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onPrimaryPressed();
              },
              child: Text(primaryLabelText),
            ),
          ],
        );
      },
    );
  }

  Future<void> _maybeShowFairModal(SharedPreferences prefs, Map<String, dynamic>? appConfig) async {
    const key = 'promo_fair_modal_v2';
    if (prefs.getBool(key) == true || !mounted) return;
    if (appConfig != null && appConfig['homeFairEnabled'] == false) {
      return;
    }
    final imageUrl = appConfig != null && appConfig['homeFairImageUrl'] is String
        ? (appConfig['homeFairImageUrl'] as String).trim()
        : null;

    String? titleOverride;
    final rawTitle = appConfig != null ? appConfig['homeFairTitleText'] : null;
    if (rawTitle is String && rawTitle.trim().isNotEmpty) {
      titleOverride = rawTitle.trim();
    }

    String? descriptionOverride;
    final rawDescription = appConfig != null ? appConfig['homeFairDescriptionText'] : null;
    if (rawDescription is String && rawDescription.trim().isNotEmpty) {
      descriptionOverride = rawDescription.trim();
    }

    String? primaryLabelOverride;
    final rawPrimaryLabel = appConfig != null ? appConfig['homeFairPrimaryLabelText'] : null;
    if (rawPrimaryLabel is String && rawPrimaryLabel.trim().isNotEmpty) {
      primaryLabelOverride = rawPrimaryLabel.trim();
    }

    String? primaryUrl;
    final rawPrimaryUrl = appConfig != null ? appConfig['homeFairPrimaryUrl'] : null;
    if (rawPrimaryUrl is String && rawPrimaryUrl.trim().isNotEmpty) {
      primaryUrl = rawPrimaryUrl.trim();
    }

    await _showHomePromoDialog(
      titleKey: 'homeFairTitle',
      descriptionKey: 'homeFairDescription',
      primaryLabelKey: 'homeFairButton',
      titleOverride: titleOverride,
      descriptionOverride: descriptionOverride,
      primaryLabelOverride: primaryLabelOverride,
      onPrimaryPressed: () async {
        if (primaryUrl != null) {
          final uri = Uri.parse(primaryUrl);
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  Translations.getText(context, 'errorOpeningNavigation'),
                ),
              ),
            );
          }
        } else {
          await _openNationalFair(context);
        }
      },
      imageUrl: imageUrl,
    );
    await prefs.setBool(key, true);
  }

  Future<void> _maybeShowWhatsAppModal(SharedPreferences prefs, Map<String, dynamic>? appConfig) async {
    const key = 'promo_whatsapp_modal_v2';
    if (prefs.getBool(key) == true || !mounted) return;
    if (appConfig != null && appConfig['homeWhatsAppEnabled'] == false) {
      return;
    }
    final imageUrl = appConfig != null && appConfig['homeWhatsAppImageUrl'] is String
        ? (appConfig['homeWhatsAppImageUrl'] as String).trim()
        : null;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final descriptionText = Translations.getText(dialogContext, 'homeWhatsAppGroupDescription');
        final primaryLabel = Translations.getText(dialogContext, 'homeWhatsAppGroupButton');

        Widget? imageWidget;
        if (imageUrl != null && imageUrl.isNotEmpty) {
          imageWidget = ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
            ),
          );
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble,
                  color: Color(0xFF25D366),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  Translations.getText(dialogContext, 'homeWhatsAppGroupTitle'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (imageWidget != null) ...[
                imageWidget,
                const SizedBox(height: 12),
              ],
              Text(
                descriptionText,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 18,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Novidades do app, lançamentos e oportunidades para estabelecimentos.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 18,
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Comunidade moderada, sem spam e com foco em segurança alimentar.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(Translations.getText(dialogContext, 'close')),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _openWhatsAppGroup(context);
              },
              icon: const Icon(Icons.chat_bubble, size: 18),
              label: Text(
                primaryLabel,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
    await prefs.setBool(key, true);
  }

  Future<void> _maybeShowTopReviewersModal(SharedPreferences prefs, Map<String, dynamic>? appConfig) async {
    const key = 'promo_top_reviewers_modal_v1';
    if (prefs.getBool(key) == true || !mounted) return;
    if (appConfig != null && appConfig['homeTopReviewersEnabled'] == false) {
      return;
    }
    final imageUrl = appConfig != null && appConfig['homeTopReviewersImageUrl'] is String
        ? appConfig['homeTopReviewersImageUrl'] as String
        : null;
    await _showHomePromoDialog(
      titleKey: 'homeTopReviewersTitle',
      descriptionKey: 'homeTopReviewersDescription',
      primaryLabelKey: 'homeTopReviewersButton',
      onPrimaryPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const LeaderboardScreen(),
          ),
        );
      },
      imageUrl: imageUrl,
    );
    await prefs.setBool(key, true);
  }

  Future<void> _openNationalFair(BuildContext context) async {
    final uri = Uri.parse(kNationalFairUrl);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Translations.getText(context, 'errorOpeningNavigation'),
          ),
        ),
      );
    }
  }

  Widget _buildWhatsAppGroupBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.green.shade50,
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 12,
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.groups,
            color: Colors.green.shade700,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Translations.getText(context, 'homeWhatsAppGroupTitle'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Translations.getText(
                    context,
                    'homeWhatsAppGroupDescription',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => _openWhatsAppGroup(context),
            child: Text(
              Translations.getText(context, 'homeWhatsAppGroupButton'),
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildScreens(AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      final user = authProvider.user;
      // Se está logado como empresa, mostrar dashboard
      if (user?.type == UserType.business) {
        return [
          SearchScreen(key: SearchScreen.searchKey), // Índice 0
          const FavoritesScreen(), // Índice 1
          const BusinessDashboardScreen(), // Índice 2 (Dashboard para empresas)
          const AccountScreen(), // Índice 3
        ];
      }
      // Se está logado como usuário normal
      return [
        SearchScreen(key: SearchScreen.searchKey), // Índice 0
        const FavoritesScreen(), // Índice 1
        const UserProfileScreen(), // Índice 2 - Nova tela de perfil aprimorada
        const AccountScreen(), // Índice 3
      ];
    } else {
      // Se não está logado, mostrar tela de login primeiro
      return [
        const LoginScreen(), // Índice 0
        SearchScreen(key: SearchScreen.searchKey), // Índice 1
        const ProfileScreen(), // Índice 2
        const AccountScreen(), // Índice 3
      ];
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      extendBody: true, // Permite que o conteúdo passe por trás da navbar flutuante
      body: StreamBuilder<String?>(
        stream: FirebaseService.seasonalThemeStream(),
        builder: (context, snapshot) {
          final seasonalThemeKey = snapshot.data;
          return Column(
            children: [
              // Header com logo e seleção de idioma
              _buildHeader(context, authProvider, seasonalThemeKey),
              // Conteúdo da tela selecionada
              Expanded(child: _buildScreens(authProvider)[_selectedIndex]),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Consumer<LocaleProvider>(
              builder: (context, localeProvider, _) {
                return BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: AppTheme.primaryGreen,
                  unselectedItemColor: Colors.grey.shade400,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  items: _buildBottomNavItems(context, authProvider),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider, String? seasonalThemeKey) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final establishmentProvider = Provider.of<EstablishmentProvider>(context, listen: false);
    final user = authProvider.user;

    // Header expandido apenas na "home" (aba de busca)
    // - Usuário autenticado: índice 0 é Busca
    // - Não autenticado: índice 1 é Busca
    final bool isExpandedHeader = authProvider.isAuthenticated
        ? _selectedIndex == 0
        : _selectedIndex == 1;
    
    return Container(
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppTheme.primaryGreen,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Top Row: Location & Profile
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            Translations.getText(context, 'appName'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const Row(
                            children: [
                              Flexible(
                                child: Text(
                                  'Encontrar locais seguros',
                                  style: TextStyle(color: Colors.white70, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 16),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Actions: Ranking & Notification
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_events, color: Color(0xFFFFD700)),
                    onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen(),
                          ),
                        );
                    },
                    tooltip: Translations.getText(context, 'topReviewers'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                       Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                       );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Parte expansível: busca + filtros avançados + categorias
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 250),
            crossFadeState: isExpandedHeader
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              children: [
                // Search Bar with Filter
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: AppTheme.primaryGreen),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _homeSearchController,
                                focusNode: _homeSearchFocusNode,
                                onTap: () {
                                  setState(() {
                                    _selectedIndex = authProvider.isAuthenticated ? 0 : 1;
                                  });
                                },
                                onChanged: (value) {
                                  establishmentProvider.setSearchQuery(value);
                                },
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  hintText: Translations.getText(context, 'searchHint'),
                                ),
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = authProvider.isAuthenticated ? 0 : 1;
                        });
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          final state = SearchScreen.searchKey.currentState;
                          if (state != null) {
                            (state as dynamic).openAdvancedFiltersFromHeader();
                          }
                        });
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.tune, color: Colors.white),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: Color(0xFFFFD700),
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Categories
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryItem(context, Icons.restaurant, 'categoryRestaurant', 'Restaurante'),
                      _buildCategoryItem(context, Icons.bakery_dining, 'categoryBakery', 'Padaria'),
                      _buildCategoryItem(context, Icons.local_cafe, 'categoryCafe', 'Café'),
                      _buildCategoryItem(context, Icons.hotel, 'categoryHotel', 'Hotel'),
                      _buildCategoryItem(context, Icons.storefront, 'categoryMarket', 'Mercado'),
                    ],
                  ),
                ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, IconData icon, String labelKey, String categoryValue) {
    final provider = Provider.of<EstablishmentProvider>(context);
    final isSelected = provider.selectedCategories.contains(categoryValue);
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedIndex = 0);
          final current = Set<String>.from(provider.selectedCategories);
          if (isSelected) {
            current.remove(categoryValue);
          } else {
            current.add(categoryValue);
          }
          provider.setAdvancedFilters(categories: current);
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppTheme.primaryGreen : Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              Translations.getText(context, labelKey),
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavItems(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      final user = authProvider.user;
      if (user?.type == UserType.business) {
        return [
          BottomNavigationBarItem(
            icon: const Icon(Icons.search_outlined),
            activeIcon: const Icon(Icons.search),
            label: Translations.getText(context, 'search'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_outline),
            activeIcon: const Icon(Icons.favorite),
            label: Translations.getText(context, 'favorites'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard_outlined),
            activeIcon: const Icon(Icons.dashboard),
            label: Translations.getText(context, 'dashboard'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_outlined),
            activeIcon: const Icon(Icons.settings),
            label: Translations.getText(context, 'settings'),
          ),
        ];
      }
      // User Normal
      return [
        BottomNavigationBarItem(
          icon: const Icon(Icons.search_outlined),
          activeIcon: const Icon(Icons.search),
          label: Translations.getText(context, 'search'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.favorite_outline),
          activeIcon: const Icon(Icons.favorite),
          label: Translations.getText(context, 'favorites'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline), // Perfil agora é bonequinho
          activeIcon: const Icon(Icons.person),
          label: Translations.getText(context, 'profile'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined), // Conta virou Configurações (Engrenagem)
          activeIcon: const Icon(Icons.settings),
          label: Translations.getText(context, 'settings'),
        ),
      ];
    } else {
      return [
        BottomNavigationBarItem(
          icon: const Icon(Icons.login_outlined),
          activeIcon: const Icon(Icons.login),
          label: Translations.getText(context, 'login'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.search_outlined),
          activeIcon: const Icon(Icons.search),
          label: Translations.getText(context, 'search'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: Translations.getText(context, 'profile'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings_outlined),
          activeIcon: const Icon(Icons.settings),
          label: Translations.getText(context, 'settings'),
        ),
      ];
    }
  }

  _SeasonalVariant _getSeasonalVariant(String? themeKey) {
    final key = (themeKey ?? '').toLowerCase().trim();
    if (key == 'christmas' || key == 'natal' || key == 'xmas') {
      return _SeasonalVariant.christmas;
    }
    if (key == 'carnival' || key == 'carnaval') {
      return _SeasonalVariant.carnival;
    }
    return _SeasonalVariant.none;
  }

  String? _getSeasonalLabel(BuildContext context, String? themeKey) {
    final variant = _getSeasonalVariant(themeKey);
    switch (variant) {
      case _SeasonalVariant.christmas:
        return Translations.getText(context, 'seasonalBadgeChristmas');
      case _SeasonalVariant.carnival:
        return Translations.getText(context, 'seasonalBadgeCarnival');
      case _SeasonalVariant.none:
        return null;
    }
  }

  Color _getSeasonalColor(String? themeKey) {
    final variant = _getSeasonalVariant(themeKey);
    switch (variant) {
      case _SeasonalVariant.christmas:
        return const Color(0xFFBF1E2E);
      case _SeasonalVariant.carnival:
        return Colors.purple;
      case _SeasonalVariant.none:
        return Colors.green;
    }
  }

  IconData _getSeasonalIcon(String? themeKey) {
    final variant = _getSeasonalVariant(themeKey);
    switch (variant) {
      case _SeasonalVariant.christmas:
        return Icons.celebration;
      case _SeasonalVariant.carnival:
        return Icons.festival;
      case _SeasonalVariant.none:
        return Icons.star;
    }
  }

  Widget _buildSeasonalChip(BuildContext context, String? themeKey) {
    final label = _getSeasonalLabel(context, themeKey);
    if (label == null) {
      return const SizedBox.shrink();
    }
    final color = _getSeasonalColor(themeKey);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSeasonalIcon(themeKey),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

}

// Tela de perfil
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Translations.getText(context, 'myProfile'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (user != null) ...[
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.green.shade100,
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null
                  ? Text(
                      user.name?.substring(0, 1).toUpperCase() ?? user.email.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontSize: 32,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.name ?? Translations.getText(context, 'noName'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: user.type == UserType.business 
                    ? Colors.blue.shade50 
                    : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    user.type == UserType.business 
                        ? Icons.business 
                        : Icons.person,
                    color: user.type == UserType.business 
                        ? Colors.blue 
                        : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.type == UserType.business 
                        ? Translations.getText(context, 'businessAccount')
                        : Translations.getText(context, 'userAccount'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: user.type == UserType.business 
                          ? Colors.blue 
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Text(Translations.getText(context, 'noUserLoggedIn')),
        ],
      ),
    );
  }

}

// Tela de conta
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  static Widget _buildLanguageSelector(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translations.getText(context, 'language'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildLanguageButton(
                        context,
                        'PT',
                        'Português',
                        localeProvider.isSelected('pt'),
                        () => _changeLanguage(context, 'pt'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLanguageButton(
                        context,
                        'EN',
                        'English',
                        localeProvider.isSelected('en'),
                        () => _changeLanguage(context, 'en'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLanguageButton(
                        context,
                        'ES',
                        'Español',
                        localeProvider.isSelected('es'),
                        () => _changeLanguage(context, 'es'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildLanguageButton(BuildContext context, String code, String label, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? Colors.green : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                code,
                style: TextStyle(
                  color: isSelected ? Colors.green : Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.green : Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _changeLanguage(BuildContext context, String code) async {
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Atualizar idioma no LocaleProvider
    localeProvider.selectLanguage(code);
    
    // Salvar preferência do usuário se estiver logado
    if (authProvider.isAuthenticated && authProvider.user != null) {
      await authProvider.updatePreferredLanguage(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            Translations.getText(context, 'account'),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          if (user != null) ...[
            ListTile(
              leading: const Icon(Icons.email, color: Colors.grey),
              title: Text(Translations.getText(context, 'email') ?? 'Email'),
              subtitle: Text(user.email),
            ),
            const Divider(),
            if (user.name != null) ...[
              ListTile(
                leading: const Icon(Icons.person, color: Colors.grey),
                title: Text(Translations.getText(context, 'name')),
                subtitle: Text(user.name!),
              ),
              const Divider(),
            ],
            ListTile(
              leading: Icon(
                user.type == UserType.business ? Icons.business : Icons.person,
                color: Colors.grey,
              ),
              title: Text(Translations.getText(context, 'accountType')),
              subtitle: Text(
                user.type == UserType.business ? Translations.getText(context, 'business') : Translations.getText(context, 'user'),
              ),
            ),
            const Divider(),
            const SizedBox(height: 24),
            // Seletor de idioma
            _buildLanguageSelector(context),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                icon: const Icon(Icons.logout),
                label: Text(Translations.getText(context, 'logout')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ] else ...[
            Text(Translations.getText(context, 'noUserLoggedIn')),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/login');
                },
                child: Text(Translations.getText(context, 'doLogin')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


