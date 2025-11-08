# ✅ Próximos Passos - SafePlate MVP

## 🎉 O QUE JÁ FOI FEITO

✅ **Google Services configurado**
- ✅ `google-services.json` colocado em `android/app/`
- ✅ `firebase_options.dart` criado com suas credenciais
- ✅ `main.dart` atualizado para usar Firebase
- ✅ `android/build.gradle.kts` configurado (Google Services plugin)
- ✅ `android/app/build.gradle.kts` configurado (Google Services plugin)

✅ **Permissões configuradas**
- ✅ Permissões Android (INTERNET, LOCALIZAÇÃO)
- ✅ Permissões iOS (NSLocationWhenInUseUsageDescription)

✅ **Outros**
- ✅ Mapbox token configurado
- ✅ Código Firebase implementado
- ✅ Todas as funcionalidades prontas

## 🔥 PRÓXIMO PASSO: Ativar Google Sign-In no Firebase

### 1. Acesse Firebase Console

https://console.firebase.google.com/project/safeplate-a14e9

### 2. Ativar Google Sign-In

1. No menu lateral: **Authentication** > **Sign-in method**
2. Clique em **Google**
3. Clique no **toggle** para **Ativar**
4. Configure o **Email de suporte do projeto** (pode ser qualquer email)
5. Clique em **Salvar**

### 3. (Opcional) Obter SHA-1 para Android

Se quiser testar Google Sign-In no Android:

1. Execute:
   ```powershell
   cd android
   .\gradlew signingReport
   ```

2. Copie o **SHA-1** (algo como: `AA:BB:CC:DD:EE:...`)

3. No Firebase Console:
   - **Project Settings** > **Your apps** > **Android app** (safeplate)
   - Role até **SHA certificate fingerprints**
   - Clique em **Add fingerprint**
   - Cole o SHA-1 e salve

**Nota**: Isso é opcional - login com email/senha funciona sem SHA-1!

## 🚀 TESTAR O APP

### 1. Executar em modo debug

```bash
flutter run
```

### 2. Testar Login

**Login com Email/Senha:**
- Crie uma conta primeiro (cadastro)
- Depois faça login

**Login com Google:**
- Funcionará após ativar no Firebase Console
- Precisa de SHA-1 se testar no Android

## ✅ CHECKLIST FINAL

- [x] google-services.json em android/app/
- [x] firebase_options.dart criado
- [x] main.dart configurado
- [x] build.gradle.kts configurado
- [ ] **Ativar Google Sign-In no Firebase Console** ⚠️
- [ ] **Adicionar SHA-1 (opcional, para Google Sign-In Android)** ⚠️
- [ ] Testar login com email/senha
- [ ] Testar login com Google
- [ ] Testar mapa
- [ ] Testar favoritos

## 🐛 SE TIVER PROBLEMAS

### Firebase não inicializa

**Verificar:**
1. `google-services.json` está em `android/app/`?
2. `firebase_options.dart` existe em `lib/`?
3. Executou `flutter clean` e `flutter pub get`?

**Solução:**
```bash
flutter clean
flutter pub get
flutter run
```

### Google Sign-In não funciona

**Verificar:**
1. Google Sign-In está ativado no Firebase Console?
2. SHA-1 foi adicionado (Android)?
3. Package name está correto: `com.safeplate.safeplate`?

### Mapa não funciona

**Verificar:**
1. Token do Mapbox está configurado? (já está ✅)
2. Permissões de localização foram concedidas?

## 📊 STATUS ATUAL

✅ **Pronto para testar:**
- Login com email/senha
- Mapa com Mapbox
- Favoritos
- Busca e filtros

⚠️ **Aguardando:**
- Ativar Google Sign-In no Firebase Console
- Testar em dispositivo real

## 🎯 PRÓXIMA AÇÃO

**Ative o Google Sign-In no Firebase Console agora:**

1. Acesse: https://console.firebase.google.com/project/safeplate-a14e9/authentication/providers
2. Clique em **Google**
3. **Ative**
4. Salve

Depois disso, execute `flutter run` e teste tudo! 🚀

