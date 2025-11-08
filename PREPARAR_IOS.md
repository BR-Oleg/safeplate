# 📱 Preparar Projeto iOS - Checklist Completo

Checklist para preparar seu projeto Flutter para compilação iOS.

## ✅ Checklist Pré-Compilação

### 1. Configurações do Projeto

- [x] **Nome do App**: Atualizado para "Prato Seguro" no `Info.plist`
- [x] **Permissões**: Configuradas (Localização, Câmera, Fotos)
- [x] **Background Modes**: Configurado para notificações push
- [ ] **Bundle Identifier**: Verificar e configurar
- [ ] **GoogleService-Info.plist**: Adicionar arquivo Firebase iOS
- [ ] **Versão**: Verificar versão no `pubspec.yaml` (atual: 1.1.0+1)

### 2. Configurações Firebase

- [ ] **Firebase iOS Config**:
  1. Acesse: https://console.firebase.google.com
  2. Selecione seu projeto
  3. iOS App → Adicionar app iOS
  4. Bundle ID: `com.seuapp.pratoseguro` (ou o que você configurar)
  5. Baixe `GoogleService-Info.plist`
  6. Coloque em: `ios/Runner/GoogleService-Info.plist`

### 3. Configurações Apple Developer

- [ ] **Conta Apple Developer**: 
  - Acesse: https://developer.apple.com
  - Certifique-se de que a conta está ativa
  
- [ ] **App ID**:
  1. Vá para: https://developer.apple.com/account/resources/identifiers/list
  2. Crie um novo App ID (se não existir)
  3. Bundle ID: `com.seuapp.pratoseguro`
  4. Habilite:
     - Push Notifications
     - Background Modes
     - Location Services

- [ ] **Certificados**:
  - Development Certificate
  - Distribution Certificate (para App Store)

- [ ] **Provisioning Profiles**:
  - Development Profile
  - App Store Profile

### 4. Configurações do Xcode Project

#### Verificar Bundle Identifier:

1. Abra `ios/Runner.xcworkspace` (se tiver Mac)
2. Ou edite `ios/Runner.xcodeproj/project.pbxproj`

Procure por `PRODUCT_BUNDLE_IDENTIFIER` e defina como:
```
com.seuapp.pratoseguro
```

Ou use um Bundle ID único, por exemplo:
```
com.pratoseguro.app
```

### 5. Dependências iOS

Verificar se todas as dependências têm suporte iOS:

- [x] `firebase_core` ✅
- [x] `firebase_auth` ✅
- [x] `firebase_storage` ✅
- [x] `cloud_firestore` ✅
- [x] `firebase_messaging` ✅
- [x] `google_sign_in` ✅
- [x] `geolocator` ✅
- [x] `permission_handler` ✅
- [x] `image_picker` ✅
- [x] `mapbox_maps_flutter` ⚠️ (verificar configuração)

### 6. Configuração Mapbox (se usar)

Se você usa Mapbox no iOS, precisa configurar:

1. Obter token Mapbox
2. Adicionar em `ios/Runner/Info.plist`:
```xml
<key>MGLMapboxAccessToken</key>
<string>SEU_TOKEN_AQUI</string>
```

### 7. Podfile (CocoaPods)

Verificar `ios/Podfile`:

```ruby
platform :ios, '12.0'

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
  end
end
```

## 🚀 Próximos Passos

Após completar o checklist:

1. **Configurar GitHub Secrets** (veja `CONFIGURAR_CERTIFICADOS_IOS.md`)
2. **Executar build** via GitHub Actions
3. **Testar no iPhone** via TestFlight

## ⚠️ Problemas Comuns

### Erro: "No such module 'Firebase'"
- **Solução**: Execute `cd ios && pod install`

### Erro: "Bundle identifier not found"
- **Solução**: Crie o App ID no Apple Developer Portal

### Erro: "Provisioning profile not found"
- **Solução**: Crie o provisioning profile no Developer Portal

### Erro: "GoogleService-Info.plist not found"
- **Solução**: Adicione o arquivo Firebase iOS em `ios/Runner/`

## 📞 Ajuda

Se tiver problemas:
1. Veja os logs do build no GitHub Actions
2. Verifique os documentos:
   - `COMPILAR_IOS_SEM_MAC.md`
   - `CONFIGURAR_CERTIFICADOS_IOS.md`
   - `QUICK_START_IOS.md`


