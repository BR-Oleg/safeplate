import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../models/user.dart';
import '../widgets/google_sign_in_button.dart';
import '../utils/translations.dart';
import 'home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserType _selectedUserType = UserType.user;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedLanguage; // Idioma selecionado no cadastro

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('As senhas não coincidem'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final languageCode = _selectedLanguage ?? localeProvider.locale.languageCode;
    
    final success = await authProvider.signUp(
      _emailController.text.trim(),
      _passwordController.text,
      _selectedUserType,
      _nameController.text.trim(),
      preferredLanguage: languageCode,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      final userType = authProvider.user?.type == UserType.business ? 'Empresa' : 'Usuário';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conta criada com sucesso como $userType! ✅'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      final errorMessage = authProvider.errorMessage ?? 'Erro ao criar conta. Tente novamente.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    final languageCode = _selectedLanguage ?? localeProvider.locale.languageCode;
    
    final success = await authProvider.loginWithGoogle(_selectedUserType, preferredLanguage: languageCode);

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      final userType = authProvider.user?.type == UserType.business ? 'Empresa' : 'Usuário';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cadastro com Google realizado como $userType! ✅'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      final errorMessage = authProvider.errorMessage ?? 'Erro ao fazer cadastro com Google. Tente novamente.';
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Logo e título
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 70,
                        height: 70,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Prato Seguro',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Safe Plate',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                
                // Seletor de idioma
                _buildLanguageSelector(),
                const SizedBox(height: 24),
                
                // Título Cadastrar
                Text(
                  Translations.getText(context, 'createAccount') ?? 'Criar Conta',
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
                        'Usuário',
                        UserType.user,
                        _selectedUserType == UserType.user,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildUserTypeButton(
                        'Empresa',
                        UserType.business,
                        _selectedUserType == UserType.business,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Campo de nome
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person_outlined, color: Colors.grey),
                    labelText: _selectedUserType == UserType.business ? 'Nome da Empresa' : 'Nome',
                    hintText: _selectedUserType == UserType.business ? 'Nome da Empresa' : 'Nome completo',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe o ${_selectedUserType == UserType.business ? 'nome da empresa' : 'nome'}';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de email
                TextFormField(
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe o email';
                    }
                    if (!value.contains('@')) {
                      return 'Por favor, informe um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outlined, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    labelText: 'Senha',
                    hintText: 'Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, informe a senha';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de confirmar senha
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outlined, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    labelText: 'Confirmar Senha',
                    hintText: 'Confirmar Senha',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, confirme a senha';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Botão de cadastro
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add, size: 20),
                            SizedBox(width: 8),
                            Text('Criar Conta', style: TextStyle(fontSize: 16)),
                          ],
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
                        'ou',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Botão de cadastro com Google
                GoogleSignInButton(
                  onPressed: _handleGoogleSignUp,
                  text: 'Continuar com Google',
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 32),

                // Link para login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Já tem uma conta? ',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Entrar',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  Translations.getText(context, 'language'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildLanguageButton(
                        'PT',
                        localeProvider.isSelected('pt') || (_selectedLanguage == null && localeProvider.locale.languageCode == 'pt'),
                        () {
                          setState(() {
                            _selectedLanguage = 'pt';
                          });
                          localeProvider.selectLanguage('pt');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLanguageButton(
                        'EN',
                        localeProvider.isSelected('en') || (_selectedLanguage == null && localeProvider.locale.languageCode == 'en'),
                        () {
                          setState(() {
                            _selectedLanguage = 'en';
                          });
                          localeProvider.selectLanguage('en');
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildLanguageButton(
                        'ES',
                        localeProvider.isSelected('es') || (_selectedLanguage == null && localeProvider.locale.languageCode == 'es'),
                        () {
                          setState(() {
                            _selectedLanguage = 'es';
                          });
                          localeProvider.selectLanguage('es');
                        },
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

  Widget _buildLanguageButton(String code, bool isSelected, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.green : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            code,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.green : Colors.grey.shade700,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

