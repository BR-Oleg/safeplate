# 🔧 Solução: Erro 408 ao Fazer Push no GitHub

Se você recebeu o erro:
```
error: RPC failed; HTTP 408 curl 22 The requested URL returned error: 408
fatal: the remote end hung up unexpectedly
```

Isso geralmente acontece quando:
- O repositório é muito grande (>100MB)
- A conexão é lenta ou instável
- Há arquivos grandes que não deveriam estar no Git

---

## ✅ Solução Rápida (Já Aplicada)

As seguintes configurações já foram aplicadas automaticamente:

```bash
git config http.postBuffer 524288000      # Buffer de 500MB
git config http.maxRequestBuffer 100M      # Buffer máximo de 100MB
git config core.compression 0              # Desabilitar compressão (mais rápido)
```

---

## 🚀 Tentar Push Novamente

Agora tente fazer push novamente:

```bash
git push -u origin main
```

---

## 🔍 Se Ainda Der Erro: Verificar Arquivos Grandes

### **1. Verificar Tamanho do Repositório**

```bash
# Ver tamanho total
git count-objects -vH

# Ver arquivos maiores que 1MB
git ls-files | ForEach-Object { Get-Item $_ -ErrorAction SilentlyContinue | Where-Object { $_.Length -gt 1MB } | Select-Object FullName, @{Name="SizeMB";Expression={[math]::Round($_.Length/1MB,2)}} } | Sort-Object SizeMB -Descending
```

### **2. Remover Arquivos Grandes do Git (Se Necessário)**

Se encontrar arquivos grandes que não deveriam estar no Git (PDFs, documentos, builds):

```bash
# Remover do Git (mas manter no disco)
git rm --cached "caminho/do/arquivo.pdf"

# Atualizar .gitignore
# Adicione o padrão do arquivo ao .gitignore

# Fazer commit
git add .gitignore
git commit -m "Remover arquivos grandes do Git"
```

### **3. Usar Git LFS para Arquivos Grandes**

Se você PRECISA versionar arquivos grandes (>50MB):

```bash
# Instalar Git LFS (se não tiver)
# Baixe: https://git-lfs.github.com/

# Inicializar Git LFS
git lfs install

# Rastrear arquivos grandes
git lfs track "*.pdf"
git lfs track "*.docx"

# Adicionar .gitattributes
git add .gitattributes
git commit -m "Adicionar Git LFS para arquivos grandes"
```

---

## 🌐 Alternativa: Push em Partes Menores

Se o repositório for muito grande, você pode fazer push em partes:

### **Método 1: Push Shallow (Mais Rápido)**

```bash
# Fazer push apenas do commit atual
git push -u origin main --depth=1
```

### **Método 2: Dividir em Commits Menores**

```bash
# Fazer push de commits menores
git push -u origin main --no-verify
```

### **Método 3: Usar SSH em Vez de HTTPS**

SSH geralmente é mais estável para pushs grandes:

```bash
# Mudar remote para SSH
git remote set-url origin git@github.com:SEU-USUARIO/prato-seguro.git

# Tentar push novamente
git push -u origin main
```

**Para usar SSH, você precisa:**
1. Gerar chave SSH: `ssh-keygen -t ed25519 -C "seu@email.com"`
2. Adicionar ao GitHub: Settings → SSH and GPG keys → New SSH key

---

## 📦 Verificar o Que Está Sendo Enviado

```bash
# Ver todos os arquivos rastreados
git ls-files

# Ver tamanho de cada arquivo
git ls-files | ForEach-Object { Get-Item $_ -ErrorAction SilentlyContinue | Select-Object FullName, @{Name="SizeKB";Expression={[math]::Round($_.Length/1KB,2)}} } | Sort-Object SizeKB -Descending | Select-Object -First 30
```

---

## ✅ Verificar .gitignore

Certifique-se de que o `.gitignore` está ignorando:

- ✅ `build/` e `**/build/`
- ✅ `node_modules/` e `**/node_modules/`
- ✅ `*.apk`, `*.ipa`, `*.zip`
- ✅ `*.pdf`, `*.docx` (documentos grandes)
- ✅ `.gradle/`, `android/build/`
- ✅ Arquivos de configuração local

---

## 🔄 Resetar e Tentar Novamente

Se nada funcionar, você pode resetar o commit e tentar novamente:

```bash
# Ver último commit
git log --oneline -1

# Resetar (mantém arquivos)
git reset --soft HEAD~1

# Remover arquivos grandes do staging
git reset HEAD "caminho/arquivo-grande.pdf"

# Adicionar apenas arquivos necessários
git add lib/ android/ ios/ pubspec.yaml .gitignore

# Fazer commit menor
git commit -m "Código fonte do app Prato Seguro"

# Tentar push
git push -u origin main
```

---

## 📞 Ajuda Adicional

- **GitHub Docs:** https://docs.github.com/en/get-started/getting-started-with-git
- **Git LFS:** https://git-lfs.github.com/
- **Tamanho máximo do GitHub:** 100MB por arquivo (recomendado usar Git LFS)

---

**✅ Tente fazer push novamente agora!**

