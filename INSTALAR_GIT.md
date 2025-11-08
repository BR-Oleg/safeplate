# 📥 Como Instalar Git no Windows

O Git é necessário para fazer commit e push do código para o GitHub.

---

## 🚀 Instalação Rápida

### **Método 1: Download Direto (Recomendado)**

1. **Baixe o Git:**
   - Acesse: https://git-scm.com/download/win
   - O download começará automaticamente
   - Ou clique em **"Download for Windows"**

2. **Execute o Instalador:**
   - Abra o arquivo baixado (ex: `Git-2.43.0-64-bit.exe`)
   - Clique em **"Next"** várias vezes
   - **IMPORTANTE:** Na tela "Adjusting your PATH environment":
     - Selecione: **"Git from the command line and also from 3rd-party software"**
     - Isso permite usar `git` no PowerShell
   - Continue clicando em **"Next"** até **"Install"**
   - Aguarde a instalação

3. **Verificar Instalação:**
   - Feche e abra o PowerShell novamente
   - Digite: `git --version`
   - Deve aparecer algo como: `git version 2.43.0`

---

## ✅ Verificar se Funcionou

Abra um **novo** PowerShell e digite:

```powershell
git --version
```

Se aparecer a versão, está funcionando! ✅

---

## 🔧 Se Ainda Não Funcionar

### **Opção 1: Reiniciar o Computador**

Às vezes o PATH só é atualizado após reiniciar.

### **Opção 2: Adicionar ao PATH Manualmente**

1. Procure por **"Variáveis de Ambiente"** no Windows
2. Clique em **"Editar as variáveis de ambiente do sistema"**
3. Clique em **"Variáveis de Ambiente"**
4. Em **"Variáveis do sistema"**, encontre **"Path"**
5. Clique em **"Editar"**
6. Clique em **"Novo"**
7. Adicione: `C:\Program Files\Git\cmd`
8. Clique em **"OK"** em todas as janelas
9. Feche e abra o PowerShell novamente

### **Opção 3: Usar Git Bash**

O Git vem com o **Git Bash**, que é um terminal alternativo:

1. Procure por **"Git Bash"** no menu Iniciar
2. Abra o Git Bash
3. Use os comandos normalmente (funciona igual)

---

## 🎯 Próximos Passos

Após instalar o Git:

1. Configure seu nome e email:
   ```bash
   git config --global user.name "Seu Nome"
   git config --global user.email "seu@email.com"
   ```

2. Teste se funciona:
   ```bash
   git status
   ```

---

## 📞 Precisa de Ajuda?

- **Documentação oficial:** https://git-scm.com/doc
- **Guia de instalação:** https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

---

**✅ Após instalar, volte ao `GUIA_COMPLETO_IOS_SEM_MAC.md` e continue de onde parou!**
