# 🔧 Configurar Repositório Git

Seu projeto não estava conectado ao Git. Vamos configurar agora!

---

## ✅ Passo 1: Git Já Inicializado

O repositório Git já foi inicializado. Agora vamos configurar.

---

## 📝 Passo 2: Configurar Seu Nome e Email (Primeira Vez)

Se ainda não configurou, execute:

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

**Exemplo:**
```bash
git config --global user.name "Bruna B"
git config --global user.email "bruna@exemplo.com"
```

---

## 🚀 Passo 3: Adicionar Todos os Arquivos

```bash
git add .
```

---

## 💾 Passo 4: Fazer Primeiro Commit

```bash
git commit -m "Projeto inicial Prato Seguro"
```

---

## 🌐 Passo 5: Conectar ao GitHub

### **Opção A: Você Já Tem Repositório no GitHub**

Se você já criou um repositório no GitHub:

```bash
# Substitua SEU-USUARIO e NOME-REPOSITORIO pelos seus valores
git remote add origin https://github.com/SEU-USUARIO/NOME-REPOSITORIO.git

# Verificar se foi adicionado
git remote -v

# Enviar código para o GitHub
git branch -M main
git push -u origin main
```

**Exemplo:**
```bash
git remote add origin https://github.com/bruna/prato-seguro.git
git branch -M main
git push -u origin main
```

---

### **Opção B: Criar Novo Repositório no GitHub**

1. **Acesse:** https://github.com/new
2. **Nome do repositório:** `prato-seguro` (ou outro nome)
3. **Visibilidade:** Escolha **Privado** ou **Público**
4. **NÃO marque** "Add a README file" (já temos arquivos)
5. **NÃO marque** "Add .gitignore" (já temos)
6. **Clique em:** "Create repository"

Depois, execute:

```bash
# Substitua SEU-USUARIO pelo seu usuário GitHub
git remote add origin https://github.com/SEU-USUARIO/prato-seguro.git
git branch -M main
git push -u origin main
```

---

## 🔐 Passo 6: Autenticação no GitHub

### **Se Pedir Usuário e Senha:**

O GitHub não aceita mais senha simples. Use um **Personal Access Token**:

1. **Acesse:** https://github.com/settings/tokens
2. **Clique em:** "Generate new token" → "Generate new token (classic)"
3. **Nome:** `Prato Seguro`
4. **Expiração:** Escolha (ex: 90 dias)
5. **Permissões:** Marque `repo` (todas as opções)
6. **Clique em:** "Generate token"
7. **COPIE O TOKEN** (você só verá uma vez!)

Quando pedir senha, **cole o token** no lugar da senha.

---

## ✅ Verificar se Funcionou

```bash
git status
```

Deve mostrar algo como:
```
On branch main
Your branch is up to date with 'origin/main'.
nothing to commit, working tree clean
```

---

## 🎯 Próximos Passos

Após configurar o Git:

1. ✅ Continue com o `GUIA_COMPLETO_IOS_SEM_MAC.md`
2. ✅ O GitHub Actions poderá fazer o build do iOS
3. ✅ Você poderá testar no simulador

---

## ❓ Problemas Comuns

### **Erro: "remote origin already exists"**

```bash
# Remover o remote antigo
git remote remove origin

# Adicionar novamente
git remote add origin https://github.com/SEU-USUARIO/prato-seguro.git
```

### **Erro: "authentication failed"**

- Use um **Personal Access Token** em vez de senha
- Veja o Passo 6 acima

### **Erro: "fatal: refusing to merge unrelated histories"**

```bash
git pull origin main --allow-unrelated-histories
```

---

**✅ Após configurar, volte ao `GUIA_COMPLETO_IOS_SEM_MAC.md`!**

