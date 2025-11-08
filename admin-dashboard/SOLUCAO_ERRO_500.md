# 🔧 Solução para Erro 500

## Problema

O backend está retornando erro 500 (Internal Server Error) em todas as rotas.

## Causas Possíveis

### 1. Firebase Admin SDK não configurado

**Sintoma:** Erro 500 em todas as rotas

**Solução:**
1. Verifique se o arquivo `.env` existe na pasta `admin-dashboard/backend`
2. Verifique se as variáveis estão configuradas:
   ```
   FIREBASE_PROJECT_ID=seu-project-id
   FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk@seu-projeto.iam.gserviceaccount.com
   ```

### 2. Credenciais do Firebase incorretas

**Sintoma:** Erro ao inicializar Firebase Admin SDK

**Solução:**
1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Selecione seu projeto
3. Vá em **Configurações do Projeto** (ícone de engrenagem)
4. Vá na aba **Contas de Serviço**
5. Clique em **Gerar Nova Chave Privada**
6. Um arquivo JSON será baixado
7. Copie os valores para o arquivo `.env`:
   - `project_id` → `FIREBASE_PROJECT_ID`
   - `private_key` → `FIREBASE_PRIVATE_KEY` (mantenha as aspas e `\n`)
   - `client_email` → `FIREBASE_CLIENT_EMAIL`

### 3. Firestore não habilitado

**Sintoma:** Erro ao acessar coleções

**Solução:**
1. Acesse o Firebase Console
2. Vá em **Firestore Database**
3. Se não existir, clique em **Criar banco de dados**
4. Escolha modo de produção ou teste (para desenvolvimento)

## Como Testar

Execute o script de teste:

```bash
cd admin-dashboard/backend
npm run test-firebase
```

Este script vai:
- ✅ Verificar se as variáveis de ambiente estão configuradas
- ✅ Testar a inicialização do Firebase Admin SDK
- ✅ Testar a conexão com Firestore
- ✅ Verificar se as coleções existem

## Verificar Logs do Backend

Quando você rodar `npm start`, você deve ver:

```
✅ Firebase Admin SDK inicializado com sucesso
🚀 Servidor admin rodando na porta 3001
```

Se você ver erros, eles vão indicar o problema específico.

## Passo a Passo para Resolver

1. **Pare o backend** (Ctrl+C)

2. **Verifique o arquivo .env:**
   ```bash
   cd admin-dashboard/backend
   # Verifique se o arquivo .env existe e tem as variáveis corretas
   ```

3. **Teste a conexão:**
   ```bash
   npm run test-firebase
   ```

4. **Se o teste passar, reinicie o backend:**
   ```bash
   npm start
   ```

5. **Teste a rota de health:**
   Abra no navegador: `http://localhost:3001/api/health`
   
   Deve retornar:
   ```json
   {
     "status": "ok",
     "message": "Servidor funcionando",
     "firebase": "conectado"
   }
   ```

## Se Ainda Não Funcionar

1. **Verifique os logs do backend:**
   - Procure por mensagens de erro
   - Procure por "❌" que indicam problemas

2. **Verifique o console do navegador:**
   - Pressione F12
   - Vá na aba "Network"
   - Clique em uma requisição que falhou
   - Veja a resposta do servidor

3. **Envie os logs:**
   - Copie os logs do terminal do backend
   - Copie os erros do console do navegador
   - Me envie para eu ajudar a debugar

## Exemplo de .env Correto

```env
FIREBASE_PROJECT_ID=prato-seguro-12345
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-abc123@prato-seguro-12345.iam.gserviceaccount.com
JWT_SECRET=minha-chave-secreta-super-segura-123
PORT=3001
ADMIN_EMAIL=admin@pratoseguro.com
ADMIN_PASSWORD=admin123
```

**⚠️ IMPORTANTE:**
- O `FIREBASE_PRIVATE_KEY` deve estar entre aspas duplas
- Deve ter `\n` para quebras de linha
- Não deve ter espaços extras


