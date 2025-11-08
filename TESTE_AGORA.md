# 🧪 TESTE AGORA - FIRESTORE

## ✅ Banco de Dados Criado!

Agora vamos testar se o app está salvando os dados corretamente no Firestore.

---

## 🚀 TESTE RÁPIDO (5 minutos)

### 1️⃣ Criar um Estabelecimento

1. **Abra o app**
2. **Faça login como empresa** (ou crie uma conta empresa)
3. **Vá para "Cadastrar Estabelecimento"**
4. **Preencha:**
   - Nome: `Teste Firestore`
   - Categoria: `Restaurante`
   - CEP: `01310-100` (Av. Paulista, São Paulo)
   - Número: `1000`
   - Horário: `08:00` até `18:00`
   - Dias: Marque alguns dias da semana
   - Opções dietéticas: Marque algumas
5. **Clique em "Salvar"**
6. **Aguarde a mensagem de sucesso**

### 2️⃣ Verificar no Firebase Console

1. **Abra:** https://console.firebase.google.com/project/safeplate-a14e9/firestore
2. **Clique em "Dados"** (aba superior)
3. **Procure pela coleção `establishments`**
4. **Clique na coleção**
5. **Você deve ver o estabelecimento "Teste Firestore"!**

**✅ Se aparecer:**
- ✅ O Firestore está funcionando!
- ✅ Os dados estão sendo salvos na nuvem!

**❌ Se NÃO aparecer:**
- Verifique os logs do app (veja abaixo)
- Pode haver um erro de permissão

---

## 🔍 VERIFICAR LOGS DO APP

### No Android Studio:

1. Abra o Android Studio
2. Execute o app
3. Abra a aba **"Logcat"** (parte inferior)
4. Filtre por: `Firebase` ou `Firestore`
5. Procure por:

**✅ Mensagens de SUCESSO:**
```
✅ Estabelecimento salvo com ID: abc123
✅ Firebase inicializado com sucesso!
```

**❌ Mensagens de ERRO:**
```
❌ Erro ao salvar estabelecimento: PERMISSION_DENIED
⚠️ Erro ao salvar dados no Firestore: ...
```

### No Terminal:

```bash
flutter run
```

Os logs aparecerão no terminal. Procure por mensagens com `✅` ou `❌`.

---

## 🚨 SE NÃO FUNCIONAR

### Erro: `PERMISSION_DENIED`

**Solução:**
1. Acesse: https://console.firebase.google.com/project/safeplate-a14e9/firestore/rules
2. Cole estas regras:

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

### Erro: `NOT_FOUND` ou `UNAVAILABLE`

**Solução:**
1. Verifique se o Firestore Database existe:
   - https://console.firebase.google.com/project/safeplate-a14e9/firestore
2. Verifique se o Firestore API está habilitado:
   - https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=safeplate-a14e9
3. Aguarde alguns minutos e tente novamente

---

## ✅ RESULTADO ESPERADO

### Se tudo estiver funcionando:

1. ✅ Você cria um estabelecimento pelo app
2. ✅ Aparece mensagem de sucesso no app
3. ✅ O estabelecimento aparece no Firebase Console
4. ✅ Todos os dados estão corretos no Firestore

### Se algo não funcionar:

1. ❌ Verifique os logs do app
2. ❌ Identifique o erro específico
3. ❌ Siga as soluções acima
4. ❌ Teste novamente

---

## 📝 RELATÓRIO DE TESTE

Após fazer o teste, me diga:

1. **O estabelecimento apareceu no Firebase Console?**
   - [ ] Sim ✅
   - [ ] Não ❌

2. **Há erros nos logs do app?**
   - [ ] Não, tudo funcionou ✅
   - [ ] Sim, erro: `PERMISSION_DENIED` ❌
   - [ ] Sim, erro: `NOT_FOUND` ❌
   - [ ] Sim, outro erro: ______________ ❌

3. **Os dados estão corretos no Firestore?**
   - [ ] Sim, todos os dados estão corretos ✅
   - [ ] Não, faltam alguns dados ❌

---

## 🚀 PRÓXIMOS PASSOS

### Se o teste passou:

1. ✅ **O Firestore está funcionando!**
2. ✅ **Configure as regras de segurança para produção**
3. ✅ **Teste as outras funcionalidades (login, avaliações)**
4. ✅ **O app está pronto para produção!**

### Se o teste falhou:

1. ❌ **Me envie os logs do app**
2. ❌ **Me diga qual erro apareceu**
3. ❌ **Vou ajudar a corrigir**

---

**Faça o teste rápido e me diga o resultado!** 🚀


