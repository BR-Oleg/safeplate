# 🔑 OBTER SHA-1 PARA GOOGLE SIGN-IN

## ⚠️ Problema

O Gradle precisa do JAVA_HOME configurado para obter o SHA-1.

## ✅ SOLUÇÃO

### Opção 1: Configurar JAVA_HOME Temporariamente (Recomendado)

**No PowerShell, execute:**

```powershell
# Configurar JAVA_HOME para esta sessão
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

# Ir para pasta android e obter SHA-1
cd android
.\gradlew signingReport
```

### Opção 2: Usar Java do Android Studio Diretamente

```powershell
cd android
& "C:\Program Files\Android\Android Studio\jbr\bin\java.exe" -version

# Depois configure JAVA_HOME
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
.\gradlew signingReport
```

### Opção 3: Configurar JAVA_HOME Permanentemente (Opcional)

1. **Encontre o Java do Android Studio:**
   - Geralmente em: `C:\Program Files\Android\Android Studio\jbr`
   - Ou em: `C:\Program Files\JetBrains\IntelliJ IDEA\jbr`

2. **Configure variável de ambiente:**
   - Windows + R → `sysdm.cpl` → OK
   - Aba "Avançado" → "Variáveis de Ambiente"
   - Em "Variáveis do sistema", clique em "Novo"
   - Nome: `JAVA_HOME`
   - Valor: `C:\Program Files\Android\Android Studio\jbr`
   - OK em tudo
   - **Reinicie o PowerShell**

3. **Depois execute:**
   ```bash
   cd android
   .\gradlew signingReport
   ```

## 📋 O QUE FAZER COM O SHA-1

Depois de obter o SHA-1:

1. **Copiar o SHA-1** (formato: `AA:BB:CC:DD:EE:...`)

2. **Adicionar no Firebase Console:**
   - https://console.firebase.google.com/project/safeplate-a14e9/settings/general
   - "Your apps" > Android app (safeplate)
   - Role até "SHA certificate fingerprints"
   - Clique em "Add fingerprint"
   - Cole o SHA-1
   - Salve

3. **Recompilar o app** (não precisa, mas pode ajudar)

## 🚀 COMANDO RÁPIDO

```powershell
cd "C:\Users\Bruna B\Desktop\apkpratoseguro"
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
cd android
.\gradlew signingReport
```

---

**Execute o comando rápido acima para obter o SHA-1!** 🔑

