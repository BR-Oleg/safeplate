import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/establishment_provider.dart';
import '../providers/locale_provider.dart';
import '../models/establishment.dart';
import '../models/user.dart';
import '../utils/translations.dart';
import 'search_screen.dart';
import 'login_screen.dart';
import 'favorites_screen.dart';
import 'business_dashboard_screen.dart';
import 'user_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int get _initialIndex {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    return authProvider.isAuthenticated ? 0 : 1; // Busca se logado, Login se não
  }
  
  late int _selectedIndex = _initialIndex;

  List<Widget> _buildScreens(AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      final user = authProvider.user;
      // Se está logado como empresa, mostrar dashboard
      if (user?.type == UserType.business) {
        return [
          const SearchScreen(), // Índice 0
          const FavoritesScreen(), // Índice 1
          const BusinessDashboardScreen(), // Índice 2 (Dashboard para empresas)
          const AccountScreen(), // Índice 3
        ];
      }
      // Se está logado como usuário normal
      return [
        const SearchScreen(), // Índice 0
        const FavoritesScreen(), // Índice 1
        const UserProfileScreen(), // Índice 2 - Nova tela de perfil aprimorada
        const AccountScreen(), // Índice 3
      ];
    } else {
      // Se não está logado, mostrar tela de login primeiro
      return [
        const LoginScreen(), // Índice 0
        const SearchScreen(), // Índice 1
        const ProfileScreen(), // Índice 2
        const AccountScreen(), // Índice 3
      ];
    }
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      body: Column(
        children: [
          // Header com logo e seleção de idioma
          _buildHeader(context, authProvider),
          const Divider(height: 1),
          // Conteúdo da tela selecionada
          Expanded(child: _buildScreens(authProvider)[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: Consumer<LocaleProvider>(
        builder: (context, localeProvider, _) {
          return BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey.shade600,
            backgroundColor: Colors.white,
            elevation: 8,
            items: _buildBottomNavItems(context, authProvider),
          );
        },
      ),
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavItems(BuildContext context, AuthProvider authProvider) {
    if (authProvider.isAuthenticated) {
      final user = authProvider.user;
      // Se está logado como empresa
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
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: Translations.getText(context, 'account'),
          ),
        ];
      }
      // Se está logado como usuário normal
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
          icon: const Icon(Icons.business_outlined),
          activeIcon: const Icon(Icons.business),
          label: Translations.getText(context, 'profile'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: Translations.getText(context, 'account'),
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
          icon: const Icon(Icons.business_outlined),
          activeIcon: const Icon(Icons.business),
          label: Translations.getText(context, 'profile'),
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: Translations.getText(context, 'account'),
        ),
      ];
    }
  }

  Widget _buildHeader(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width > 600 ? 24 : 12,
        vertical: 12,
      ),
      color: Colors.white,
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          Translations.getText(context, 'appName'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Safe Plate',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.withOpacity(0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'v1.1.0',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

    return Container(
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

    return Container(
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


