# 📦 MOVER PROJETO PARA C:\

## 🎯 Objetivo

Mover o projeto de `C:\Users\Bruna B\Desktop\apkpratoseguro` para `C:\apkpratoseguro` para evitar problemas com espaços no caminho.

## ⚠️ ANTES DE COMEÇAR

**FECHE TODOS OS PROGRAMAS QUE PODEM ESTAR USANDO O PROJETO:**
- ✅ Android Studio
- ✅ VS Code / Cursor
- ✅ Terminais PowerShell
- ✅ Qualquer outro editor
- ✅ Qualquer processo Flutter em execução

## 🚀 OPÇÃO 1: Usar o Script Automático (Recomendado)

1. **Feche todos os programas acima**
2. **Execute:**
   ```bash
   MOVER_PROJETO.bat
   ```
3. **Aguarde a conclusão**

## 🚀 OPÇÃO 2: Mover Manualmente pelo Explorador

1. **Feche todos os programas acima**
2. **Abra o Explorador de Arquivos**
3. **Navegue até:** `C:\Users\Bruna B\Desktop\`
4. **Clique com o botão direito** em `apkpratoseguro`
5. **Escolha "Cortar"** (Ctrl+X)
6. **Navegue até:** `C:\`
7. **Cole** (Ctrl+V)
8. **Aguarde a conclusão**

## 🚀 OPÇÃO 3: Mover pelo PowerShell (Após Fechar Programas)

1. **Feche todos os programas acima**
2. **Abra PowerShell como Administrador**
3. **Execute:**
   ```powershell
   Move-Item -Path "C:\Users\Bruna B\Desktop\apkpratoseguro" -Destination "C:\apkpratoseguro" -Force
   ```

## ✅ APÓS MOVER

1. **Navegue até o novo diretório:**
   ```bash
   cd C:\apkpratoseguro
   ```

2. **Atualize o local.properties (se necessário):**
   ```bash
   notepad android\local.properties
   ```
   
   Certifique-se de que os caminhos estão corretos:
   ```
   flutter.sdk=C:/src/flutter
   sdk.dir=C:/Users/Bruna B/AppData/Local/Android/sdk
   ```

3. **Execute o app com logs:**
   ```bash
   flutter run -d ZF524HHBBN
   ```

## 🎉 VANTAGENS DO NOVO CAMINHO

- ✅ **Sem espaços no caminho** - Resolve problemas com Gradle
- ✅ **Mais curto** - Caminhos mais simples
- ✅ **Mais rápido** - Melhor desempenho do build
- ✅ **Sem problemas** - Evita erros de compilação

---

**Depois de mover, execute `flutter run -d ZF524HHBBN` novamente!** 🚀

