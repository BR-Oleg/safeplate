# 🍎 Compilação iOS - Guia Completo

Este é o guia principal para compilar o app **Prato Seguro** para iOS sem ter um Mac.

## 📚 Documentos Disponíveis

1. **COMPILAR_IOS_SEM_MAC.md** - Guia completo com todas as opções
2. **QUICK_START_IOS.md** - Início rápido (5 minutos)
3. **CONFIGURAR_CERTIFICADOS_IOS.md** - Como obter certificados
4. **PREPARAR_IOS.md** - Checklist de preparação

## 🚀 Opções Rápidas

### Opção 1: GitHub Actions (Recomendado - Grátis)
- ✅ Gratuito para repositórios públicos
- ✅ 2000 minutos/mês para privados
- ✅ Integração com GitHub
- 📖 Veja: `QUICK_START_IOS.md`

### Opção 2: Codemagic (Mais Fácil)
- ✅ Interface gráfica
- ✅ 500 minutos/mês grátis
- ✅ Gerenciamento automático de certificados
- 🔗 https://codemagic.io

### Opção 3: Mac na Nuvem
- ✅ Controle total
- ⚠️ Requer pagamento ($20-50/mês)
- 🔗 MacStadium, MacInCloud, AWS EC2 Mac

## ⚡ Quick Start (5 Minutos)

### 1. Preparar Repositório
```bash
git add .
git commit -m "Prepare for iOS build"
git push
```

### 2. Configurar Secrets no GitHub
Vá para: `Settings → Secrets and variables → Actions`

Adicione:
- `APPLE_ID`: seu-email@exemplo.com
- `APPLE_ID_PASSWORD`: xxxx-xxxx-xxxx-xxxx (App-Specific Password)
- `APPLE_TEAM_ID`: ABC123DEF4

### 3. Executar Build
1. Vá para: `Actions` no GitHub
2. Selecione: `Build iOS App`
3. Clique: `Run workflow`
4. Aguarde: ~15 minutos

### 4. Baixar e Instalar
- Baixe o IPA dos artifacts
- Instale via TestFlight ou distribuição direta

## ✅ Pré-requisitos

Antes de começar, você precisa:

1. **Conta Apple Developer** ($99/ano)
   - https://developer.apple.com/programs/

2. **App-Specific Password**
   - https://appleid.apple.com → Security
   - Generate app-specific password

3. **Team ID**
   - https://developer.apple.com/account
   - Membership → Team ID

4. **GoogleService-Info.plist** (Firebase iOS)
   - Firebase Console → iOS App
   - Baixe e coloque em `ios/Runner/`

## 📱 Configurações do Projeto

### ✅ Já Configurado:
- ✅ Nome do app: "Prato Seguro"
- ✅ Permissões: Localização, Câmera, Fotos
- ✅ Background Modes: Notificações push
- ✅ Workflow GitHub Actions criado

### ⚠️ Você Precisa Fazer:
- [ ] Configurar Bundle Identifier
- [ ] Adicionar GoogleService-Info.plist
- [ ] Configurar certificados (veja `CONFIGURAR_CERTIFICADOS_IOS.md`)
- [ ] Configurar Firebase iOS no Console

## 🔧 Configuração Bundle Identifier

O Bundle Identifier precisa ser único. Exemplos:

- `com.pratoseguro.app`
- `com.seuapp.pratoseguro`
- `br.com.pratoseguro.app`

**Onde configurar:**
1. Apple Developer Portal → App IDs
2. Criar novo App ID com esse Bundle ID
3. O GitHub Actions vai usar automaticamente

## 🔥 Configuração Firebase iOS

1. **Firebase Console**:
   - https://console.firebase.google.com
   - Selecione seu projeto
   - iOS App → Adicionar app iOS

2. **Bundle ID**:
   - Use o mesmo Bundle ID configurado acima

3. **Download**:
   - Baixe `GoogleService-Info.plist`
   - Coloque em: `ios/Runner/GoogleService-Info.plist`

4. **Adicionar ao Git** (ou usar secret):
   ```bash
   git add ios/Runner/GoogleService-Info.plist
   git commit -m "Add Firebase iOS config"
   ```

## 📦 Distribuição

### Opção 1: TestFlight (Recomendado)
- ✅ Fácil para testadores
- ✅ Cliente instala via app TestFlight
- ✅ Até 10.000 testadores

### Opção 2: App Store
- ✅ Distribuição pública
- ✅ Requer revisão da Apple
- ⏱️ Pode levar alguns dias

### Opção 3: Distribuição Direta
- ✅ Via AltStore/Sideloadly
- ⚠️ Requer reinstalação a cada 7 dias (free account)

## 🆘 Problemas Comuns

### Build falha?
- Verifique secrets no GitHub
- Verifique logs do build
- Verifique se tem conta Apple Developer ativa

### Certificados não funcionam?
- Use Codemagic (gerencia automaticamente)
- Ou veja `CONFIGURAR_CERTIFICADOS_IOS.md`

### App não instala?
- Verifique se o Bundle ID está correto
- Verifique provisioning profile
- Use TestFlight (mais confiável)

## 📞 Suporte

- **GitHub Issues**: Crie uma issue no repositório
- **Documentação Flutter**: https://docs.flutter.dev/deployment/ios
- **Codemagic Support**: https://codemagic.io/support

## 🎯 Próximos Passos

1. Leia: `QUICK_START_IOS.md` para começar rápido
2. Configure: Certificados (veja `CONFIGURAR_CERTIFICADOS_IOS.md`)
3. Execute: Build via GitHub Actions
4. Teste: Instale no iPhone via TestFlight

---

**Tempo estimado**: 5-10 minutos de configuração + 15 minutos de build = **20-25 minutos total** 🚀


