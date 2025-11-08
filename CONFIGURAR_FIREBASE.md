# 🔥 Como Configurar Firebase - Passo a Passo

## ✅ O QUE JÁ FOI FEITO

✅ **Permissões Android configuradas**
- Internet
- Localização (Fine e Coarse)
- Network State

✅ **Permissões iOS configuradas**
- NSLocationWhenInUseUsageDescription
- NSLocationAlwaysUsageDescription
- NSLocationAlwaysAndWhenInUseUsageDescription

✅ **Código Firebase implementado**
- AuthProvider pronto
- Login com Google implementado
- Login com email/senha implementado

## 📋 PRÓXIMOS PASSOS PARA CONFIGURAR FIREBASE

### Passo 1: Instalar FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### Passo 2: Fazer Login no Firebase

```bash
firebase login
```

Isso abrirá seu navegador para fazer login na conta Google associada ao Firebase.

### Passo 3: Criar Projeto no Firebase Console

1. Acesse: https://console.firebase.google.com/
2. Clique em "Adicionar projeto"
3. Nome do projeto: `SafePlate` (ou outro de sua escolha)
4. Siga o assistente para criar o projeto

### Passo 4: Adicionar Apps ao Firebase

#### Android:
1. No Firebase Console, clique em "Adicionar app" > Android
2. Package name: `com.safeplate.safeplate`
3. Baixe o arquivo `google-services.json`
4. Coloque em: `android/app/google-services.json`

#### iOS (se for desenvolver para iOS):
1. No Firebase Console, clique em "Adicionar app" > iOS
2. Bundle ID: `com.safeplate.safeplate`
3. Baixe o arquivo `GoogleService-Info.plist`
4. Coloque em: `ios/Runner/GoogleService-Info.plist`

### Passo 5: Configurar FlutterFire

```bash
flutterfire configure
```

Este comando irá:
- Detectar seus apps Firebase
- Criar o arquivo `lib/firebase_options.dart`
- Configurar tudo automaticamente

### Passo 6: Configurar Google Sign-In

1. No Firebase Console: **Authentication** > **Sign-in method**
2. Clique em **Google** e ative
3. Configure o email de suporte do projeto
4. Salve

### Passo 7: Obter SHA-1 para Android (para Google Sign-In)

```bash
cd android
.\gradlew signingReport
```

Copie o SHA-1 (parecido com: `AA:BB:CC:DD:...`) e adicione no Firebase Console:
- Firebase Console > Project Settings > Your apps > Android app
- Adicione o SHA-1 fingerprint

### Passo 8: Atualizar build.gradle

#### No arquivo `android/build.gradle.kts`:
Adicione antes do fechamento:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

#### No arquivo `android/app/build.gradle.kts`:
Adicione no final:
```kotlin
plugins {
    // ... plugins existentes ...
    id("com.google.gms.google-services")
}
```

## ✅ VERIFICAÇÃO FINAL

Após configurar, verifique:

- [ ] `lib/firebase_options.dart` existe e está configurado
- [ ] `android/app/google-services.json` existe
- [ ] `ios/Runner/GoogleService-Info.plist` existe (se iOS)
- [ ] Google Sign-In ativado no Firebase Console
- [ ] SHA-1 adicionado no Firebase Console (Android)
- [ ] `flutterfire configure` executado com sucesso

## 🚀 TESTAR

```bash
flutter run
```

O login deve funcionar agora!

## 🐛 TROUBLESHOOTING

### Erro: "FirebaseApp not initialized"
- Execute `flutterfire configure` novamente
- Verifique se `firebase_options.dart` existe

### Erro: Google Sign-In não funciona
- Verifique se SHA-1 está configurado no Firebase
- Verifique se Google Sign-In está ativado no Firebase Console

### Erro: "google-services.json not found"
- Certifique-se de que o arquivo está em `android/app/google-services.json`
- Execute `flutter clean` e `flutter pub get`

## 📝 NOTA IMPORTANTE

O comando `flutterfire configure` é **interativo** e requer que você:
1. Esteja logado no Firebase (`firebase login`)
2. Tenha um projeto criado no Firebase Console
3. Tenha baixado os arquivos `google-services.json` e `GoogleService-Info.plist`

Após executar `flutterfire configure`, tudo será configurado automaticamente!

