# Prato Seguro - Painel Administrativo

Painel administrativo completo para gerenciar o aplicativo Prato Seguro.

## Estrutura

- `backend/` - API Node.js/Express
- `frontend/` - Interface Next.js

## Configuração

### Backend

1. Instale as dependências:
```bash
cd backend
npm install
```

2. Configure as variáveis de ambiente:
```bash
cp .env.example .env
# Edite o .env com suas credenciais do Firebase
```

3. Inicie o servidor:
```bash
npm start
```

### Frontend

1. Instale as dependências:
```bash
cd frontend
npm install
```

2. Configure a URL da API no `.env.local`:
```
NEXT_PUBLIC_API_URL=http://localhost:3001
```

3. Inicie o servidor de desenvolvimento:
```bash
npm run dev
```

## Funcionalidades

- ✅ Sistema de manutenção do app
- ✅ Gerenciamento de usuários e empresas
- ✅ Banimento/desbanimento de usuários
- ✅ Atribuição de nível de dificuldade aos estabelecimentos
- ✅ Gerenciamento de licenças e faturamento
- ✅ Dashboard com estatísticas gerais

## Autenticação

O painel usa autenticação via Firebase Admin SDK. Configure as credenciais no arquivo `.env` do backend.



