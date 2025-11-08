# Guia de Configuração - SafePlate MVP

Este guia explica como configurar todas as funcionalidades reais do MVP.

## 1. Configuração do Firebase

### Passo 1: Criar projeto no Firebase Console
1. Acesse [Firebase Console](https://console.firebase.google.com/)
2. Clique em "Adicionar projeto"
3. Siga o assistente para criar o projeto

### Passo 2: Configurar FlutterFire CLI
```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase para o projeto
flutterfire configure
```

Isso criará automaticamente o arquivo `lib/firebase_options.dart` com as credenciais.

### Passo 3: Configurar Google Sign-In
1. No Firebase Console, vá em "Authentication" > "Sign-in method"
2. Ative "Google" como método de login
3. Configure o SHA-1 fingerprint (para Android):
   ```bash
   # Android
   cd android
   ./gradlew signingReport
   ```
4. Copie o SHA-1 e adicione no Firebase Console > Project Settings > Android apps

### Arquivos necessários:
- `android/app/google-services.json` (baixado do Firebase Console)
- `ios/Runner/GoogleService-Info.plist` (baixado do Firebase Console)
- `lib/firebase_options.dart` (gerado pelo flutterfire configure)

## 2. Configuração do Mapbox

### Passo 1: Criar conta no Mapbox
1. Acesse [Mapbox](https://www.mapbox.com/)
2. Crie uma conta gratuita
3. Vá em "Account" > "Access tokens"
4. Copie seu token de acesso público (ou crie um novo)

### Passo 2: Token já configurado! ✅
O token do Mapbox já foi adicionado ao projeto:
- Token: `pk.eyJ1Ijoic2FmZXBsYXRlNTAwIiwiYSI6ImNtaGZoMXF2NTA1dDIya3B5dnljbXkzZG4ifQ.DgeBcy0YXvBdDLdPVerqjA`
- Arquivo: `lib/services/mapbox_service.dart`

Se precisar alterar, edite o arquivo `lib/services/mapbox_service.dart`.

### Passo 3: Configurar Android (se necessário)
Adicione no `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.mapbox.accessToken"
    android:value="YOUR_MAPBOX_ACCESS_TOKEN" />
```

### Passo 4: Configurar iOS (se necessário)
Adicione no `ios/Runner/Info.plist`:
```xml
<key>MBXAccessToken</key>
<string>YOUR_MAPBOX_ACCESS_TOKEN</string>
```

## 3. Permissões

### Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

### iOS (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Precisamos da sua localização para mostrar estabelecimentos próximos</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Precisamos da sua localização para mostrar estabelecimentos próximos</string>
```

## 4. Instalação de Dependências

```bash
# Instalar dependências do Flutter
flutter pub get

# Para iOS (se estiver usando macOS)
cd ios
pod install
cd ..
```

## 5. Configuração do Build

### Android
1. Certifique-se de ter o `google-services.json` em `android/app/`
2. Verifique se o `minSdkVersion` é pelo menos 21 em `android/app/build.gradle`

### iOS
1. Certifique-se de ter o `GoogleService-Info.plist` em `ios/Runner/`
2. Execute `pod install` no diretório `ios/`

## 6. Executar o App

```bash
# Executar em modo debug
flutter run

# Executar em modo release (Android)
flutter build apk --release

# Executar em modo release (iOS)
flutter build ios --release
```

## Troubleshooting

### Firebase não inicializa
- Verifique se `firebase_options.dart` existe e está configurado
- Verifique se os arquivos `google-services.json` e `GoogleService-Info.plist` estão no lugar certo
- Verifique se executou `flutterfire configure`

### Mapbox não funciona
- Verifique se o token foi substituído corretamente
- Verifique se as permissões de localização estão configuradas
- Verifique os logs para mensagens de erro do Mapbox

### Google Sign-In não funciona
- Verifique se o SHA-1 fingerprint está configurado no Firebase
- Verifique se o Google Sign-In está ativado no Firebase Console
- Verifique se o `google-services.json` está atualizado

### Erro de permissões de localização
- Verifique se as permissões estão declaradas nos manifestos
- Verifique se o usuário concedeu permissão no dispositivo
- Teste em um dispositivo real (emuladores podem ter problemas)

## Suporte

Se encontrar problemas, verifique:
1. Os logs do Flutter (`flutter logs`)
2. Os logs do Firebase Console
3. A documentação oficial:
   - [Firebase Flutter](https://firebase.flutter.dev/)
   - [Mapbox Maps Flutter](https://docs.mapbox.com/flutter/maps/)

