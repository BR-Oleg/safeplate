# 🔍 Solução: Mesmo Banco de Dados do App

## Você está certo! 

Se o app Flutter já está funcionando e salvando dados no Firestore, então:
- ✅ O Firestore API **já está habilitado**
- ✅ O banco de dados **já existe**
- ✅ As regras permitem escrita/leitura

## O Problema Real

O erro `PERMISSION_DENIED` geralmente acontece porque:

### 1. **A Conta de Serviço não tem permissões**

A conta de serviço (service account) usada no backend precisa ter permissões no projeto.

**Como verificar e corrigir:**

1. **Acesse o Google Cloud Console:**
   - https://console.cloud.google.com/
   - Selecione o projeto `safeplate-a14e9`

2. **Vá para IAM e Administração:**
   - Menu lateral → **"IAM e Administração"** → **"IAM"**
   - Ou acesse: https://console.cloud.google.com/iam-admin/iam?project=safeplate-a14e9

3. **Procure pela conta de serviço:**
   - Procure pelo email que está no seu `.env` (algo como `firebase-adminsdk-xxxxx@safeplate-a14e9.iam.gserviceaccount.com`)

4. **Verifique o papel (role):**
   - Deve ter pelo menos: **"Editor"** ou **"Proprietário"**
   - Se não tiver, clique nos 3 pontos → **"Editar"** → Adicione o papel **"Editor"**

### 2. **Credenciais Incorretas**

As credenciais no arquivo `.env` podem estar incorretas.

**Como verificar:**

1. **Acesse o Firebase Console:**
   - https://console.firebase.google.com/
   - Selecione o projeto `safeplate-a14e9`

2. **Vá para Configurações do Projeto:**
   - Ícone de engrenagem → **"Configurações do Projeto"**

3. **Vá para Contas de Serviço:**
   - Aba **"Contas de Serviço"**

4. **Gere uma nova chave:**
   - Clique em **"Gerar Nova Chave Privada"**
   - Um arquivo JSON será baixado

5. **Atualize o `.env`:**
   - Abra o JSON baixado
   - Copie os valores:
     - `project_id` → `FIREBASE_PROJECT_ID`
     - `private_key` → `FIREBASE_PRIVATE_KEY` (mantenha as aspas e `\n`)
     - `client_email` → `FIREBASE_CLIENT_EMAIL`

### 3. **Firestore API precisa ser habilitado para Admin SDK**

Mesmo que o app Flutter já use o Firestore, o **Admin SDK** pode precisar que a API esteja explicitamente habilitada.

**Como habilitar:**

1. **Acesse o link direto:**
   - https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=safeplate-a14e9

2. **Clique em "HABILITAR"**

3. **Aguarde alguns minutos**

## Como Testar

Execute o script de verificação:

```bash
cd admin-dashboard/backend
npm run verificar-permissoes
```

Este script vai:
- ✅ Verificar se consegue acessar as coleções que o app já usa
- ✅ Mostrar exatamente qual é o problema
- ✅ Dar dicas de como resolver

## Resumo

1. ✅ **Mesmo banco de dados** - O app Flutter já usa
2. ❌ **Problema:** Conta de serviço sem permissões OU credenciais incorretas
3. 🔧 **Solução:** 
   - Verificar permissões da conta de serviço no Google Cloud Console
   - Gerar nova chave privada no Firebase Console
   - Atualizar o arquivo `.env`
   - (Opcional) Habilitar Firestore API explicitamente

## Próximos Passos

1. Execute: `npm run verificar-permissoes`
2. Veja qual é o erro específico
3. Siga as instruções acima baseado no erro
4. Teste novamente: `npm run test-firebase`


