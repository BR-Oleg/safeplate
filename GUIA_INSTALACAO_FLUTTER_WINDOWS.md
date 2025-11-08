# 🚀 Guia Completo: Instalar Flutter no Windows

Este guia explica passo a passo como instalar o Flutter no Windows para começar a desenvolver o SafePlate.

## 📋 Requisitos do Sistema

- **Windows 10 ou superior** (64-bit)
- **Espaço em disco**: Pelo menos 2.8 GB (sem considerar IDE/tools)
- **PowerShell 5.0 ou superior** (já vem com Windows 10)

## 🔧 Passo 1: Baixar o Flutter SDK

### Opção A: Download Direto (Recomendado)

1. Acesse: https://docs.flutter.dev/get-started/install/windows
2. Clique em **"Download Flutter SDK"**
3. Baixe o arquivo ZIP (aprox. 1.5 GB)
4. **NÃO** extraia no caminho `C:\Program Files\` (permissões podem causar problemas)

### Opção B: GitHub

```powershell
# Clonar do GitHub (mais lento, mas atualizado)
git clone https://github.com/flutter/flutter.git -b stable
```

## 📂 Passo 2: Extrair o Flutter

1. Extraia o ZIP baixado em um local de fácil acesso, por exemplo:
   ```
   C:\src\flutter
   ```
   ou
   ```
   C:\flutter
   ```
   ou
   ```
   C:\Users\[SeuUsuario]\flutter
   ```

⚠️ **Importante**: Não coloque o Flutter em pastas com espaços ou caracteres especiais no nome.

## 🌐 Passo 3: Adicionar Flutter ao PATH

### Método 1: Pelo Painel de Controle (Recomendado)

1. Pressione `Win + X` e escolha **"Sistema"**
2. Clique em **"Configurações avançadas do sistema"**
3. Clique em **"Variáveis de Ambiente"**
4. Na seção **"Variáveis do sistema"**, encontre a variável `Path`
5. Clique em **"Editar"**
6. Clique em **"Novo"**
7. Adicione o caminho completo até a pasta `bin` do Flutter:
   ```
   C:\src\flutter\bin
   ```
   (Substitua pelo seu caminho real)
8. Clique em **"OK"** em todas as janelas

### Método 2: Pelo PowerShell (Administrador)

```powershell
# Substitua o caminho pelo seu
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\src\flutter\bin", [EnvironmentVariableTarget]::Machine)
```

### Método 3: Temporário (apenas para esta sessão)

```powershell
$env:Path += ";C:\src\flutter\bin"
```

## ✅ Passo 4: Verificar Instalação

1. **Feche e reabra** o terminal/PowerShell (para recarregar o PATH)

2. Execute:
```powershell
flutter --version
```

Você deve ver algo como:
```
Flutter 3.x.x • channel stable • https://github.com/flutter/flutter.git
Framework • revision xxxxx
Engine • revision xxxxx
Tools • Dart 3.x.x • DevTools 2.x.x
```

## 🔍 Passo 5: Executar Flutter Doctor

Execute o comando que verifica se tudo está configurado:

```powershell
flutter doctor
```

Isso mostrará o que está instalado e o que falta:

### ✅ O que você DEVE ter:
- [✓] Flutter (versão instalada)
- [✓] Windows Version (Windows 10 ou superior)

### ⚠️ O que você PRECISA instalar:

#### 1. **Visual Studio** (para compilar apps Windows)
- Baixe: https://visualstudio.microsoft.com/downloads/
- Durante instalação, marque:
  - **Desktop development with C++**
  - **Windows 10/11 SDK**

#### 2. **Android Studio** (para apps Android)
- Baixe: https://developer.android.com/studio
- Durante instalação, instale:
  - **Android SDK**
  - **Android SDK Platform-Tools**
  - **Android Emulator**

#### 3. **VS Code** (Editor de código - opcional mas recomendado)
- Baixe: https://code.visualstudio.com/
- Instale extensão **Flutter** no VS Code

#### 4. **Git** (para versionamento)
- Geralmente já vem instalado com Windows 10
- Se não tiver: https://git-scm.com/download/win

## 🎯 Passo 6: Aceitar Licenças Android

Se você for desenvolver para Android:

```powershell
flutter doctor --android-licenses
```

Pressione `y` para aceitar todas as licenças.

## 🧪 Passo 7: Criar e Testar um App

```powershell
# Criar um app de teste
flutter create meu_teste

# Entrar na pasta
cd meu_teste

# Executar
flutter run
```

## 🚨 Problemas Comuns

### "Flutter não é reconhecido como comando"

**Solução**: O PATH não foi configurado corretamente.
1. Verifique se o caminho está correto no PATH
2. Feche e reabra o terminal
3. Tente reiniciar o computador

### "PowerShell não pode executar scripts"

**Solução**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Erro ao baixar dependências"

**Solução**: Verifique sua conexão com a internet. O Flutter precisa baixar várias ferramentas.

## ✅ Checklist Final

Antes de começar a desenvolver:

- [ ] Flutter instalado e no PATH
- [ ] `flutter doctor` mostra Flutter como instalado
- [ ] Visual Studio instalado (se for desenvolver para Windows)
- [ ] Android Studio instalado (se for desenvolver para Android)
- [ ] Licenças Android aceitas
- [ ] Testou criar e executar um app de teste

## 🎉 Próximo Passo

Agora você pode instalar as dependências do SafePlate:

```powershell
cd "C:\apkpratoseguro"
flutter pub get
```

## 📚 Links Úteis

- **Documentação Flutter**: https://docs.flutter.dev/
- **Flutter Doctor**: https://docs.flutter.dev/get-started/install/windows#run-flutter-doctor
- **Troubleshooting**: https://docs.flutter.dev/get-started/install/windows#troubleshooting

## 💡 Dica

Para facilitar, você pode usar o **Flutter Installer**:
- Baixe: https://docs.flutter.dev/get-started/install/windows#install-flutter-manually
- Isso instala tudo automaticamente, mas pode ser mais lento.

---

**Depois de instalar o Flutter, volte aqui e execute:**
```powershell
flutter pub get
```
na pasta do projeto SafePlate!


