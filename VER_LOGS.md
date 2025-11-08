# 📊 VER LOGS DO APP EM TEMPO REAL

## 🚀 EXECUTANDO COM LOGS

O app está sendo executado com logs em tempo real!

### ✅ O QUE VOCÊ VERÁ NO TERMINAL

- ✅ **Logs do Flutter** (debugPrint, print, etc.)
- ✅ **Logs do Firebase** (inicialização, autenticação)
- ✅ **Logs do Mapbox** (configuração, erros)
- ✅ **Logs do sistema** (Android)
- ✅ **Erros em tempo real** (se houver)

### 💡 COMANDOS ÚTEIS DURANTE EXECUÇÃO

Quando o app estiver rodando, você pode:

- **`r`** - Hot Reload (recarregar mudanças rapidamente)
- **`R`** - Hot Restart (reiniciar o app completamente)
- **`q`** - Sair/Fechar
- **`h`** - Ver ajuda
- **`v`** - Alternar verbose (mais detalhes)

### 📊 TIPOS DE LOGS QUE VOCÊ VERÁ

#### Logs do Flutter:
```
I/flutter: ✅ Firebase inicializado com sucesso!
I/flutter: Erro no login com Google: ...
```

#### Logs do Android:
```
D/AndroidRuntime: ...
W/System: ...
```

#### Logs do Firebase:
```
I/FirebaseAuth: ...
```

#### Logs do Mapbox:
```
I/Mapbox: ...
```

### 🔍 INTERPRETANDO OS LOGS

- **`I/flutter:`** - Logs do Flutter (seu código)
- **`D/`** - Debug logs
- **`W/`** - Warnings (avisos)
- **`E/`** - Errors (erros)
- **`I/`** - Info logs

### ⚠️ SOBRE O ERRO DO GOOGLE SIGN-IN

Se você ver:
```
I/flutter: Erro no login com Google: PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10: , null, null)
```

**Isso é normal!** Acontece porque o SHA-1 não está configurado no Firebase Console ainda.

**Para resolver:**
1. Adicione o SHA-1 no Firebase Console (veja `ADICIONAR_SHA1_FIREBASE.md`)
2. Aguarde alguns minutos
3. Teste novamente

### 📱 O QUE ESTÁ ACONTECENDO

O app está:
- ✅ Compilando
- ✅ Instalando no telefone
- ✅ Abrindo automaticamente
- ✅ Mostrando logs em tempo real no terminal

### ✅ PRONTO!

Agora você pode ver todos os logs em tempo real no terminal!

---

**O app está rodando com logs!** 📊

