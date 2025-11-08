# 🔍 COMO VERIFICAR SE O FIRESTORE ESTÁ FUNCIONANDO

## ✅ TESTE RÁPIDO

### 1. Crie um estabelecimento pelo app

### 2. Verifique imediatamente no Firebase Console

Acesse: https://console.firebase.google.com/project/safeplate-a14e9/firestore

**Procure pela coleção `establishments`**

- ✅ **Se aparecer:** O Firestore está funcionando! ✅
- ❌ **Se NÃO aparecer:** O Firestore não está funcionando! ❌

---

## 📋 CHECKLIST COMPLETO

### ✅ Firestore Database existe?

1. Acesse: https://console.firebase.google.com/project/safeplate-a14e9/firestore
2. Você vê uma interface com coleções ou uma tela pedindo para "Criar banco de dados"?

**Se pedir para criar:**
- ❌ O Firestore não existe
- 🔧 **Solução:** Clique em "Criar banco de dados" e crie

**Se você vê uma interface com coleções:**
- ✅ O Firestore existe
- Continue verificando...

### ✅ Há dados nas coleções?

**Verifique estas coleções:**
- `users` - Deve ter os usuários que fizeram login
- `establishments` - Deve ter os estabelecimentos criados
- `reviews` - Deve ter as avaliações criadas

**Se as coleções estão vazias:**
- ⚠️ Pode ser que o app ainda não salvou dados
- ⚠️ Ou o app está falhando silenciosamente ao salvar

**Teste:**
1. Crie um estabelecimento pelo app
2. Aguarde 5 segundos
3. Recarregue a página do Firebase Console
4. O estabelecimento aparece?

**Se aparecer:**
- ✅ O Firestore está funcionando!

**Se NÃO aparecer:**
- ❌ O Firestore não está funcionando
- Verifique os logs do app para ver o erro

### ✅ Firestore API está habilitada?

1. Acesse: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=safeplate-a14e9
2. Você vê um botão "HABILITAR" ou "Habilitado"?

**Se vê "HABILITAR":**
- ❌ A API não está habilitada
- 🔧 **Solução:** Clique em "HABILITAR"

**Se vê "Habilitado":**
- ✅ A API está habilitada
- Continue verificando...

### ✅ Regras de segurança permitem escrita?

1. Acesse: https://console.firebase.google.com/project/safeplate-a14e9/firestore/rules
2. Verifique as regras

**Regras básicas para teste:**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Se as regras estão muito restritivas:**
- ❌ Pode estar bloqueando escrita
- 🔧 **Solução:** Use as regras acima para teste (depois ajuste para produção)

---

## 🧪 TESTE PRÁTICO

### Teste 1: Criar Estabelecimento

1. Abra o app
2. Faça login como empresa
3. Crie um estabelecimento novo
4. Anote o nome do estabelecimento
5. Abra o Firebase Console
6. Vá em Firestore → Dados
7. Procure pela coleção `establishments`
8. O estabelecimento aparece?

**Resultado esperado:**
- ✅ O estabelecimento deve aparecer imediatamente
- ✅ Com o nome que você digitou
- ✅ Com todos os dados que você preencheu

**Se NÃO aparecer:**
- ❌ O Firestore não está funcionando
- ❌ Os dados estão sendo perdidos
- ❌ O app está usando apenas dados mockados

### Teste 2: Fazer Login

1. Faça logout do app
2. Faça login novamente com Google
3. Abra o Firebase Console
4. Vá em Firestore → Dados
5. Procure pela coleção `users`
6. Seu usuário aparece?

**Resultado esperado:**
- ✅ O usuário deve aparecer
- ✅ Com o email que você usou
- ✅ Com o nome do Google

**Se NÃO aparecer:**
- ❌ O Firestore não está salvando usuários
- ❌ Os dados estão sendo salvos apenas localmente

### Teste 3: Criar Avaliação

1. Abra um estabelecimento
2. Crie uma avaliação
3. Abra o Firebase Console
4. Vá em Firestore → Dados
5. Procure pela coleção `reviews`
6. A avaliação aparece?

**Resultado esperado:**
- ✅ A avaliação deve aparecer
- ✅ Com o comentário que você digitou
- ✅ Com a nota que você deu

**Se NÃO aparecer:**
- ❌ O Firestore não está salvando avaliações
- ❌ Os dados estão sendo salvos apenas localmente

---

## ✅ CONCLUSÃO

**O app só está realmente na nuvem se:**

1. ✅ O Firestore Database existe
2. ✅ Os dados aparecem no Firebase Console
3. ✅ Quando você cria algo pelo app, aparece no Firestore
4. ✅ Quando você recarrega o app, os dados persistem

**Se alguma dessas condições não for verdadeira:**

- ❌ O Firestore não está funcionando
- ❌ Os dados estão sendo perdidos
- ❌ O app está usando apenas dados mockados/locais
- 🔧 **Corrija as configurações do Firestore antes de publicar!**

---

## 🚨 IMPORTANTE

**NÃO publique o app na Play Store se:**

- ❌ O Firestore não existe
- ❌ Os dados não aparecem no Firestore
- ❌ O app está usando apenas dados mockados

**Isso causaria:**
- ❌ Perda de dados dos usuários
- ❌ Dados não sincronizam entre dispositivos
- ❌ Problemas graves em produção

**Corrija primeiro, depois publique!** ✅


