# 🔍 Como Verificar os Dados no Firestore

## Você está certo!

Se o app Flutter já está funcionando e salvando dados, então:

✅ **O app usa Firestore para:**
- `users` - Dados dos usuários (login Google, etc)
- `establishments` - Estabelecimentos criados
- `reviews` - Avaliações

✅ **O app usa SQLite LOCAL para:**
- `favorites` - Favoritos (não estão no Firestore!)

## Como Verificar no Firebase Console

### 1. Acesse o Firebase Console

👉 **https://console.firebase.google.com/project/safeplate-a14e9/firestore**

### 2. Verifique se o Firestore Database existe

- Se você ver uma tela pedindo para "Criar banco de dados", **crie agora**
- Se você ver uma interface com coleções, o banco já existe ✅

### 3. Verifique as coleções

Você deve ver coleções como:
- `users` - Com os usuários que fizeram login
- `establishments` - Com os estabelecimentos criados
- `reviews` - Com as avaliações

### 4. Se as coleções estão vazias

Isso pode significar:
- O app ainda não salvou dados no Firestore
- Os dados estão sendo salvos apenas localmente
- Há um erro ao salvar no Firestore

## Como Verificar se o App Está Salvando no Firestore

### 1. Abra o app Flutter

### 2. Crie um estabelecimento novo

### 3. Verifique no Firebase Console

- Vá em **Firestore Database** → **Dados**
- Procure pela coleção `establishments`
- Você deve ver o novo estabelecimento

### 4. Faça login com Google

- Vá em **Firestore Database** → **Dados**
- Procure pela coleção `users`
- Você deve ver o usuário criado

## Se o Firestore Database Não Existe

### Crie o banco de dados:

1. **Acesse:** https://console.firebase.google.com/project/safeplate-a14e9/firestore

2. **Clique em "Criar banco de dados"**

3. **Escolha o modo:**
   - **Modo de produção** (recomendado) - Regras mais restritivas
   - **Modo de teste** (para desenvolvimento) - Permite leitura/escrita por 30 dias

4. **Escolha a localização:**
   - Ex: `us-central1` (Iowa)
   - Ou a mais próxima do Brasil

5. **Clique em "Criar"**

6. **Aguarde alguns minutos** para o banco ser criado

## Se o Firestore API Não Está Habilitado

Mesmo que o app use o Firestore, o **Admin SDK** pode precisar que a API esteja explicitamente habilitada:

👉 **Habilite aqui:** https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=safeplate-a14e9

## Depois de Verificar

1. **Se o banco existe e tem dados:**
   - O problema é com as credenciais do Admin SDK
   - Verifique se a conta de serviço tem permissões

2. **Se o banco não existe:**
   - Crie o banco de dados no Firebase Console
   - Aguarde alguns minutos
   - Teste novamente

3. **Se o banco existe mas está vazio:**
   - Crie um estabelecimento pelo app
   - Faça login com Google
   - Verifique se os dados aparecem no Firestore

## Resumo

1. ✅ **Acesse o Firebase Console** e verifique se o Firestore Database existe
2. ✅ **Verifique se há dados** nas coleções `users`, `establishments`, `reviews`
3. ✅ **Se não existir**, crie o banco de dados
4. ✅ **Se estiver vazio**, teste criando dados pelo app
5. ✅ **Habilite o Firestore API** para o Admin SDK funcionar

Me diga o que você encontrou no Firebase Console!


