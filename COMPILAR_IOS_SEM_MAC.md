# 🍎 Guia Completo: Compilar App Flutter para iOS Sem Mac

Este guia detalha todas as opções disponíveis para compilar seu app Flutter para iOS sem ter um Mac físico.

## 📋 Pré-requisitos

Antes de começar, você precisa ter:
- ✅ Conta de desenvolvedor Apple (Apple Developer Account)
  - **Individual**: $99/ano
  - **Enterprise**: $299/ano (para empresas)
- ✅ Certificados de desenvolvimento configurados (você pode criar usando um Mac temporário ou serviços online)
- ✅ Repositório Git (GitHub, GitLab, Bitbucket) - necessário para a maioria das soluções

---

## 🚀 Opção 1: GitHub Actions (RECOMENDADO - GRATUITO)

**Vantagens:**
- ✅ Grátis para repositórios públicos
- ✅ 2000 minutos/mês gratuitos para repositórios privados
- ✅ Integração direta com GitHub
- ✅ Fácil configuração

**Desvantagens:**
- ⚠️ Requer repositório no GitHub
- ⚠️ Limite de minutos gratuitos (pode não ser suficiente para builds frequentes)

### Passo a Passo:

#### 1. Configurar Repositório GitHub
```bash
# Se ainda não tem repositório Git
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/SEU_USUARIO/apkpratoseguro.git
git push -u origin main
```

#### 2. Criar Secrets no GitHub

1. Vá para seu repositório no GitHub
2. Settings → Secrets and variables → Actions
3. Adicione os seguintes secrets:

**Obrigatórios:**
- `APPLE_ID`: Seu email da conta Apple Developer
- `APPLE_ID_PASSWORD`: Senha da sua conta (pode usar App-Specific Password)
- `APPLE_TEAM_ID`: ID da sua equipe (encontre em https://developer.apple.com/account)
- `CERTIFICATES_BASE64`: Certificado de desenvolvimento em base64
- `P12_PASSWORD`: Senha do certificado .p12
- `PROVISIONING_PROFILE_BASE64`: Perfil de provisionamento em base64

**Opcionais (para Firebase):**
- `FIREBASE_IOS_CONFIG`: Conteúdo do arquivo `GoogleService-Info.plist`

#### 3. Criar Arquivo de Workflow

Crie o arquivo `.github/workflows/ios-build.yml`:

```yaml
name: Build iOS

on:
  workflow_dispatch:
  push:
    branches:
      - main
    tags:
      - 'v*'

jobs:
  build-ios:
    name: Build iOS App
    runs-on: macos-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Setup Xcode
        uses: maxim-lobanov/setup-xcode@v1
        with:
          xcode-version: latest-stable

      - name: Setup certificates
        env:
          BUILD_CERTIFICATE_BASE64: ${{ secrets.CERTIFICATES_BASE64 }}
          P12_PASSWORD: ${{ secrets.P12_PASSWORD }}
          KEYCHAIN_PASSWORD: ${{ secrets.KEYCHAIN_PASSWORD }}
        run: |
          # Criar keychain
          security create-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
          security default-keychain -s build.keychain
          security unlock-keychain -p "$KEYCHAIN_PASSWORD" build.keychain
          security set-keychain-settings -t 3600 -u build.keychain

          # Decodificar certificado
          echo "$BUILD_CERTIFICATE_BASE64" | base64 --decode > certificate.p12
          
          # Importar certificado
          security import certificate.p12 -k build.keychain -P "$P12_PASSWORD" -T /usr/bin/codesign
          security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k "$KEYCHAIN_PASSWORD" build.keychain

      - name: Setup provisioning profile
        env:
          PROVISIONING_PROFILE_BASE64: ${{ secrets.PROVISIONING_PROFILE_BASE64 }}
        run: |
          mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
          echo "$PROVISIONING_PROFILE_BASE64" | base64 --decode > ~/Library/MobileDevice/Provisioning\ Profiles/profile.mobileprovision

      - name: Get Flutter dependencies
        run: flutter pub get

      - name: Build iOS
        run: |
          cd ios
          pod install
          cd ..
          flutter build ios --release --no-codesign

      - name: Archive iOS
        run: |
          xcodebuild -workspace ios/Runner.xcworkspace \
            -scheme Runner \
            -configuration Release \
            -archivePath build/Runner.xcarchive \
            archive \
            CODE_SIGN_IDENTITY="" \
            CODE_SIGNING_REQUIRED=NO

      - name: Export IPA
        run: |
          xcodebuild -exportArchive \
            -archivePath build/Runner.xcarchive \
            -exportPath build/ios \
            -exportOptionsPlist ios/ExportOptions.plist

      - name: Upload IPA
        uses: actions/upload-artifact@v3
        with:
          name: ios-ipa
          path: build/ios/*.ipa
```

#### 4. Criar ExportOptions.plist

Crie o arquivo `ios/ExportOptions.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>SEU_TEAM_ID</string>
    <key>compileBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <false/>
</dict>
</plist>
```

---

## 🎯 Opção 2: Codemagic (RECOMENDADO - FÁCIL)

**Vantagens:**
- ✅ Interface gráfica muito fácil
- ✅ 500 minutos/mês gratuitos
- ✅ Suporte excelente para Flutter
- ✅ Não requer conhecimento avançado

**Desvantagens:**
- ⚠️ Limite de minutos gratuitos
- ⚠️ Pode ser mais lento que outras opções

### Passo a Passo:

1. **Acesse**: https://codemagic.io
2. **Crie uma conta** (pode usar GitHub)
3. **Adicione seu repositório**
4. **Configure o build**:
   - Selecione "iOS" como plataforma
   - Codemagic detecta automaticamente Flutter
   - Configure certificados e provisioning profiles
5. **Execute o build**

**Documentação**: https://docs.codemagic.io/getting-started/building-a-flutter-app/

---

## 🏗️ Opção 3: MacStadium / MacInCloud (MAC NA NUVEM)

**Vantagens:**
- ✅ Acesso completo a um Mac
- ✅ Pode usar Xcode diretamente
- ✅ Mais controle sobre o processo

**Desvantagens:**
- ⚠️ Requer pagamento mensal ($20-50/mês)
- ⚠️ Pode ser mais lento (depende da conexão)

### Passo a Passo:

1. **Assine um serviço**:
   - MacStadium: https://www.macstadium.com
   - MacInCloud: https://www.macincloud.com
   - AWS EC2 Mac Instances: https://aws.amazon.com/ec2/instance-types/mac/

2. **Configure o Mac remoto**:
   - Instale Xcode
   - Instale Flutter
   - Configure certificados

3. **Conecte via VNC/SSH** e compile normalmente

---

## 🔧 Opção 4: Bitrise (CI/CD PROFISSIONAL)

**Vantagens:**
- ✅ 200 minutos/mês gratuitos
- ✅ Interface muito intuitiva
- ✅ Muitos templates prontos

**Desvantagens:**
- ⚠️ Limite de minutos

### Passo a Passo:

1. **Acesse**: https://www.bitrise.io
2. **Conecte seu repositório**
3. **Selecione template Flutter**
4. **Configure certificados**
5. **Execute build**

---

## 📱 Opção 5: TestFlight (PARA TESTES)

**Vantagens:**
- ✅ Fácil distribuição para testadores
- ✅ Não precisa de Mac para instalar
- ✅ Cliente pode instalar direto no iPhone

**Desvantagens:**
- ⚠️ Ainda precisa compilar o app (use uma das opções acima)

### Passo a Passo:

1. **Compile o app** usando uma das opções acima
2. **Faça upload para App Store Connect**:
   - Use `xcrun altool` ou Transporter app
   - Ou faça upload via Xcode
3. **Configure TestFlight**:
   - Vá para App Store Connect
   - Adicione testadores
   - Envie convites

---

## 🔐 Como Obter Certificados Sem Mac

### Método 1: Usar App Store Connect API

1. **Gere uma chave API**:
   - Vá para https://appstoreconnect.apple.com
   - Users and Access → Keys
   - Crie uma nova chave
   - Baixe o arquivo .p8

2. **Use ferramentas online**:
   - **App Store Connect API**: Para automatizar criação de certificados
   - **Fastlane Match**: Para gerenciar certificados (requer Mac temporário)

### Método 2: Usar Serviço Online

- **AppCircle**: https://appcircle.io (pode ajudar com certificados)
- **EAS Build**: https://expo.dev (se usar Expo, pode gerar certificados automaticamente)

### Método 3: Emprestar/Alugar Mac Temporariamente

1. **Empreste um Mac** de um amigo/colegas
2. **Configure certificados uma vez**:
   ```bash
   # Instalar Fastlane
   sudo gem install fastlane
   
   # Configurar Match
   fastlane match development
   fastlane match appstore
   ```

3. **Exporte certificados** e use nas soluções acima

---

## 📝 Configurações Necessárias no Projeto

### 1. Verificar/Criar Pasta iOS

```bash
# Se não existe pasta ios, crie:
flutter create --platforms=ios .
```

### 2. Configurar Info.plist

Verifique/edite `ios/Runner/Info.plist`:

```xml
<key>CFBundleDisplayName</key>
<string>Prato Seguro</string>
<key>CFBundleIdentifier</key>
<string>com.seuapp.pratoseguro</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>CFBundleShortVersionString</key>
<string>1.1.0</string>
```

### 3. Configurar Firebase para iOS

1. **Baixe `GoogleService-Info.plist`** do Firebase Console
2. **Adicione ao projeto**: `ios/Runner/GoogleService-Info.plist`
3. **Adicione ao Git** (ou use secret no CI/CD)

### 4. Configurar Permissões

No `ios/Runner/Info.plist`, adicione:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Precisamos da sua localização para mostrar estabelecimentos próximos</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>Precisamos da sua localização para mostrar estabelecimentos próximos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Precisamos acessar suas fotos para adicionar imagens às avaliações</string>
<key>NSCameraUsageDescription</key>
<string>Precisamos acessar a câmera para tirar fotos das avaliações</string>
```

---

## 🚀 Quick Start (GitHub Actions)

Se você quer começar rapidamente com GitHub Actions:

### 1. Crie o workflow básico:

```bash
mkdir -p .github/workflows
```

Crie `.github/workflows/ios.yml` (versão simplificada):

```yaml
name: iOS Build

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      - run: flutter pub get
      - run: flutter build ios --release --no-codesign
      - uses: actions/upload-artifact@v3
        with:
          name: ios-build
          path: build/ios/iphoneos/Runner.app
```

### 2. Commit e push:

```bash
git add .github/workflows/ios.yml
git commit -m "Add iOS build workflow"
git push
```

### 3. Execute no GitHub:

- Vá para Actions no GitHub
- Selecione o workflow
- Clique em "Run workflow"

---

## 📞 Suporte

Se tiver problemas:

1. **GitHub Actions**: https://docs.github.com/en/actions
2. **Codemagic**: https://docs.codemagic.io
3. **Flutter iOS**: https://docs.flutter.dev/deployment/ios

---

## ✅ Checklist Final

Antes de compilar, verifique:

- [ ] Conta Apple Developer ativa
- [ ] Certificados configurados
- [ ] Provisioning profiles criados
- [ ] `GoogleService-Info.plist` no projeto iOS
- [ ] Permissões configuradas no Info.plist
- [ ] Versão atualizada no `pubspec.yaml`
- [ ] Repositório Git configurado
- [ ] Secrets configurados (se usando CI/CD)

---

**Recomendação**: Comece com **GitHub Actions** (gratuito) ou **Codemagic** (mais fácil). Ambos têm boa documentação e comunidade ativa.


