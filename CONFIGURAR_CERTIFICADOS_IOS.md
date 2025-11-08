# 🔐 Como Configurar Certificados iOS Sem Mac

Este guia explica como obter os certificados necessários para compilar o app iOS sem ter um Mac.

## 📋 O que você precisa

1. **Conta Apple Developer** ($99/ano)
   - Acesse: https://developer.apple.com/programs/
   - Se inscreva como desenvolvedor individual ou empresa

2. **App Store Connect API Key** (opcional, mas recomendado)
   - Vá para: https://appstoreconnect.apple.com
   - Users and Access → Keys
   - Crie uma nova chave
   - Baixe o arquivo `.p8`

## 🎯 Método 1: Usar GitHub Actions com Auto-Signing (MAIS FÁCIL)

O GitHub Actions pode criar certificados automaticamente usando sua conta Apple Developer.

### Passo a Passo:

#### 1. Obter App-Specific Password

1. Acesse: https://appleid.apple.com
2. Security → App-Specific Passwords
3. Clique em "Generate an app-specific password"
4. Nome: "GitHub Actions"
5. Copie a senha gerada

#### 2. Obter Team ID

1. Acesse: https://developer.apple.com/account
2. Membership → Team ID
3. Copie o Team ID (formato: `ABC123DEF4`)

#### 3. Configurar Secrets no GitHub

Vá para: Settings → Secrets and variables → Actions

Adicione:

```
APPLE_ID: seu-email@exemplo.com
APPLE_ID_PASSWORD: xxxx-xxxx-xxxx-xxxx (App-Specific Password)
APPLE_TEAM_ID: ABC123DEF4
```

#### 4. Atualizar Workflow

O workflow já está configurado para usar auto-signing. Ele irá:
- Criar certificados automaticamente
- Criar provisioning profiles
- Assinar o app

## 🔑 Método 2: Criar Certificados Manualmente (Com Mac Temporário)

Se você tiver acesso a um Mac (emprestado ou alugado), pode criar os certificados manualmente.

### Passo a Passo:

#### 1. No Mac, instale Xcode e Flutter

```bash
# Instalar Xcode (via App Store)
# Instalar Flutter
flutter doctor
```

#### 2. Instalar Fastlane

```bash
sudo gem install fastlane
```

#### 3. Configurar Match (Gerenciador de Certificados)

```bash
cd ios
fastlane match init
# Escolha: git (recomendado)
```

#### 4. Criar Certificados

```bash
# Development
fastlane match development

# App Store (para distribuição)
fastlane match appstore
```

#### 5. Exportar Certificados

Os certificados serão salvos em:
- `~/.fastlane/match/development/`
- `~/.fastlane/match/appstore/`

Você precisará de:
- `certificates.p12` (certificado)
- `profiles/` (provisioning profiles)

#### 6. Converter para Base64 (para GitHub Secrets)

```bash
# No Mac
base64 -i certificates.p12 | pbcopy
# Cole no GitHub Secret: CERTIFICATES_BASE64

base64 -i profiles/*.mobileprovision | pbcopy
# Cole no GitHub Secret: PROVISIONING_PROFILE_BASE64
```

## 🌐 Método 3: Usar Serviços Online

### Opção A: AppCircle (Automático)

1. Acesse: https://appcircle.io
2. Conecte sua conta Apple Developer
3. AppCircle gerencia certificados automaticamente
4. Não precisa fazer nada manual

### Opção B: Codemagic (Automático)

1. Acesse: https://codemagic.io
2. Conecte sua conta Apple Developer
3. Codemagic gerencia certificados automaticamente

## 📱 Método 4: Usar TestFlight Sem Certificados (Limitações)

Você pode usar serviços como:
- **EAS Build** (Expo): Se migrar para Expo, pode gerar certificados automaticamente
- **AppCircle**: Gerencia tudo automaticamente

## 🔍 Verificar Certificados Existentes

Se você já tem certificados:

1. **Verificar no Keychain** (Mac):
   ```bash
   security find-identity -v -p codesigning
   ```

2. **Verificar no Developer Portal**:
   - https://developer.apple.com/account/resources/certificates/list
   - Veja certificados existentes

3. **Verificar Provisioning Profiles**:
   - https://developer.apple.com/account/resources/profiles/list
   - Veja profiles existentes

## ⚠️ Problemas Comuns

### Erro: "No signing certificate found"
- **Solução**: Configure os secrets no GitHub ou use auto-signing

### Erro: "Provisioning profile not found"
- **Solução**: Crie um provisioning profile no Developer Portal
- Ou use auto-signing no GitHub Actions

### Erro: "Team ID not found"
- **Solução**: Verifique se o Team ID está correto
- Encontre em: https://developer.apple.com/account

## ✅ Checklist

Antes de compilar, verifique:

- [ ] Conta Apple Developer ativa
- [ ] Team ID obtido
- [ ] App-Specific Password criado
- [ ] Secrets configurados no GitHub (se usando GitHub Actions)
- [ ] Bundle ID configurado no projeto
- [ ] Certificados criados (se usando método manual)

## 🚀 Próximos Passos

Após configurar certificados:

1. **Compilar o app** usando GitHub Actions
2. **Baixar o IPA** dos artifacts
3. **Instalar no iPhone** via TestFlight ou distribuição direta

## 📞 Ajuda Adicional

- **Apple Developer Support**: https://developer.apple.com/support/
- **Fastlane Docs**: https://docs.fastlane.tools/
- **GitHub Actions**: https://docs.github.com/en/actions

---

**Recomendação**: Use o **Método 1** (GitHub Actions com auto-signing) - é o mais simples e não requer Mac!


