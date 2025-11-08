# 🧪 TESTE DO FIRESTORE - GUIA COMPLETO

## ✅ Banco de Dados Criado!

Agora vamos testar se o app está salvando os dados corretamente no Firestore.

---

## 📋 CHECKLIST DE TESTE

### 1. **Teste: Criar Estabelecimento**

**Passos:**
1. Abra o app
2. Faça login como **empresa** (ou crie uma conta empresa)
3. Vá para **"Cadastrar Estabelecimento"**
4. Preencha todos os campos:
   - Nome do estabelecimento
   - Categoria
   - CEP (para preencher endereço automaticamente)
   - Número do endereço
   - Horário de funcionamento
   - Dias da semana
   - Opções dietéticas
   - Foto (opcional)
5. Clique em **"Salvar"** ou **"Cadastrar"**
6. Aguarde a mensagem de sucesso

**Verificação:**
1. Abra o Firebase Console: https://console.firebase.google.com/project/safeplate-a14e9/firestore
2. Vá em **"Dados"** (aba superior)
3. Procure pela coleção **`establishments`**
4. Clique na coleção
5. Você deve ver o estabelecimento que acabou de criar!

**✅ Se aparecer:**
- O Firestore está funcionando! ✅
- Os dados estão sendo salvos na nuvem! ✅

**❌ Se NÃO aparecer:**
- Verifique os logs do app (veja abaixo)
- Pode haver um erro de permissão
- Pode haver um erro de configuração

---

### 2. **Teste: Fazer Login**

**Passos:**
1. Faça logout do app (se estiver logado)
2. Faça login novamente com **Google Sign In**
3. Complete o login

**Verificação:**
1. Abra o Firebase Console
2. Vá em **"Dados"**
3. Procure pela coleção **`users`**
4. Clique na coleção
5. Você deve ver seu usuário!

**✅ Se aparecer:**
- O Firestore está salvando usuários! ✅

**❌ Se NÃO aparecer:**
- O usuário pode estar sendo salvo apenas localmente
- Verifique os logs do app

---

### 3. **Teste: Criar Avaliação**

**Passos:**
1. Abra um estabelecimento qualquer
2. Role até a seção de **"Avaliações"**
3. Clique em **"Deixar sua avaliação"** ou similar
4. Preencha:
   - Nota (estrelas)
   - Comentário
   - Opções dietéticas (se aplicável)
5. Clique em **"Enviar"** ou **"Salvar"**

**Verificação:**
1. Abra o Firebase Console
2. Vá em **"Dados"**
3. Procure pela coleção **`reviews`**
4. Clique na coleção
5. Você deve ver a avaliação que acabou de criar!

**✅ Se aparecer:**
- O Firestore está salvando avaliações! ✅

**❌ Se NÃO aparecer:**
- Verifique os logs do app
- Pode haver um erro de permissão

---

## 🔍 COMO VERIFICAR OS LOGS DO APP

### No Android Studio:

1. Abra o Android Studio
2. Conecte seu dispositivo ou inicie o emulador
3. Execute o app
4. Abra a aba **"Logcat"** (parte inferior)
5. Filtre por: `Firebase` ou `Firestore`
6. Procure por mensagens como:
   - ✅ `✅ Estabelecimento salvo com ID: ...`
   - ✅ `✅ Dados do usuário salvos: ...`
   - ✅ `✅ Avaliação salva com ID: ...`
   - ❌ `❌ Erro ao salvar estabelecimento: ...`
   - ❌ `⚠️ Erro ao salvar dados no Firestore: ...`

### No Terminal (Flutter):

```bash
flutter run
```

Os logs aparecerão no terminal. Procure por:
- ✅ Mensagens de sucesso (com ✅)
- ❌ Mensagens de erro (com ❌ ou ⚠️)

---

## 🚨 PROBLEMAS COMUNS E SOLUÇÕES

### Problema 1: "Permission Denied"

**Sintoma:**
- Erro nos logs: `PERMISSION_DENIED`
- Dados não aparecem no Firestore

**Solução:**
1. Acesse: https://console.firebase.google.com/project/safeplate-a14e9/firestore/rules
2. Configure as regras:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /establishments/{establishmentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

3. Clique em **"Publicar"**

### Problema 2: "Collection not found"

**Sintoma:**
- Erro nos logs: `NOT_FOUND`
- Dados não aparecem no Firestore

**Solução:**
- Isso é normal! As coleções são criadas automaticamente quando você salva o primeiro documento
- Tente salvar novamente

### Problema 3: "Network error" ou "Timeout"

**Sintoma:**
- Erro nos logs: `Timeout` ou `Network error`
- Dados não aparecem no Firestore

**Solução:**
1. Verifique sua conexão com a internet
2. Verifique se o Firestore API está habilitado:
   - https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=safeplate-a14e9
3. Aguarde alguns minutos e tente novamente

---

## ✅ VERIFICAÇÃO FINAL

Depois de fazer os testes acima, verifique:

### No Firebase Console:

1. Acesse: https://console.firebase.google.com/project/safeplate-a14e9/firestore
2. Vá em **"Dados"**
3. Você deve ver 3 coleções:
   - ✅ `users` - Com os usuários que fizeram login
   - ✅ `establishments` - Com os estabelecimentos criados
   - ✅ `reviews` - Com as avaliações criadas

### Se todas as coleções têm dados:

✅ **O Firestore está funcionando perfeitamente!**
✅ **O app está salvando dados na nuvem!**
✅ **O app está pronto para produção!**

### Se alguma coleção está vazia:

❌ **Há um problema com essa funcionalidade**
❌ **Verifique os logs do app para ver o erro específico**
❌ **Corrija antes de publicar na Play Store**

---

## 📝 RELATÓRIO DE TESTE

Preencha este relatório após os testes:

### Teste 1: Criar Estabelecimento
- [ ] Estabelecimento criado com sucesso no app
- [ ] Estabelecimento aparece no Firestore Console
- [ ] Todos os dados estão corretos no Firestore

### Teste 2: Fazer Login
- [ ] Login realizado com sucesso
- [ ] Usuário aparece na coleção `users` no Firestore
- [ ] Dados do usuário estão corretos

### Teste 3: Criar Avaliação
- [ ] Avaliação criada com sucesso no app
- [ ] Avaliação aparece na coleção `reviews` no Firestore
- [ ] Dados da avaliação estão corretos

### Resultado Final:
- [ ] ✅ Todos os testes passaram - Firestore funcionando!
- [ ] ❌ Algum teste falhou - Verificar logs e corrigir

---

## 🚀 PRÓXIMOS PASSOS

### Se todos os testes passaram:

1. ✅ **O app está pronto para produção!**
2. ✅ **Configure as regras de segurança do Firestore para produção**
3. ✅ **Teste o app em modo release**
4. ✅ **Publique na Play Store!**

### Se algum teste falhou:

1. ❌ **Verifique os logs do app**
2. ❌ **Identifique o erro específico**
3. ❌ **Corrija o problema**
4. ❌ **Teste novamente**

---

## 💡 DICAS

- **Sempre verifique o Firebase Console após criar dados pelo app**
- **Os dados podem levar alguns segundos para aparecer (atualize a página)**
- **Se não aparecer, verifique os logs do app para ver o erro**
- **As coleções são criadas automaticamente quando você salva o primeiro documento**

---

**Boa sorte com os testes!** 🚀


