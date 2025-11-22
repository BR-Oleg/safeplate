import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../models/user.dart';
import '../widgets/google_sign_in_button.dart';
import '../utils/translations.dart';
import '../services/maintenance_service.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserType _selectedUserType = UserType.user;
  bool _isLoading = false;
  String? _selectedLanguage; // Idioma selecionado no login

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    // Verificar manutenção antes de fazer login
    final maintenanceStatus = await MaintenanceService.checkMaintenanceStatus();
    if (maintenanceStatus['enabled'] == true) {
      _showMaintenanceDialog(maintenanceStatus['message'] as String);
      return;
    }

    // Validação melhorada
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Translations.getText(context, 'loginEnterEmail')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_emailController.text.trim().contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Translations.getText(context, 'loginEnterValidEmail')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(Translations.getText(context, 'loginEnterPassword')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? languageCode;
    try {
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      languageCode = _selectedLanguage ?? localeProvider.locale.languageCode;
    } catch (e) {
      languageCode = _selectedLanguage ?? 'pt';
    }
    
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
      _selectedUserType,
      preferredLanguage: languageCode,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // Mostrar mensagem de sucesso com tipo de usuário
      final userType = authProvider.user?.type == UserType.business 
          ? Translations.getText(context, 'business') 
          : Translations.getText(context, 'user');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${Translations.getText(context, 'loginAs')} $userType! ✅'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      final errorMessage = authProvider.errorMessage ?? Translations.getText(context, 'loginError');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleFacebookLogin() async {
    // Verificar manutenção antes de fazer login
    final maintenanceStatus = await MaintenanceService.checkMaintenanceStatus();
    if (maintenanceStatus['enabled'] == true) {
      _showMaintenanceDialog(maintenanceStatus['message'] as String);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? languageCode;
    try {
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      languageCode = _selectedLanguage ?? localeProvider.locale.languageCode;
    } catch (e) {
      languageCode = _selectedLanguage ?? 'pt';
    }

    final success = await authProvider.loginWithFacebook(
      _selectedUserType,
      preferredLanguage: languageCode,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      final userType = authProvider.user?.type == UserType.business
          ? Translations.getText(context, 'business')
          : Translations.getText(context, 'user');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${Translations.getText(context, 'loginAs')} $userType! ✅'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      final errorMessage = authProvider.errorMessage ?? Translations.getText(context, 'loginError');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleAppleLogin() async {
    // Verificar manutenção antes de fazer login
    final maintenanceStatus = await MaintenanceService.checkMaintenanceStatus();
    if (maintenanceStatus['enabled'] == true) {
      _showMaintenanceDialog(maintenanceStatus['message'] as String);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? languageCode;
    try {
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      languageCode = _selectedLanguage ?? localeProvider.locale.languageCode;
    } catch (e) {
      languageCode = _selectedLanguage ?? 'pt';
    }

    final success = await authProvider.loginWithApple(
      _selectedUserType,
      preferredLanguage: languageCode,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      final userType = authProvider.user?.type == UserType.business
          ? Translations.getText(context, 'business')
          : Translations.getText(context, 'user');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${Translations.getText(context, 'loginAs')} $userType! ✅'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      final errorMessage = authProvider.errorMessage ?? Translations.getText(context, 'loginError');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Translations.getText(context, 'loginEnterValidEmailForReset'),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Translations.getText(context, 'passwordResetEmailSent'),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Translations.getText(context, 'passwordResetEmailError'),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    // Verificar manutenção antes de fazer login
    final maintenanceStatus = await MaintenanceService.checkMaintenanceStatus();
    if (maintenanceStatus['enabled'] == true) {
      _showMaintenanceDialog(maintenanceStatus['message'] as String);
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    String? languageCode;
    try {
      final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
      languageCode = _selectedLanguage ?? localeProvider.locale.languageCode;
    } catch (e) {
      languageCode = _selectedLanguage ?? 'pt';
    }
    
    final success = await authProvider.loginWithGoogle(_selectedUserType, preferredLanguage: languageCode);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      // Mostrar mensagem de sucesso com tipo de usuário
      final userType = authProvider.user?.type == UserType.business 
          ? Translations.getText(context, 'business') 
          : Translations.getText(context, 'user');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${Translations.getText(context, 'googleLoginAs')} $userType! ✅'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      final errorMessage = authProvider.errorMessage ?? Translations.getText(context, 'googleLoginError');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Logo e título
              Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 80,
                    height: 80,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Prato Seguro',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Safe Plate',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'v1.1.0',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      color: Colors.grey.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              
              // Título Entrar
              Text(
                Translations.getText(context, 'doLogin'),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Seletor de tipo de usuário
              Row(
                children: [
                  Expanded(
                    child: _buildUserTypeButton(
                      Translations.getText(context, 'user'),
                      UserType.user,
                      _selectedUserType == UserType.user,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildUserTypeButton(
                      Translations.getText(context, 'business'),
                      UserType.business,
                      _selectedUserType == UserType.business,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Campo de email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.grey),
                  labelText: Translations.getText(context, 'email'),
                  hintText: Translations.getText(context, 'email'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de senha
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outlined, color: Colors.grey),
                  labelText: Translations.getText(context, 'password'),
                  hintText: Translations.getText(context, 'password'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isLoading ? null : _handleForgotPassword,
                  child: Text(
                    Translations.getText(context, 'forgotPassword'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Botão de login
              AnimatedScale(
                scale: _isLoading ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.login, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              Translations.getText(context, 'doLogin'),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Separador
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      Translations.getText(context, 'or'),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),

              // Botão de login com Google
              GoogleSignInButton(
                onPressed: _handleGoogleLogin,
                text: Translations.getText(context, 'continueWithGoogle'),
                isLoading: _isLoading,
              ),
              const SizedBox(height: 12),

              // Botões de login social adicionais
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              Translations.getText(
                                context,
                                'socialLoginComingSoon',
                              ),
                            ),
                          ),
                        );
                      },
                child: Text(
                  Translations.getText(context, 'continueWithFacebook'),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              Translations.getText(
                                context,
                                'socialLoginComingSoon',
                              ),
                            ),
                          ),
                        );
                      },
                child: Text(
                  Translations.getText(context, 'continueWithApple'),
                ),
              ),
              const SizedBox(height: 24),

              // Link para cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    Translations.getText(context, 'dontHaveAccount'),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      Translations.getText(context, 'signUp'),
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Seletor de idioma minimalista
              _buildLanguageSelector(),
              const SizedBox(height: 16),

              // Links de rodapé
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      Translations.getText(context, 'termsOfUse'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      Translations.getText(context, 'privacyPolicy'),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                Translations.getText(context, 'dataProtectionMessage'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeButton(String label, UserType type, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedUserType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.green : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        final currentLang = _selectedLanguage ?? localeProvider.locale.languageCode;
        return PopupMenuButton<String>(
          icon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _flagForCode(currentLang),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 4),
              Text(
                currentLang.toUpperCase(),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          onSelected: (String code) {
            setState(() {
              _selectedLanguage = code;
            });
            localeProvider.selectLanguage(code);
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'pt',
              child: Row(
                children: [
                  Text(
                    _flagForCode('pt'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PT',
                    style: TextStyle(
                      fontWeight: currentLang == 'pt' ? FontWeight.bold : FontWeight.normal,
                      color: currentLang == 'pt' ? Colors.green : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Português',
                    style: TextStyle(
                      color: currentLang == 'pt' ? Colors.green : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  Text(
                    _flagForCode('en'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'EN',
                    style: TextStyle(
                      fontWeight: currentLang == 'en' ? FontWeight.bold : FontWeight.normal,
                      color: currentLang == 'en' ? Colors.green : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'English',
                    style: TextStyle(
                      color: currentLang == 'en' ? Colors.green : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'es',
              child: Row(
                children: [
                  Text(
                    _flagForCode('es'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'ES',
                    style: TextStyle(
                      fontWeight: currentLang == 'es' ? FontWeight.bold : FontWeight.normal,
                      color: currentLang == 'es' ? Colors.green : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Español',
                    style: TextStyle(
                      color: currentLang == 'es' ? Colors.green : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _flagForCode(String code) {
    switch (code) {
      case 'pt':
        return '🇧🇷';
      case 'es':
        return '🇪🇸';
      case 'en':
      default:
        return '🇺🇸';
    }
  }

  void _showMaintenanceDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.build, color: Colors.orange),
              SizedBox(width: 8),
              Text('Manutenção'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Tentar verificar novamente
                _handleLogin();
              },
              child: const Text('Tentar Novamente'),
            ),
          ],
        ),
      ),
    );
  }
}

