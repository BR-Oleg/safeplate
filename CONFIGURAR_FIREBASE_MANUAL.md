# 🔥 Configurar Firebase Manualmente (Sem FlutterFire CLI)

Se você não quer instalar o Git agora, pode configurar o Firebase manualmente seguindo estes passos:

## 📋 Passo a Passo Manual

### 1. Criar Projeto no Firebase Console

1. Acesse: https://console.firebase.google.com/
2. Clique em **"Adicionar projeto"**
3. Nome: `SafePlate` (ou outro de sua escolha)
4. Siga o assistente para criar

### 2. Adicionar App Android

1. No Firebase Console, clique em **"Adicionar app"** > **Android**
2. **Package name**: `com.safeplate.safeplate`
3. **Nome do app**: `SafePlate`
4. Baixe o arquivo **`google-services.json`**
5. Coloque o arquivo em: **`android/app/google-services.json`**

### 3. Adicionar App iOS (se necessário)

1. No Firebase Console, clique em **"Adicionar app"** > **iOS**
2. **Bundle ID**: `com.safeplate.safeplate`
3. Baixe o arquivo **`GoogleService-Info.plist`**
4. Coloque o arquivo em: **`ios/Runner/GoogleService-Info.plist`**

### 4. Atualizar build.gradle (Android)

#### 4.1. Editar `android/build.gradle.kts`:

Adicione no início do arquivo:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

#### 4.2. Editar `android/app/build.gradle.kts`:

Adicione o plugin no final do arquivo:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // Adicionar esta linha
}
```

### 5. Criar firebase_options.dart Manualmente

Crie o arquivo `lib/firebase_options.dart` com o seguinte conteúdo (substitua os valores pelos do seu projeto):

```dart
// File generated using manual configuration
// Replace these values with your Firebase project settings

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'SUA_API_KEY_AQUI',  // Do google-services.json
    appId: '1:SEU_APP_ID:android:SEU_APP_ID_AQUI',  // Do google-services.json
    messagingSenderId: 'SEU_SENDER_ID_AQUI',  // Do google-services.json
    projectId: 'seu-projeto-id',  // Do google-services.json
    storageBucket: 'seu-projeto-id.appspot.com',  // Do google-services.json
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'SUA_API_KEY_IOS_AQUI',  // Do GoogleService-Info.plist
    appId: '1:SEU_APP_ID:ios:SEU_APP_ID_IOS_AQUI',  // Do GoogleService-Info.plist
    messagingSenderId: 'SEU_SENDER_ID_AQUI',  // Do GoogleService-Info.plist
    projectId: 'seu-projeto-id',  // Do GoogleService-Info.plist
    storageBucket: 'seu-projeto-id.appspot.com',  // Do GoogleService-Info.plist
    iosBundleId: 'com.safeplate.safeplate',
  );
}
```

#### Como obter os valores:

1. **Para Android**: Abra o arquivo `android/app/google-services.json` e copie os valores:
   - `api_key.current_key` → `apiKey`
   - `client[0].client_info.android_client_info.package_name` e `client[0].client_info.mobilesdk_app_id` → `appId`
   - `project_info.project_number` → `messagingSenderId`
   - `project_info.project_id` → `projectId`
   - `project_info.storage_bucket` → `storageBucket`

2. **Para iOS**: Abra o arquivo `ios/Runner/GoogleService-Info.plist` e copie os valores:
   - `API_KEY` → `apiKey`
   - `GOOGLE_APP_ID` → `appId`
   - `GCM_SENDER_ID` → `messagingSenderId`
   - `PROJECT_ID` → `projectId`
   - `STORAGE_BUCKET` → `storageBucket`

### 6. Atualizar main.dart

Certifique-se de que `lib/main.dart` importa e usa o `firebase_options.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  // Importar o arquivo criado

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const SafePlateApp());
}
```

### 7. Configurar Google Sign-In

1. No Firebase Console: **Authentication** > **Sign-in method**
2. Clique em **Google** e ative
3. Configure email de suporte
4. Salve

### 8. Obter SHA-1 para Android (Google Sign-In)

```powershell
cd android
.\gradlew signingReport
```

Copie o SHA-1 e adicione no Firebase Console:
- Firebase Console > **Project Settings** > **Your apps** > **Android app**
- Adicione o **SHA-1 fingerprint**

## ✅ Verificação

Após configurar, teste:

```bash
flutter run
```

O login deve funcionar agora!

## 🐛 Troubleshooting

### Erro: "google-services.json not found"
- Certifique-se de que o arquivo está em `android/app/google-services.json`
- Execute `flutter clean` e `flutter pub get`

### Erro: "FirebaseApp not initialized"
- Verifique se `firebase_options.dart` está correto
- Verifique se `main.dart` importa `firebase_options.dart`

## 📝 Nota

Esta configuração manual funciona perfeitamente! A diferença é que você precisa copiar os valores manualmente ao invés de usar o CLI que faz isso automaticamente.

