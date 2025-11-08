# 📋 Resumo das Funcionalidades do Dashboard

## 🎯 O que o Dashboard Administrativo faz?

O dashboard é um **painel de controle completo** para administrar o aplicativo Prato Seguro. Ele permite gerenciar usuários, estabelecimentos, licenças e controlar o status do app.

---

## 🔧 **1. Sistema de Manutenção**

**O que faz:**
- **Ativa/desativa o modo de manutenção** do aplicativo
- Quando ativado, **bloqueia o acesso** de todos os usuários
- Exibe uma **mensagem personalizada** para quem tentar usar o app durante a manutenção

**Quando usar:**
- Para fazer atualizações importantes
- Para resolver problemas técnicos
- Para realizar manutenções programadas

---

## 👥 **2. Gerenciamento de Usuários**

**O que faz:**
- **Visualiza todos os usuários** cadastrados no app
- **Filtra por tipo:**
  - Usuários comuns
  - Empresas (usuários-empresa)
  - Usuários banidos
- **Banir usuários:**
  - Remove o acesso do usuário ao app
  - Registra o motivo do banimento
  - Desabilita a conta no Firebase
- **Desbanir usuários:**
  - Restaura o acesso do usuário
  - Remove o status de banido

**Quando usar:**
- Para moderar usuários problemáticos
- Para auditar contas suspeitas
- Para gerenciar acessos

---

## 🏢 **3. Gerenciamento de Estabelecimentos**

**O que faz:**
- **Visualiza todos os estabelecimentos** cadastrados
- **Atribui nível de dificuldade:**
  - **Popular** - Fácil de entender
  - **Intermediário** - Requer conhecimento médio
  - **Técnico** - Requer conhecimento avançado
- **Filtra estabelecimentos** por nível de dificuldade

**Quando usar:**
- Para classificar estabelecimentos conforme complexidade
- Para garantir que os selos estejam corretos
- Para auditar estabelecimentos cadastrados

---

## 💳 **4. Gerenciamento de Licenças e Faturamento**

**O que faz:**
- **Visualiza todas as licenças** vendidas para empresas
- **Cria novas licenças:**
  - Define o valor da licença
  - Define o plano (mensal/anual)
  - Define a duração em dias
  - Associa a uma empresa
- **Estatísticas de faturamento:**
  - Total de licenças vendidas
  - Licenças ativas
  - Faturamento total acumulado
- **Visualiza detalhes:**
  - Qual empresa comprou
  - Quando expira
  - Status da licença

**Quando usar:**
- Para gerenciar vendas de licenças
- Para acompanhar faturamento
- Para controlar expiração de licenças

---

## 📊 **5. Dashboard de Estatísticas**

**O que faz:**
- **Mostra números gerais** do aplicativo:
  - Total de usuários cadastrados
  - Quantidade de empresas
  - Quantidade de estabelecimentos
  - Total de avaliações
  - Total de licenças vendidas
  - Faturamento total

**Quando usar:**
- Para ter uma visão geral do app
- Para acompanhar o crescimento
- Para tomar decisões baseadas em dados

---

## 🔐 **6. Autenticação e Segurança**

**O que faz:**
- **Login protegido** com credenciais de administrador
- **Acesso restrito** apenas para admins
- **Tokens de autenticação** para segurança
- **Logout** para encerrar sessão

---

## 📱 **Interface do Dashboard**

O dashboard tem **5 abas principais:**

1. **📊 Estatísticas** - Visão geral dos números
2. **🔧 Manutenção** - Controlar status do app
3. **👥 Usuários** - Gerenciar usuários e empresas
4. **🏢 Estabelecimentos** - Gerenciar estabelecimentos
5. **💳 Licenças** - Gerenciar faturamento

---

## 🎯 Resumo Rápido

| Funcionalidade | O que faz |
|---------------|-----------|
| **Manutenção** | Liga/desliga o app e mostra mensagem |
| **Usuários** | Vê, filtra, bane e desbane usuários |
| **Estabelecimentos** | Atribui nível de dificuldade (Popular/Intermediário/Técnico) |
| **Licenças** | Cria licenças, vê faturamento e gerencia vendas |
| **Estatísticas** | Mostra números gerais do app |

---

## 💡 Casos de Uso Práticos

1. **"Preciso fazer uma atualização importante"**
   → Vá em **Manutenção** e ative o modo de manutenção

2. **"Um usuário está causando problemas"**
   → Vá em **Usuários**, encontre o usuário e clique em **Banir**

3. **"Uma empresa comprou uma licença"**
   → Vá em **Licenças** e crie uma nova licença para a empresa

4. **"Preciso classificar um estabelecimento"**
   → Vá em **Estabelecimentos** e altere o nível de dificuldade

5. **"Quero ver quantos usuários temos"**
   → Vá em **Estatísticas** e veja todos os números

---

## ✅ Tudo isso em um só lugar!

O dashboard centraliza **todas as funções administrativas** do Prato Seguro, facilitando o gerenciamento do aplicativo de forma simples e eficiente.


