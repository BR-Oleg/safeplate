# ⚡ Quick Start: Compilar iOS Agora

Guia rápido para começar a compilar seu app iOS em 5 minutos.

## 🚀 Passo a Passo Rápido

### 1. Configurar Repositório GitHub (2 min)

```bash
# Se ainda não tem repositório
git init
git add .
git commit -m "Prepare for iOS build"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/apkpratoseguro.git
git push -u origin main
```

### 2. Configurar Secrets no GitHub (2 min)

1. Vá para: https://github.com/SEU_USUARIO/apkpratoseguro/settings/secrets/actions
2. Clique em "New repository secret"
3. Adicione:

**APPLE_ID**
```
seu-email@exemplo.com
```

**APPLE_ID_PASSWORD**
```
xxxx-xxxx-xxxx-xxxx
```
(Obtenha em: https://appleid.apple.com → Security → App-Specific Passwords)

**APPLE_TEAM_ID**
```
ABC123DEF4
```
(Obtenha em: https://developer.apple.com/account → Membership)

### 3. Executar Build (1 min)

1. Vá para: https://github.com/SEU_USUARIO/apkpratoseguro/actions
2. Clique em "Build iOS App"
3. Clique em "Run workflow"
4. Aguarde o build completar (~10-15 minutos)

### 4. Baixar IPA

1. Após o build completar, clique no workflow
2. Vá para "Artifacts"
3. Baixe "ios-build-XXX"
4. Extraia o arquivo .ipa

### 5. Instalar no iPhone

#### Opção A: Via TestFlight (Recomendado)

1. Faça upload do .ipa para App Store Connect
2. Configure TestFlight
3. Envie convite para seu cliente
4. Cliente instala via app TestFlight

#### Opção B: Instalação Direta

1. Use **AltStore** ou **Sideloadly**
2. Conecte iPhone ao computador
3. Instale o .ipa

## 🎯 Usando Codemagic (Ainda Mais Fácil)

Se GitHub Actions for complicado, use Codemagic:

1. Acesse: https://codemagic.io
2. Conecte com GitHub
3. Selecione seu repositório
4. Clique em "Start new build"
5. Escolha "iOS"
6. Codemagic faz tudo automaticamente!

## ⚠️ Problemas?

### Build falha?
- Verifique se os secrets estão corretos
- Verifique se tem conta Apple Developer ativa
- Veja os logs do build no GitHub Actions

### Não consigo obter certificados?
- Use Codemagic (gerencia automaticamente)
- Ou use AppCircle (também automático)

### Cliente não consegue instalar?
- Use TestFlight (mais confiável)
- Ou distribua via App Store

## 📞 Precisa de Ajuda?

- **GitHub Issues**: Crie uma issue no repositório
- **Codemagic Support**: https://codemagic.io/support
- **Flutter Docs**: https://docs.flutter.dev/deployment/ios

---

**Tempo total**: ~5 minutos de configuração + ~15 minutos de build = **20 minutos** para ter seu app iOS compilado! 🎉


