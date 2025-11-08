# 🔧 Problema: Git não encontrado - Soluções

## ❌ Erro que você recebeu

```
git : O termo 'git' não é reconhecido como nome de cmdlet...
Error: Unable to determine engine version...
```

**Causa**: O Git não está instalado ou não está no PATH do sistema.

## ✅ DUAS SOLUÇÕES

### Opção 1: Instalar Git (Recomendado) ⭐

**Por que instalar Git:**
- ✅ Flutter funciona melhor com Git
- ✅ Facilita usar FlutterFire CLI
- ✅ Útil para controle de versão
- ✅ Muitas ferramentas precisam de Git

**Como instalar:**
1. Baixe: https://git-scm.com/download/win
2. Durante instalação, marque:
   - ✅ **"Add Git to PATH"**
   - ✅ **"Use Git from the command line and also from 3rd-party software"**
3. Reinicie o terminal/PowerShell
4. Teste: `git --version`
5. Execute novamente: `dart pub global activate flutterfire_cli`

**Veja o guia completo**: `INSTALAR_GIT.md`

### Opção 2: Configurar Firebase Manualmente (Sem Git) 🔥

**Por que configurar manualmente:**
- ✅ Não precisa instalar Git
- ✅ Você tem controle total
- ✅ Funciona perfeitamente

**O que você precisa fazer:**
1. Criar projeto no Firebase Console
2. Baixar `google-services.json` e colocar em `android/app/`
3. Editar `android/app/build.gradle.kts` (já preparei o arquivo)
4. Criar `lib/firebase_options.dart` manualmente (ou usar google-services.json)

**Veja o guia completo**: `CONFIGURAR_FIREBASE_MANUAL.md`

## 🎯 O QUE JÁ ESTÁ PRONTO

### ✅ Configurado:
- ✅ Permissões Android (INTERNET, LOCALIZAÇÃO)
- ✅ Permissões iOS (NSLocationWhenInUseUsageDescription)
- ✅ `android/build.gradle.kts` preparado para Google Services
- ✅ `android/app/build.gradle.kts` preparado para Google Services
- ✅ Código Firebase implementado
- ✅ Mapbox token configurado

### ⚠️ Pendente:
- ⚠️ Instalar Git OU configurar Firebase manualmente
- ⚠️ Baixar `google-services.json` do Firebase Console
- ⚠️ Criar `lib/firebase_options.dart` (se usar FlutterFire CLI)

## 🚀 RECOMENDAÇÃO

**Para MVP e demonstração rápida**, recomendo:

**Configurar Firebase manualmente** (mais rápido, sem precisar instalar Git):
1. Acesse Firebase Console: https://console.firebase.google.com/
2. Crie projeto
3. Baixe `google-services.json`
4. Coloque em `android/app/google-services.json`
5. Teste: `flutter run`

O Firebase funcionará com apenas o `google-services.json`! 

Veja `CONFIGURAR_FIREBASE_MANUAL.md` para instruções detalhadas.

## 📝 RESUMO

- ❌ **Problema**: Git não instalado
- ✅ **Solução 1**: Instalar Git (`INSTALAR_GIT.md`)
- ✅ **Solução 2**: Configurar Firebase manualmente (`CONFIGURAR_FIREBASE_MANUAL.md`)
- 🎯 **Recomendação**: Configurar manualmente para MVP rápido

**Tudo pronto! Só falta o `google-services.json` do Firebase!** 🔥

