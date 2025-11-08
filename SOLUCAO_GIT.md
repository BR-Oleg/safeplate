# 🚨 Problema: Git não encontrado

O erro que você recebeu indica que o **Git não está instalado** ou não está no **PATH** do sistema.

## ❌ Erro Recebido

```
git : O termo 'git' não é reconhecido como nome de cmdlet...
Error: Unable to determine engine version...
```

## ✅ Solução Rápida

### Opção 1: Instalar Git (Recomendado)

1. **Baixe Git**: https://git-scm.com/download/win
2. **Durante instalação**, marque:
   - ✅ **"Add Git to PATH"**
   - ✅ **"Use Git from the command line and also from 3rd-party software"**
3. **Reinicie o terminal/PowerShell**
4. **Teste**: `git --version`
5. **Execute novamente**: `dart pub global activate flutterfire_cli`

### Opção 2: Configurar Firebase Manualmente (Sem Git)

Se você não quer instalar Git agora, pode configurar o Firebase **manualmente**:

**Veja o guia completo**: `CONFIGURAR_FIREBASE_MANUAL.md`

Resumo rápido:
1. Crie projeto no Firebase Console
2. Baixe `google-services.json` e coloque em `android/app/`
3. Edite `android/app/build.gradle.kts` (adicionar plugin Google Services)
4. Crie `lib/firebase_options.dart` manualmente

## 🔍 Por que o Git é necessário?

O Flutter usa o Git para:
- Verificar versões do engine
- Gerenciar dependências
- Funcionalidades internas

O FlutterFire CLI também usa Git para algumas operações.

## 💡 Recomendação

**Para desenvolvimento Flutter**, é recomendado instalar Git porque:
- ✅ Flutter funciona melhor com Git instalado
- ✅ Facilita o uso de ferramentas como FlutterFire CLI
- ✅ Útil para controle de versão (Git)
- ✅ Muitas ferramentas do ecossistema Flutter precisam de Git

## ⚡ Alternativa: Instalar via Winget (Windows 10/11)

Se você tem o Winget instalado:

```powershell
winget install --id Git.Git -e --source winget
```

Depois reinicie o terminal e teste: `git --version`

## 📝 Depois de Instalar Git

1. Feche e reabra o terminal/PowerShell
2. Execute:
   ```powershell
   git --version
   ```
   Deve mostrar: `git version 2.x.x`
3. Execute novamente:
   ```powershell
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

## 🎯 Escolha sua Opção

- **Opção A**: Instalar Git (recomendado) → Veja `INSTALAR_GIT.md`
- **Opção B**: Configurar Firebase manualmente (sem Git) → Veja `CONFIGURAR_FIREBASE_MANUAL.md`

Ambas as opções funcionam perfeitamente! A diferença é que com Git você usa o CLI automático, sem Git você configura manualmente.

