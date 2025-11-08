# ⚡ Instruções Rápidas - Configurar Firebase

## 🔥 Problema: Git não encontrado

**Solução mais rápida**: Configure Firebase **MANUALMENTE** (sem precisar instalar Git)

## 🚀 Passo a Passo Rápido (5 minutos)

### 1. Criar Projeto no Firebase

1. Acesse: https://console.firebase.google.com/
2. Clique em **"Adicionar projeto"**
3. Nome: `SafePlate`
4. Siga o assistente (pode desativar Google Analytics se quiser)

### 2. Adicionar App Android

1. No Firebase Console, clique no ícone do Android
2. **Package name**: `com.safeplate.safeplate`
3. **Nome do app**: `SafePlate`
4. Clique em **"Registrar app"**
5. **BAIXE** o arquivo `google-services.json`
6. **COLOQUE** o arquivo em: `android/app/google-services.json`

### 3. Ativar Google Sign-In

1. No Firebase Console: **Authentication** > **Sign-in method**
2. Clique em **Google** e **Ative**
3. Configure email de suporte
4. **Salve**

### 4. Testar!

```bash
flutter run
```

O Firebase já está configurado! O app funcionará com o `google-services.json`.

## ✅ O QUE JÁ ESTÁ PRONTO

- ✅ Permissões Android configuradas
- ✅ Permissões iOS configuradas  
- ✅ `android/app/build.gradle.kts` preparado para Google Services
- ✅ Código Firebase implementado
- ✅ Mapbox token configurado

## 📝 IMPORTANTE

**Você NÃO precisa:**
- ❌ Instalar Git agora
- ❌ Executar `flutterfire configure`
- ❌ Criar `firebase_options.dart` manualmente

**O Firebase funcionará apenas com o `google-services.json`!**

O Flutter Firebase SDK detecta automaticamente o `google-services.json` e configura tudo.

## 🎯 PRÓXIMO PASSO

1. Baixe `google-services.json` do Firebase Console
2. Coloque em `android/app/google-services.json`
3. Execute: `flutter run`

**Pronto! Firebase configurado!** 🎉

## 🔍 OPCIONAL (se quiser SHA-1 para Google Sign-In)

Se quiser usar Google Sign-In no Android, adicione SHA-1:

1. Execute:
   ```powershell
   cd android
   .\gradlew signingReport
   ```

2. Copie o SHA-1 e adicione no Firebase Console:
   - Firebase Console > **Project Settings** > **Your apps** > **Android app**
   - Adicione o SHA-1 fingerprint

Isso é **opcional** - o login com email/senha funciona sem isso!

---

**Resumo**: Baixe `google-services.json`, coloque em `android/app/`, pronto! 🚀

