# 🔧 Como Habilitar o Firestore API

## Problema Identificado

O erro mostra que o **Firestore API não está habilitado** no seu projeto Firebase.

```
PERMISSION_DENIED: Cloud Firestore API has not been used in project safeplate-a14e9 before or it is disabled.
```

## Solução: Habilitar Firestore API

### Opção 1: Link Direto (Mais Rápido)

Clique neste link para habilitar diretamente:
👉 **https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=safeplate-a14e9**

Depois clique em **"HABILITAR"** ou **"ENABLE"**.

### Opção 2: Passo a Passo Manual

1. **Acesse o Google Cloud Console:**
   - Vá em: https://console.cloud.google.com/
   - Certifique-se de que o projeto `safeplate-a14e9` está selecionado

2. **Vá para APIs e Serviços:**
   - No menu lateral, clique em **"APIs e Serviços"** → **"Biblioteca"**
   - Ou acesse diretamente: https://console.cloud.google.com/apis/library

3. **Procure por Firestore:**
   - Na barra de busca, digite: **"Cloud Firestore API"**
   - Clique no resultado

4. **Habilite a API:**
   - Clique no botão **"HABILITAR"** ou **"ENABLE"**
   - Aguarde alguns segundos

5. **Verifique:**
   - Você deve ver uma mensagem de sucesso
   - O status deve mudar para "Habilitado"

## Depois de Habilitar

### 1. Aguarde alguns minutos
   - Pode levar 1-5 minutos para a API se propagar

### 2. Teste novamente:
```bash
cd admin-dashboard/backend
npm run test-firebase
```

Agora deve funcionar! ✅

### 3. Se ainda não funcionar:

#### Verifique se o Firestore Database está criado:

1. **Acesse o Firebase Console:**
   - Vá em: https://console.firebase.google.com/
   - Selecione o projeto `safeplate-a14e9`

2. **Vá para Firestore Database:**
   - No menu lateral, clique em **"Firestore Database"**
   - Se você ver uma mensagem "Criar banco de dados", clique nela

3. **Configure o Firestore:**
   - Escolha o modo: **"Modo de produção"** ou **"Modo de teste"** (para desenvolvimento)
   - Escolha a localização (ex: `us-central1`)
   - Clique em **"Criar"**

4. **Aguarde:**
   - Pode levar alguns minutos para o banco ser criado

## Verificar se Está Funcionando

Depois de habilitar o Firestore API e criar o banco de dados:

1. **Teste novamente:**
```bash
npm run test-firebase
```

2. **Você deve ver:**
```
✅ Firebase Admin SDK inicializado com sucesso!
🔍 Testando conexão com Firestore...
✅ Conexão com Firestore funcionando!
📦 Verificando coleções existentes...
  users: ⚠️ Vazia ou não existe
  establishments: ⚠️ Vazia ou não existe
  reviews: ⚠️ Vazia ou não existe
✅ Teste concluído com sucesso!
```

3. **Inicie o backend:**
```bash
npm start
```

4. **Teste a rota de health:**
   - Abra: http://localhost:3001/api/health
   - Deve retornar: `{"status":"ok","message":"Servidor funcionando","firebase":"conectado"}`

## Resumo Rápido

1. ✅ Habilite o Firestore API: https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=safeplate-a14e9
2. ✅ Crie o Firestore Database no Firebase Console (se não existir)
3. ✅ Aguarde alguns minutos
4. ✅ Teste: `npm run test-firebase`
5. ✅ Inicie o backend: `npm start`

## Se Ainda Não Funcionar

Verifique também:

1. **Permissões da Conta de Serviço:**
   - No Firebase Console → Configurações → Contas de Serviço
   - Certifique-se de que a conta de serviço tem permissões de **Editor** ou **Proprietário**

2. **Regras do Firestore:**
   - No Firebase Console → Firestore Database → Regras
   - Para desenvolvimento, você pode usar regras permissivas temporariamente:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /{document=**} {
         allow read, write: if true;
       }
     }
   }
   ```
   ⚠️ **ATENÇÃO:** Isso é apenas para desenvolvimento! Em produção, use regras mais restritivas.


