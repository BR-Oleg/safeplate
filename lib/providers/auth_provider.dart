import 'package:flutter/material.dart';
import '../models/user.dart' as model;
import '../models/user_seal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';
import 'dart:convert';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';

class AuthProvider with ChangeNotifier {
  model.User? _user;
  UserCredential? _firebaseUser;
  bool _isLoading = false;
  String? _errorMessage;

  model.User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserCredential? get firebaseUser => _firebaseUser;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn? _googleSignIn;
  
  GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn(
      scopes: ['email', 'profile'],
    );
    return _googleSignIn!;
  }

  AuthProvider() {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Carregar dados locais primeiro para não travar
        await _loadUser();
        // Depois tentar atualizar do Firestore (sem bloquear)
        _loadUserFromFirebase(currentUser).then((_) {
          // Inicializar notificações push após carregar usuário
          if (_user != null) {
            NotificationService.initialize(_user!.id).catchError((e) {
              debugPrint('⚠️ Erro ao inicializar notificações: $e');
            });
          }
        }).catchError((e) {
          debugPrint('⚠️ Erro ao carregar do Firestore no _checkAuthState: $e');
        });
        // Aplicar idioma preferido após carregar usuário
        _applyPreferredLanguage();
      } else {
        await _loadUser();
        _applyPreferredLanguage();
      }
    } catch (e) {
      debugPrint('Erro ao verificar estado de autenticação: $e');
    }
  }

  void _applyPreferredLanguage() {
    if (_user?.preferredLanguage != null) {
      // Salvar no SharedPreferences para o LocaleProvider carregar
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('language', _user!.preferredLanguage!);
      });
    }
  }

  Future<void> _loadUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user');
      if (userJson != null) {
        _user = model.User.fromJson(json.decode(userJson));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erro ao carregar usuário: $e');
    }
  }

  Future<void> _loadUserFromFirebase(User firebaseUser, {String? preferredLanguage}) async {
    try {
      final userTypeString = await SharedPreferences.getInstance()
          .then((prefs) => prefs.getString('userType') ?? 'user');
      
      // Tentar carregar dados do Firestore primeiro (com timeout)
      model.User? firestoreUser;
      try {
        firestoreUser = await FirebaseService.getUserData(firebaseUser.uid)
            .timeout(const Duration(seconds: 5), onTimeout: () {
          debugPrint('⚠️ Timeout ao carregar dados do Firestore');
          return null;
        });
      } catch (e) {
        debugPrint('⚠️ Erro ao carregar dados do Firestore: $e');
      }
      
      // Usar dados do Firestore se disponíveis, senão criar novo
      if (firestoreUser != null) {
        // Usar dados do Firestore (incluindo Premium e gamificação)
        _user = firestoreUser;
        // Se temos preferredLanguage novo, atualizar apenas esse campo
        if (preferredLanguage != null && preferredLanguage != _user!.preferredLanguage) {
          _user = model.User(
            id: _user!.id,
            email: _user!.email,
            name: _user!.name,
            type: _user!.type,
            photoUrl: _user!.photoUrl,
            preferredLanguage: preferredLanguage,
            // Manter todos os dados de gamificação do Firestore
            points: _user!.points,
            seal: _user!.seal,
            isPremium: _user!.isPremium,
            premiumExpiresAt: _user!.premiumExpiresAt,
            totalCheckIns: _user!.totalCheckIns,
            totalReviews: _user!.totalReviews,
            totalReferrals: _user!.totalReferrals,
          );
          // Atualizar apenas o idioma no Firestore (sem sobrescrever outros dados)
          FirebaseService.updateUserPreferredLanguage(_user!.id, preferredLanguage)
              .catchError((e) {
            debugPrint('⚠️ Erro ao atualizar idioma no Firestore: $e');
          });
        }
      } else {
        // Criar novo usuário apenas se não existir no Firestore
        _user = model.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName,
          type: userTypeString == 'business' ? model.UserType.business : model.UserType.user,
          photoUrl: firebaseUser.photoURL,
          preferredLanguage: preferredLanguage,
          // Dados de gamificação iniciados com valores padrão
          points: 0,
          seal: UserSeal.bronze,
          isPremium: false,
          totalCheckIns: 0,
          totalReviews: 0,
          totalReferrals: 0,
        );
        // Salvar novo usuário no Firestore (sem bloquear login)
        debugPrint('💾 Salvando novo usuário no Firestore...');
        FirebaseService.saveUserData(_user!).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⚠️ Timeout ao salvar novo usuário no Firestore (continuando login)');
            return;
          },
        ).then((_) {
          debugPrint('✅ Novo usuário salvo no Firestore com sucesso');
        }).catchError((e) {
          debugPrint('⚠️ Erro ao salvar novo usuário no Firestore: $e');
        });
      }

      // Salvar localmente primeiro (não esperar Firestore)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_user!.toJson()));

      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao carregar usuário do Firebase: $e');
      // Mesmo com erro, criar usuário básico para não travar o login
      try {
        final userTypeString = await SharedPreferences.getInstance()
            .then((prefs) => prefs.getString('userType') ?? 'user');
        _user = model.User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName,
          type: userTypeString == 'business' ? model.UserType.business : model.UserType.user,
          photoUrl: firebaseUser.photoURL,
          preferredLanguage: preferredLanguage,
          // Dados de gamificação iniciados com valores padrão
          points: 0,
          seal: UserSeal.bronze,
          isPremium: false,
          totalCheckIns: 0,
          totalReviews: 0,
          totalReferrals: 0,
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(_user!.toJson()));
        notifyListeners();
      } catch (e2) {
        debugPrint('Erro crítico ao criar usuário: $e2');
      }
    }
  }

  Future<bool> login(String email, String password, model.UserType userType, {String? preferredLanguage}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🔐 Tentando fazer login com email: ${email.trim()}');
      
      // Validar email antes de tentar login
      if (email.trim().isEmpty) {
        _isLoading = false;
        _errorMessage = 'Por favor, informe o email';
        notifyListeners();
        return false;
      }

      if (password.isEmpty) {
        _isLoading = false;
        _errorMessage = 'Por favor, informe a senha';
        notifyListeners();
        return false;
      }

      if (!email.trim().contains('@')) {
        _isLoading = false;
        _errorMessage = 'Por favor, informe um email válido';
        notifyListeners();
        return false;
      }

      // Fazer login com email e senha
      UserCredential credential;
      try {
        credential = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Tempo de conexão excedido. Verifique sua internet.');
          },
        );
      } catch (e) {
        // Se o erro for relacionado a PigeonUserDetails, é um bug do Google Sign In
        // que não deveria afetar login manual, mas vamos tratar
        if (e.toString().contains('PigeonUserDetails')) {
          debugPrint('⚠️ Erro PigeonUserDetails detectado (pode ser falso positivo): $e');
          // Tentar novamente sem timeout
          credential = await _auth.signInWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
        } else {
          rethrow;
        }
      }

      debugPrint('✅ Login Firebase bem-sucedido: ${credential.user?.uid}');

      if (credential.user != null) {
        _firebaseUser = credential;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userType', userType.toString().split('.').last);

        debugPrint('📥 Carregando dados do usuário do Firestore...');
        try {
          await _loadUserFromFirebase(credential.user!, preferredLanguage: preferredLanguage);
          debugPrint('✅ Dados do usuário carregados com sucesso');
        } catch (e) {
          debugPrint('⚠️ Erro ao carregar dados do Firestore, mas continuando login: $e');
          // Continuar mesmo com erro no Firestore
        }

        // Inicializar notificações push após login
        if (_user != null) {
          NotificationService.initialize(_user!.id).catchError((e) {
            debugPrint('⚠️ Erro ao inicializar notificações: $e');
          });
        }

        _isLoading = false;
        notifyListeners();
        debugPrint('✅ Login completo com sucesso');
        return true;
      }

      _isLoading = false;
      _errorMessage = 'Erro ao fazer login. Usuário não encontrado.';
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      debugPrint('❌ Erro Firebase Auth: ${e.code} - ${e.message}');
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } on TimeoutException catch (e) {
      _isLoading = false;
      debugPrint('❌ Timeout no login: $e');
      _errorMessage = e.message ?? 'Tempo de conexão excedido. Verifique sua internet.';
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _isLoading = false;
      debugPrint('❌ Erro inesperado no login: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Filtrar erros relacionados a PigeonUserDetails (bug do Google Sign In)
      String errorMessage = e.toString();
      if (errorMessage.contains('PigeonUserDetails')) {
        debugPrint('⚠️ Erro PigeonUserDetails detectado - pode ser bug do Google Sign In');
        // Se o usuário foi autenticado mesmo com o erro, continuar
        if (_auth.currentUser != null) {
          debugPrint('✅ Usuário autenticado apesar do erro PigeonUserDetails, continuando...');
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userType', userType.toString().split('.').last);
            await _loadUserFromFirebase(_auth.currentUser!, preferredLanguage: preferredLanguage);
            
            if (_user != null) {
              NotificationService.initialize(_user!.id).catchError((e) {
                debugPrint('⚠️ Erro ao inicializar notificações: $e');
              });
            }
            
            _isLoading = false;
            notifyListeners();
            return true;
          } catch (e2) {
            debugPrint('❌ Erro ao carregar usuário após PigeonUserDetails: $e2');
          }
        }
        errorMessage = 'Erro ao fazer login. Tente novamente ou use outro método de login.';
      } else {
        errorMessage = 'Erro ao fazer login: ${e.toString()}';
      }
      
      _errorMessage = errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, model.UserType userType, String? name, {String? preferredLanguage}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('📝 Tentando criar conta com email: ${email.trim()}');
      
      // Validar email antes de tentar cadastro
      if (email.trim().isEmpty) {
        _isLoading = false;
        _errorMessage = 'Por favor, informe o email';
        notifyListeners();
        return false;
      }

      if (password.isEmpty) {
        _isLoading = false;
        _errorMessage = 'Por favor, informe a senha';
        notifyListeners();
        return false;
      }

      if (password.length < 6) {
        _isLoading = false;
        _errorMessage = 'A senha deve ter pelo menos 6 caracteres';
        notifyListeners();
        return false;
      }

      if (!email.trim().contains('@')) {
        _isLoading = false;
        _errorMessage = 'Por favor, informe um email válido';
        notifyListeners();
        return false;
      }

      // Criar conta com email e senha
      UserCredential credential;
      try {
        credential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        ).timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            throw TimeoutException('Tempo de conexão excedido. Verifique sua internet.');
          },
        );
      } catch (e) {
        // Se o erro for relacionado a PigeonUserDetails, é um bug do Google Sign In
        // que não deveria afetar cadastro manual, mas vamos tratar
        if (e.toString().contains('PigeonUserDetails')) {
          debugPrint('⚠️ Erro PigeonUserDetails detectado (pode ser falso positivo): $e');
          // Tentar novamente sem timeout
          credential = await _auth.createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );
        } else {
          rethrow;
        }
      }

      debugPrint('✅ Cadastro Firebase bem-sucedido: ${credential.user?.uid}');

      if (credential.user != null) {
        // Atualizar perfil com nome se fornecido
        if (name != null && name.isNotEmpty) {
          try {
            await credential.user!.updateDisplayName(name);
            await credential.user!.reload();
            debugPrint('✅ Nome do usuário atualizado: $name');
          } catch (e) {
            debugPrint('⚠️ Erro ao atualizar nome do usuário: $e');
            // Continuar mesmo com erro ao atualizar nome
          }
        }

        _firebaseUser = credential;
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userType', userType.toString().split('.').last);

        debugPrint('📥 Carregando dados do usuário do Firestore...');
        try {
          await _loadUserFromFirebase(credential.user!, preferredLanguage: preferredLanguage);
          debugPrint('✅ Dados do usuário carregados com sucesso');
        } catch (e) {
          debugPrint('⚠️ Erro ao carregar dados do Firestore, mas continuando cadastro: $e');
          // Continuar mesmo com erro no Firestore
        }

        // Inicializar notificações push após signup
        if (_user != null) {
          NotificationService.initialize(_user!.id).catchError((e) {
            debugPrint('⚠️ Erro ao inicializar notificações: $e');
          });
        }

        _isLoading = false;
        notifyListeners();
        debugPrint('✅ Cadastro completo com sucesso');
        return true;
      }

      _isLoading = false;
      _errorMessage = 'Erro ao criar conta. Usuário não foi criado.';
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      debugPrint('❌ Erro Firebase Auth: ${e.code} - ${e.message}');
      _errorMessage = _getAuthErrorMessage(e.code);
      notifyListeners();
      return false;
    } on TimeoutException catch (e) {
      _isLoading = false;
      debugPrint('❌ Timeout no cadastro: $e');
      _errorMessage = e.message ?? 'Tempo de conexão excedido. Verifique sua internet.';
      notifyListeners();
      return false;
    } catch (e, stackTrace) {
      _isLoading = false;
      debugPrint('❌ Erro inesperado no cadastro: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Filtrar erros relacionados a PigeonUserDetails (bug do Google Sign In)
      String errorMessage = e.toString();
      if (errorMessage.contains('PigeonUserDetails')) {
        debugPrint('⚠️ Erro PigeonUserDetails detectado - pode ser bug do Google Sign In');
        // Se o usuário foi criado mesmo com o erro, continuar
        if (_auth.currentUser != null) {
          debugPrint('✅ Usuário criado apesar do erro PigeonUserDetails, continuando...');
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('userType', userType.toString().split('.').last);
            await _loadUserFromFirebase(_auth.currentUser!, preferredLanguage: preferredLanguage);
            
            if (_user != null) {
              NotificationService.initialize(_user!.id).catchError((e) {
                debugPrint('⚠️ Erro ao inicializar notificações: $e');
              });
            }
            
            _isLoading = false;
            notifyListeners();
            return true;
          } catch (e2) {
            debugPrint('❌ Erro ao carregar usuário após PigeonUserDetails: $e2');
          }
        }
        errorMessage = 'Erro ao criar conta. Tente novamente ou use outro método de cadastro.';
      } else {
        errorMessage = 'Erro ao criar conta: ${e.toString()}';
      }
      
      _errorMessage = errorMessage;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithGoogle(model.UserType userType, {String? preferredLanguage}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Criar listener ANTES de iniciar qualquer processo
    User? authenticatedUser;
    StreamSubscription<User?>? authSubscription;
    
    authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        authenticatedUser = user;
      }
    });

    try {
      // Iniciar fluxo de login do Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        await authSubscription.cancel();
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Tentar obter autenticação (pode dar erro PigeonUserDetails)
      GoogleSignInAuthentication? googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (e) {
        debugPrint('⚠️ Erro ao obter authentication do Google (PigeonUserDetails?): $e');
        // Erro ao obter authentication - tentar método alternativo
        // Verificar se Firebase já autenticou via authStateChanges
        if (authenticatedUser != null) {
          await authSubscription.cancel();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userType', userType.toString().split('.').last);
          await _loadUserFromFirebase(authenticatedUser!, preferredLanguage: preferredLanguage);
          
          if (_user != null) {
            NotificationService.initialize(_user!.id).catchError((e) {
              debugPrint('⚠️ Erro ao inicializar notificações: $e');
            });
          }
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
        // Continuar para verificar Firebase diretamente
      }

      // Se conseguimos a autenticação, usar normalmente
      if (googleAuth != null && googleAuth.accessToken != null) {
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final userCredential = await _auth.signInWithCredential(credential);
        
        if (userCredential.user != null) {
          await authSubscription.cancel();
          _firebaseUser = userCredential;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userType', userType.toString().split('.').last);
          await _loadUserFromFirebase(userCredential.user!, preferredLanguage: preferredLanguage);
          
          // Inicializar notificações push após login com Google
          if (_user != null) {
            NotificationService.initialize(_user!.id).catchError((e) {
              debugPrint('⚠️ Erro ao inicializar notificações: $e');
            });
          }
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      // Se chegou aqui, deu erro ao obter authentication, mas Firebase pode ter autenticado
      // Aguardar um pouco para Firebase processar e verificar múltiplas vezes
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 400));
        
        // Verificar se listener capturou
        if (authenticatedUser != null) {
          await authSubscription.cancel();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userType', userType.toString().split('.').last);
          await _loadUserFromFirebase(authenticatedUser!, preferredLanguage: preferredLanguage);
          
          // Inicializar notificações push após login com Google
          if (_user != null) {
            NotificationService.initialize(_user!.id).catchError((e) {
              debugPrint('⚠️ Erro ao inicializar notificações: $e');
            });
          }
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
        
        // Verificar diretamente também
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          await authSubscription.cancel();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userType', userType.toString().split('.').last);
          await _loadUserFromFirebase(currentUser, preferredLanguage: preferredLanguage);
          
          // Inicializar notificações push após login com Google
          if (_user != null) {
            NotificationService.initialize(_user!.id).catchError((e) {
              debugPrint('⚠️ Erro ao inicializar notificações: $e');
            });
          }
          
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }

      await authSubscription.cancel();
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      await authSubscription?.cancel();
      
      // Última tentativa: verificar se usuário foi autenticado
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(milliseconds: 400));
        final currentUser = _auth.currentUser;
        
        if (currentUser != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userType', userType.toString().split('.').last);
          await _loadUserFromFirebase(currentUser, preferredLanguage: preferredLanguage);
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
      _isLoading = false;
      _errorMessage = 'Erro ao fazer login com Google';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // Remover token FCM antes de fazer logout
      if (_user != null) {
        await NotificationService.removeFcmToken(_user!.id).catchError((e) {
          debugPrint('⚠️ Erro ao remover FCM token: $e');
        });
      }
      
      // Fazer logout do Google Sign In (se estiver inicializado)
      try {
        if (_googleSignIn != null) {
          await googleSignIn.signOut();
        }
      } catch (e) {
        debugPrint('⚠️ Erro ao fazer logout do Google: $e');
        // Continuar mesmo com erro
      }
      await _auth.signOut();
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await prefs.remove('userType');
      
      _user = null;
      _firebaseUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Erro ao fazer logout: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      debugPrint('Erro ao enviar email de recuperação: $e');
      rethrow;
    }
  }

  /// Atualiza o idioma preferido do usuário
  Future<void> updatePreferredLanguage(String languageCode) async {
    if (_user == null) return;
    
    try {
      // Atualizar objeto local primeiro
      _user = model.User(
        id: _user!.id,
        email: _user!.email,
        name: _user!.name,
        type: _user!.type,
        photoUrl: _user!.photoUrl,
        preferredLanguage: languageCode,
      );
      
      // Salvar localmente primeiro (não esperar Firestore)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_user!.toJson()));
      
      notifyListeners();
      
      // Tentar atualizar no Firestore em background (não bloquear)
      FirebaseService.updateUserPreferredLanguage(_user!.id, languageCode)
          .catchError((e) {
        debugPrint('⚠️ Erro ao atualizar idioma no Firestore: $e');
      });
    } catch (e) {
      debugPrint('Erro ao atualizar idioma preferido: $e');
    }
  }

  /// Recarrega os dados do usuário do Firestore
  Future<void> reloadUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Se não há usuário autenticado, tentar carregar do local
      await _loadUser();
      return;
    }
    
    try {
      final firestoreUser = await FirebaseService.getUserData(currentUser.uid)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('⚠️ Timeout ao recarregar dados do usuário');
        return null;
      });
      
      if (firestoreUser != null) {
        // Mesclar dados: manter dados locais se Firestore não tiver algo
        _user = firestoreUser;
        // Salvar localmente também
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', json.encode(_user!.toJson()));
        notifyListeners();
        debugPrint('✅ Dados do usuário recarregados do Firestore');
      } else {
        // Se não conseguiu do Firestore, manter dados locais
        debugPrint('⚠️ Não foi possível recarregar do Firestore, mantendo dados locais');
      }
    } catch (e) {
      debugPrint('⚠️ Erro ao recarregar dados do usuário: $e');
      // Em caso de erro, manter dados locais
      await _loadUser();
    }
  }

  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Nenhum usuário encontrado com este email.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'Este email já está sendo usado.';
      case 'invalid-email':
        return 'Email inválido.';
      case 'weak-password':
        return 'Senha muito fraca. Use pelo menos 6 caracteres.';
      case 'network-request-failed':
        return 'Erro de conexão. Verifique sua internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Aguarde alguns minutos e tente novamente.';
      case 'user-disabled':
        return 'Esta conta foi desabilitada. Entre em contato com o suporte.';
      case 'operation-not-allowed':
        return 'Operação não permitida. Verifique as configurações do Firebase.';
      case 'invalid-credential':
        return 'Credenciais inválidas. Verifique email e senha.';
      case 'requires-recent-login':
        return 'Por favor, faça logout e login novamente.';
      default:
        debugPrint('⚠️ Código de erro não mapeado: $code');
        return 'Erro ao fazer login. Tente novamente. (Código: $code)';
    }
  }
}

