# 🔍 COMO VERIFICAR OS LOGS DO APP

## 📱 Método 1: Android Studio (Recomendado)

### Passos:

1. **Abra o Android Studio**
2. **Abra o projeto Flutter**
3. **Conecte seu dispositivo** ou inicie o emulador
4. **Execute o app** (botão Run ou Shift+F10)
5. **Abra a aba "Logcat"** (parte inferior da tela)
6. **Filtre os logs:**

### Filtros Úteis:

```
Firebase
Firestore
✅
❌
⚠️
```

### O que procurar:

**✅ Mensagens de SUCESSO:**
```
✅ Estabelecimento salvo com ID: abc123
✅ Dados do usuário salvos: xyz789
✅ Avaliação salva com ID: def456
✅ Imagem do estabelecimento enviada: https://...
```

**❌ Mensagens de ERRO:**
```
❌ Erro ao salvar estabelecimento: ...
❌ Erro ao salvar dados do usuário: ...
⚠️ Erro ao carregar estabelecimentos do Firestore: ...
⚠️ Timeout ao salvar dados no Firestore: ...
```

---

## 💻 Método 2: Terminal (Flutter CLI)

### Passos:

1. **Abra o terminal**
2. **Navegue até a pasta do projeto:**
   ```bash
   cd C:\apkpratoseguro
   ```
3. **Execute o app:**
   ```bash
   flutter run
   ```
4. **Os logs aparecerão no terminal**

### Filtros no Terminal:

Se quiser filtrar apenas mensagens do Firebase:
```bash
flutter run | grep -i "firebase\|firestore\|✅\|❌\|⚠️"
```

---

## 📋 O QUE CADA MENSAGEM SIGNIFICA

### ✅ Mensagens de Sucesso:

| Mensagem | Significado |
|----------|-------------|
| `✅ Estabelecimento salvo com ID: ...` | Estabelecimento foi salvo no Firestore com sucesso |
| `✅ Dados do usuário salvos: ...` | Dados do usuário foram salvos no Firestore |
| `✅ Avaliação salva com ID: ...` | Avaliação foi salva no Firestore com sucesso |
| `✅ Imagem do estabelecimento enviada: ...` | Imagem foi enviada para Firebase Storage |

### ❌ Mensagens de Erro:

| Mensagem | Significado | Solução |
|----------|-------------|---------|
| `❌ Erro ao salvar estabelecimento: PERMISSION_DENIED` | Sem permissão para salvar | Configure as regras do Firestore |
| `❌ Erro ao salvar estabelecimento: NOT_FOUND` | Firestore não encontrado | Verifique se o Firestore Database existe |
| `⚠️ Timeout ao salvar dados no Firestore` | Timeout na conexão | Verifique sua internet ou aumente o timeout |
| `⚠️ Erro ao carregar estabelecimentos do Firestore: ...` | Erro ao carregar dados | Verifique conexão e permissões |

---

## 🔍 EXEMPLO DE LOGS CORRETOS

### Quando está funcionando:

```
I/flutter: ✅ Estabelecimento salvo com ID: abc123xyz
I/flutter: ✅ Dados do usuário salvos: user123
I/flutter: ✅ Avaliação salva com ID: review456
I/flutter: 📦 Carregados 5 estabelecimentos do Firestore
I/flutter:    IDs do Firestore: Restaurante A(abc123), Restaurante B(def456), ...
```

### Quando NÃO está funcionando:

```
I/flutter: ❌ Erro ao salvar estabelecimento: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
I/flutter: ⚠️ Erro ao carregar estabelecimentos do Firestore: [cloud_firestore/unavailable] The service is currently unavailable.
I/flutter: ⚠️ Timeout ao salvar dados no Firestore (continuando login)
```

---

## 🚨 ERROS COMUNS E SOLUÇÕES

### Erro 1: `PERMISSION_DENIED`

**Log:**
```
❌ Erro ao salvar estabelecimento: [cloud_firestore/permission-denied] The caller does not have permission to execute the specified operation.
```

**Solução:**
1. Acesse: https://console.firebase.google.com/project/safeplate-a14e9/firestore/rules
2. Configure as regras (veja `TESTE_FIRESTORE.md`)
3. Clique em "Publicar"

### Erro 2: `NOT_FOUND`

**Log:**
```
❌ Erro ao salvar estabelecimento: [cloud_firestore/not-found] Document not found
```

**Solução:**
- Isso é normal para novos documentos
- O Firestore cria o documento automaticamente
- Tente novamente

### Erro 3: `UNAVAILABLE`

**Log:**
```
⚠️ Erro ao carregar estabelecimentos do Firestore: [cloud_firestore/unavailable] The service is currently unavailable.
```

**Solução:**
1. Verifique sua conexão com a internet
2. Verifique se o Firestore API está habilitado
3. Aguarde alguns minutos e tente novamente

### Erro 4: `TIMEOUT`

**Log:**
```
⚠️ Timeout ao salvar dados no Firestore (continuando login)
```

**Solução:**
1. Verifique sua conexão com a internet
2. O app continua funcionando (usa dados locais)
3. Os dados serão salvos quando a conexão melhorar

---

## 📝 CHECKLIST DE VERIFICAÇÃO

Após executar o app e fazer as ações, verifique:

- [ ] Não há erros `PERMISSION_DENIED` nos logs
- [ ] Não há erros `NOT_FOUND` persistentes
- [ ] Não há erros `UNAVAILABLE` constantes
- [ ] Há mensagens de sucesso (`✅`) quando você cria dados
- [ ] Os dados aparecem no Firebase Console

---

## 💡 DICAS

- **Sempre verifique os logs após criar dados pelo app**
- **Se houver erros, copie a mensagem completa**
- **Os logs mostram exatamente o que está acontecendo**
- **Use os filtros para encontrar mensagens específicas**

---

**Agora você pode verificar se o Firestore está funcionando!** 🔍


