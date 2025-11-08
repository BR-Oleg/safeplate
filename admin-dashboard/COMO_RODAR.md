# 🚀 Como Rodar o Dashboard Administrativo

Este guia vai te ensinar passo a passo como colocar o dashboard para funcionar.

## 📋 Pré-requisitos

Você precisa ter instalado:
- **Node.js** (versão 16 ou superior) - [Baixar aqui](https://nodejs.org/)
- **npm** (vem junto com o Node.js)

Para verificar se já tem instalado, abra o terminal e digite:
```bash
node --version
npm --version
```

---

## 🔧 Passo 1: Configurar o Backend

### 1.1. Instalar as dependências do backend

Abra o terminal na pasta do projeto e execute:

```bash
cd admin-dashboard/backend
npm install
```

Isso vai instalar todas as bibliotecas necessárias (express, firebase-admin, etc).

### 1.2. Configurar o Firebase Admin SDK

Você precisa das credenciais do Firebase Admin SDK:

1. Acesse o [Firebase Console](https://console.firebase.google.com/)
2. Selecione seu projeto
3. Vá em **Configurações do Projeto** (ícone de engrenagem)
4. Vá na aba **Contas de Serviço**
5. Clique em **Gerar Nova Chave Privada**
6. Um arquivo JSON será baixado

### 1.3. Criar arquivo .env no backend

Na pasta `admin-dashboard/backend`, crie um arquivo chamado `.env` (sem extensão) com o seguinte conteúdo:

```env
# Firebase Admin SDK (pegue do arquivo JSON que você baixou)
FIREBASE_PROJECT_ID=seu-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk@seu-projeto.iam.gserviceaccount.com

# JWT Secret (pode ser qualquer string aleatória)
JWT_SECRET=minha-chave-secreta-super-segura-123

# Porta do servidor
PORT=3001

# Credenciais do admin (você vai usar para fazer login)
ADMIN_EMAIL=admin@pratoseguro.com
ADMIN_PASSWORD=admin123
```

**⚠️ IMPORTANTE:**
- Substitua os valores do Firebase pelos valores do arquivo JSON que você baixou
- O `FIREBASE_PRIVATE_KEY` deve estar entre aspas e com `\n` para quebras de linha
- Você pode mudar o email e senha do admin para o que quiser

---

## 🎨 Passo 2: Configurar o Frontend

### 2.1. Instalar as dependências do frontend

Abra um **novo terminal** (deixe o backend rodando) e execute:

```bash
cd admin-dashboard/frontend
npm install
```

### 2.2. Criar arquivo .env.local no frontend

Na pasta `admin-dashboard/frontend`, crie um arquivo chamado `.env.local` com:

```env
# URL da API do backend
NEXT_PUBLIC_API_URL=http://localhost:3001
```

---

## ▶️ Passo 3: Rodar os Servidores

### 3.1. Iniciar o Backend

No terminal, na pasta `admin-dashboard/backend`, execute:

```bash
npm start
```

Você deve ver a mensagem:
```
🚀 Servidor admin rodando na porta 3001
```

**Deixe este terminal aberto!**

### 3.2. Iniciar o Frontend

Abra um **novo terminal**, vá para a pasta `admin-dashboard/frontend` e execute:

```bash
npm run dev
```

Você deve ver algo como:
```
- ready started server on 0.0.0.0:3000
- Local:        http://localhost:3000
```

---

## 🌐 Passo 4: Acessar o Dashboard

1. Abra seu navegador
2. Acesse: **http://localhost:3000**
3. Você verá a tela de login
4. Use as credenciais que você configurou no `.env`:
   - Email: `admin@pratoseguro.com` (ou o que você colocou)
   - Senha: `admin123` (ou a que você colocou)

---

## ✅ Verificar se está tudo funcionando

Depois de fazer login, você deve ver:
- ✅ Dashboard com estatísticas
- ✅ Aba "Manutenção" funcionando
- ✅ Aba "Usuários" funcionando
- ✅ Aba "Estabelecimentos" funcionando
- ✅ Aba "Licenças" funcionando

---

## 🐛 Problemas Comuns

### Erro: "Cannot find module"
**Solução:** Execute `npm install` novamente na pasta onde está o erro.

### Erro: "Port 3001 already in use"
**Solução:** Altere a porta no arquivo `.env` do backend para outra (ex: `PORT=3002`) e atualize o `.env.local` do frontend também.

### Erro: "Firebase Admin SDK"
**Solução:** Verifique se você copiou corretamente as credenciais do Firebase no arquivo `.env`.

### Erro: "Cannot connect to API"
**Solução:** Certifique-se de que o backend está rodando na porta 3001 e que a URL no `.env.local` do frontend está correta.

---

## 📝 Resumo Rápido

```bash
# Terminal 1 - Backend
cd admin-dashboard/backend
npm install
# (criar arquivo .env com credenciais do Firebase)
npm start

# Terminal 2 - Frontend
cd admin-dashboard/frontend
npm install
# (criar arquivo .env.local com NEXT_PUBLIC_API_URL=http://localhost:3001)
npm run dev

# Acessar no navegador
http://localhost:3000
```

---

## 🎯 Próximos Passos

Depois que estiver rodando:
1. Configure o sistema de manutenção
2. Gerencie usuários e empresas
3. Atribua níveis de dificuldade aos estabelecimentos
4. Crie e gerencie licenças

Qualquer dúvida, me avise! 🚀


