# 🍎 Guia Completo: Compilar e Testar iOS SEM Mac

**Versão:** 1.0  
**Data:** 2024  
**Autor:** Guia Prato Seguro

---

## 📋 Índice

1. [Pré-requisitos](#pré-requisitos)
2. [Preparação Inicial](#preparação-inicial)
3. [Configurar GitHub](#configurar-github)
4. [Testar no Simulador (Screenshots)](#testar-no-simulador-screenshots)
5. [Compilar IPA para iPhone](#compilar-ipa-para-iphone)
6. [Instalar no iPhone (Sideloadly)](#instalar-no-iphone-sideloadly)
7. [Instalar no iPhone (AltStore)](#instalar-no-iphone-altstore)
8. [Renovar App (Após 7 Dias)](#renovar-app-após-7-dias)
9. [Solução de Problemas](#solução-de-problemas)
10. [Checklist Final](#checklist-final)

---

## 📋 Pré-requisitos

### ✅ O Que Você Precisa Ter

- [ ] **Git instalado** (necessário para GitHub) - Veja `INSTALAR_GIT.md` se não tiver
- [ ] **Conta GitHub** (grátis) - https://github.com/signup
- [ ] **Repositório no GitHub** (pode ser privado)
- [ ] **Computador Windows** (o seu)
- [ ] **iPhone do cliente** (para instalação final)
- [ ] **Cabo USB** (iPhone → Computador)
- [ ] **Conexão com internet** (estável)

### ❌ O Que Você NÃO Precisa

- ❌ Mac físico
- ❌ Conta Apple Developer paga ($99/ano)
- ❌ iPhone próprio
- ❌ Dinheiro para pagar serviços

---

## 🚀 Preparação Inicial

### **Passo 0: Instalar Git (Se Não Tiver)**

**⚠️ IMPORTANTE:** Se você recebeu erro "git não é reconhecido", precisa instalar o Git primeiro!

1. Veja o arquivo **`INSTALAR_GIT.md`** para instruções detalhadas
2. Ou baixe diretamente: https://git-scm.com/download/win
3. Instale seguindo o assistente
4. **Reinicie o PowerShell** após instalar
5. Teste digitando: `git --version`

Se aparecer a versão, está funcionando! ✅

---

### **Passo 1: Verificar Código Local**

Abra o terminal no seu computador e vá até a pasta do projeto:

```bash
cd c:\apkpratoseguro
```

Verifique se o código está atualizado:

```bash
git status
```

**Se der erro "git não é reconhecido":**
- Veja o **Passo 0** acima para instalar o Git

**Se der erro "not a git repository":**
- O repositório Git já foi inicializado automaticamente
- Veja o arquivo **`CONFIGURAR_GIT_REPOSITORIO.md`** para conectar ao GitHub
- Ou continue abaixo se já estiver conectado

Se houver arquivos modificados ou se for o primeiro commit, faça commit:

```bash
git add .
git commit -m "Preparar para build iOS"
```

### **Passo 2: Conectar ao GitHub (Se Ainda Não Conectou)**

**⚠️ IMPORTANTE:** Se você ainda não conectou este projeto ao GitHub:

1. Veja o arquivo **`CONFIGURAR_GIT_REPOSITORIO.md`** para instruções completas
2. Ou siga os passos rápidos abaixo:

```bash
# Adicionar remote (substitua SEU-USUARIO pelo seu usuário GitHub)
git remote add origin https://github.com/SEU-USUARIO/prato-seguro.git

# Verificar se foi adicionado
git remote -v
```

**Se der erro "remote origin already exists":**
- Isso significa que já está conectado, pode pular este passo ✅

**Se não tiver repositório no GitHub ainda:**
- Crie em: https://github.com/new
- Depois execute os comandos acima

---

### **Passo 3: Verificar Arquivos iOS**

Certifique-se de que a pasta `ios/` existe e tem os arquivos necessários:

```bash
dir ios
```

Você deve ver:
- `Runner/`
- `Runner.xcodeproj/`
- `Runner.xcworkspace/`
- `Podfile`

Se não existir, o Flutter criará automaticamente quando você fizer o build.

### **Passo 3: Verificar pubspec.yaml**

Abra o arquivo `pubspec.yaml` e verifique se a versão está correta:

```yaml
name: safeplate
version: 1.1.0+1  # ← Verifique esta linha
```

---

## 🔧 Configurar GitHub

### **Passo 1: Criar Repositório (Se Não Tiver)**

1. Acesse: https://github.com/new
2. Nome do repositório: `prato-seguro` (ou o nome que preferir)
3. Marque como **Private** (se quiser)
4. **NÃO** marque "Add README" (já temos arquivos)
5. Clique em **"Create repository"**

### **Passo 2: Conectar Repositório Local ao GitHub**

Se ainda não conectou seu projeto ao GitHub:

```bash
# Adicionar remote (substitua SEU-USUARIO pelo seu usuário GitHub)
git remote add origin https://github.com/SEU-USUARIO/prato-seguro.git

# Verificar se foi adicionado
git remote -v
```

### **Passo 3: Fazer Push do Código**

```bash
# Fazer push para o GitHub
git push -u origin main
```

Se der erro de branch, tente:

```bash
git push -u origin master
```

### **Passo 4: Verificar no GitHub**

1. Acesse: https://github.com/SEU-USUARIO/prato-seguro
2. Verifique se todos os arquivos estão lá
3. Verifique se a pasta `.github/workflows/` existe

---

## 📸 Testar no Simulador (Screenshots)

**Objetivo:** Ver como o app fica no iPhone antes de instalar no dispositivo físico.

### **Passo 1: Executar Workflow de Teste**

1. Acesse: https://github.com/SEU-USUARIO/prato-seguro/actions
2. No menu lateral, procure por **"Test iOS App in Simulator"**
3. Clique em **"Run workflow"** (botão no topo direito)
4. Deixe tudo como está (não precisa mudar nada)
5. Clique em **"Run workflow"** (botão verde)

### **Passo 2: Aguardar Execução**

- ⏱️ **Tempo estimado:** 5-10 minutos
- Você verá os passos sendo executados em tempo real
- Aguarde até ver ✅ verde em todos os passos

### **Passo 3: Baixar Screenshots**

1. Após o workflow completar, clique nele
2. Role até a seção **"Artifacts"** (no final da página)
3. Clique em **"ios-simulator-screenshots-X"**
4. O arquivo ZIP será baixado automaticamente
5. Extraia o ZIP
6. Abra a pasta `screenshots/`
7. Veja as imagens `.png` do app rodando no iPhone Simulator

### **O Que Você Verá:**

- ✅ Screenshot da tela inicial
- ✅ Screenshot de outras telas
- ✅ Confirmação de que o app compila sem erros

### **Se Quiser Ver Vídeo:**

1. Abra o arquivo: `.github/workflows/ios-simulator-test.yml`
2. Procure a linha: `if: false  # Desabilitado por padrão`
3. Mude para: `if: true`
4. Salve e faça commit:
   ```bash
   git add .github/workflows/ios-simulator-test.yml
   git commit -m "Habilitar gravação de vídeo"
   git push
   ```
5. Execute o workflow novamente
6. Você receberá um arquivo `demo.mp4` nos artifacts

---

## 📦 Compilar IPA para iPhone

**Objetivo:** Gerar o arquivo `.ipa` que será instalado no iPhone do cliente.

### **Passo 1: Executar Workflow de Build**

1. Acesse: https://github.com/SEU-USUARIO/prato-seguro/actions
2. No menu lateral, procure por **"Build iOS App"**
3. Clique em **"Run workflow"**
4. Deixe tudo como está
5. Clique em **"Run workflow"**

### **Passo 2: Aguardar Compilação**

- ⏱️ **Tempo estimado:** 10-15 minutos
- Você verá os passos sendo executados:
  - ✅ Setup Flutter
  - ✅ Install CocoaPods
  - ✅ Build iOS
  - ✅ Create IPA Archive
  - ✅ Upload build artifacts

### **Passo 3: Baixar o IPA**

1. Após o workflow completar, clique nele
2. Role até **"Artifacts"**
3. Clique em **"ios-build-X"**
4. O arquivo ZIP será baixado
5. Extraia o ZIP
6. Você terá o arquivo **`PratoSeguro-ios-X.ipa`**

### **⚠️ IMPORTANTE:**

- O arquivo `.ipa` é o que você vai instalar no iPhone
- Guarde este arquivo em local seguro
- Você precisará dele toda vez que renovar o app (a cada 7 dias)

---

## 📱 Instalar no iPhone (Sideloadly)

**Método Recomendado:** Mais simples e direto.

### **Passo 1: Baixar Sideloadly**

1. Acesse: https://sideloadly.io
2. Clique em **"Download for Windows"**
3. Baixe o instalador
4. Execute o instalador
5. Instale o Sideloadly (siga o assistente)

### **Passo 2: Preparar iPhone**

1. **Desbloqueie o iPhone** (digite a senha)
2. **Conecte o iPhone ao computador** via cabo USB
3. No iPhone, aparecerá: **"Trust This Computer?"**
4. Toque em **"Trust"**
5. Digite a senha do iPhone (se solicitado)
6. Aguarde alguns segundos

### **Passo 3: Abrir Sideloadly**

1. Abra o **Sideloadly** (ícone na área de trabalho ou menu Iniciar)
2. A interface abrirá

### **Passo 4: Instalar o App**

1. **Arraste o arquivo `.ipa`** para a área do Sideloadly
   - Ou clique em **"Select IPA"** e escolha o arquivo
2. O Sideloadly detectará seu iPhone automaticamente
3. Se aparecer mais de um dispositivo, selecione o iPhone correto
4. Clique no botão **"Start"** (ou "Iniciar")
5. Uma janela pedirá sua **Apple ID**:
   - Digite seu email da Apple (qualquer conta Apple ID, não precisa ser paga!)
   - Digite sua senha
   - ⚠️ **Se tiver autenticação de dois fatores:**
     - Vá em: https://appleid.apple.com
     - Faça login
     - Vá em **"App-Specific Passwords"**
     - Crie uma senha de app
     - Use essa senha no Sideloadly (não a senha normal)
6. Clique em **"OK"** ou **"Start"**
7. Aguarde a instalação (2-5 minutos)
   - Você verá o progresso na tela
   - **NÃO desconecte o iPhone** durante a instalação

### **Passo 5: Confiar no App (IMPORTANTE!)**

1. No iPhone, vá em **Settings** (Configurações)
2. Toque em **General** (Geral)
3. Role até **VPN & Device Management** (Gerenciamento de Dispositivo)
4. Toque no seu perfil de desenvolvedor (seu email)
5. Toque em **"Trust [seu email]"**
6. Confirme toque em **"Trust"** novamente

### **Passo 6: Abrir o App**

1. Procure o ícone **"Prato Seguro"** na tela inicial do iPhone
2. Toque para abrir
3. ✅ **Pronto!** O app está funcionando!

---

## 📱 Instalar no iPhone (AltStore)

**Método Alternativo:** Com renovação automática.

### **Passo 1: Instalar AltServer no Windows**

1. Acesse: https://altstore.io
2. Clique em **"Download AltServer"**
3. Baixe **"AltInstaller.exe"** para Windows
4. Execute o instalador
5. Siga o assistente de instalação
6. O AltServer será instalado

### **Passo 2: Instalar AltStore no iPhone**

1. No iPhone, abra o **Safari**
2. Acesse: https://altstore.io
3. Toque em **"Download AltStore"**
4. Toque em **"Download"** (ou "Instalar")
5. Uma mensagem aparecerá: **"This website is trying to download a configuration profile"**
6. Toque em **"Allow"**
7. Vá em **Settings → General → VPN & Device Management**
8. Toque no perfil **"AltStore"**
9. Toque em **"Install"**
10. Digite a senha do iPhone
11. Confirme a instalação
12. O AltStore aparecerá na tela inicial

### **Passo 3: Conectar iPhone ao Computador**

1. Conecte o iPhone ao computador via cabo USB
2. Confie no computador no iPhone
3. Abra o **AltServer** (ícone na bandeja do sistema, próximo ao relógio)
4. Clique com botão direito no ícone do AltServer
5. Selecione **"Install AltStore"**
6. Escolha seu iPhone na lista
7. Digite sua Apple ID e senha
8. Aguarde a instalação

### **Passo 4: Instalar o App via AltStore**

1. No iPhone, abra o **AltStore**
2. Toque em **"My Apps"** (Meus Apps)
3. Toque no botão **"+"** (canto superior direito)
4. Selecione o arquivo **`.ipa`**
   - Você pode enviar o `.ipa` para o iPhone via AirDrop, email, ou iCloud
5. Aguarde a instalação
6. O app aparecerá na tela inicial

### **Passo 5: Configurar Renovação Automática (Opcional)**

1. No Windows, abra o **AltServer**
2. Clique com botão direito → **"Install Mail Plug-in"**
3. Configure o Mail do Windows (se necessário)
4. O AltStore renovará automaticamente quando o iPhone estiver na mesma rede Wi-Fi

---

## 🔄 Renovar App (Após 7 Dias)

**⚠️ IMPORTANTE:** O app expira em **7 dias**. Após isso, você precisa renovar.

### **Método 1: Via Sideloadly (Mais Simples)**

1. Conecte o iPhone ao computador
2. Abra o **Sideloadly**
3. Arraste o arquivo `.ipa` novamente
4. Clique em **"Start"**
5. Digite sua Apple ID e senha
6. Aguarde a renovação (1-2 minutos)
7. ✅ Pronto! O app está renovado por mais 7 dias

### **Método 2: Via AltStore (Automático)**

Se configurou a renovação automática:
- O AltStore renova sozinho quando o iPhone está na mesma rede Wi-Fi
- Ou abra o AltStore no iPhone e toque em **"Refresh All"**

Se não configurou:
- Conecte o iPhone ao computador
- Abra o AltServer
- Clique com botão direito → **"Refresh Apps"**
- Selecione seu iPhone

---

## 🐛 Solução de Problemas

### **Problema 1: "Unable to verify app"**

**Sintoma:** Ao tentar abrir o app, aparece "Unable to verify app".

**Solução:**
1. iPhone: **Settings → General → VPN & Device Management**
2. Toque no seu perfil de desenvolvedor
3. Toque em **"Trust"**
4. Confirme

### **Problema 2: "App expired"**

**Sintoma:** O app não abre e mostra "App expired".

**Solução:**
- Renove o app seguindo o passo [Renovar App](#renovar-app-após-7-dias)

### **Problema 3: iPhone não aparece no Sideloadly/AltServer**

**Sintoma:** O dispositivo não é detectado.

**Solução:**
1. Desconecte e reconecte o iPhone
2. No iPhone: **Settings → General → Reset → Reset Location & Privacy**
3. Confie no computador novamente
4. Tente outro cabo USB
5. Reinicie o Sideloadly/AltServer

### **Problema 4: Build falha no GitHub Actions**

**Sintoma:** O workflow mostra erro vermelho.

**Solução:**
1. Clique no workflow que falhou
2. Veja qual passo deu erro
3. Leia os logs (role até o passo que falhou)
4. Erros comuns:
   - **"CocoaPods error"** → Normal, tente novamente
   - **"Flutter version"** → Verifique se a versão está correta
   - **"Dependencies"** → Execute `flutter pub get` localmente e faça commit

### **Problema 5: "Invalid Apple ID" no Sideloadly**

**Sintoma:** Sideloadly rejeita a Apple ID.

**Solução:**
1. Verifique se a Apple ID está correta
2. Se tiver autenticação de dois fatores:
   - Crie uma senha de app em: https://appleid.apple.com
   - Use essa senha no Sideloadly
3. Tente outra Apple ID (qualquer uma funciona)

### **Problema 6: App não abre após instalação**

**Sintoma:** O app instala mas não abre.

**Solução:**
1. Verifique se confiou no perfil (Settings → General → VPN & Device Management)
2. Reinicie o iPhone
3. Reinstale o app

### **Problema 7: Screenshots não aparecem**

**Sintoma:** Workflow completa mas não há screenshots.

**Solução:**
1. Verifique se o app compilou corretamente
2. Veja os logs do workflow
3. Tente executar o workflow novamente

---

## ✅ Checklist Final

Use este checklist para garantir que tudo está pronto:

### **Antes de Compilar:**
- [ ] Código está no GitHub
- [ ] Workflow de teste executado com sucesso
- [ ] Screenshots visualizados e aprovados
- [ ] Arquivo `.ipa` baixado

### **Antes de Instalar:**
- [ ] Sideloadly ou AltStore instalado
- [ ] iPhone desbloqueado
- [ ] iPhone conectado ao computador
- [ ] Confiança no computador configurada no iPhone
- [ ] Apple ID pronta (ou senha de app criada)

### **Após Instalação:**
- [ ] App aparece na tela inicial
- [ ] Perfil de desenvolvedor confiado (Settings → General → VPN & Device Management)
- [ ] App abre sem erros
- [ ] Funcionalidades básicas testadas

### **Para o Cliente:**
- [ ] Instruções de renovação explicadas
- [ ] Arquivo `.ipa` guardado para futuras renovações
- [ ] Cliente sabe que precisa renovar a cada 7 dias

---

## 📞 Precisa de Ajuda?

### **Recursos Úteis:**

- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Sideloadly Docs:** https://sideloadly.io/docs
- **AltStore Docs:** https://altstore.io/faq

### **Logs e Debug:**

- **GitHub Actions Logs:** Veja os logs do workflow para entender erros
- **Sideloadly Logs:** Veja a janela do Sideloadly para mensagens de erro
- **iPhone Logs:** Settings → Privacy → Analytics & Improvements → Analytics Data

---

## 🎯 Resumo Rápido (TL;DR)

1. **Testar:** GitHub Actions → "Test iOS App in Simulator" → Baixar screenshots
2. **Compilar:** GitHub Actions → "Build iOS App" → Baixar `.ipa`
3. **Instalar:** Sideloadly → Arrastar `.ipa` → Digitar Apple ID → Instalar
4. **Confiar:** iPhone → Settings → General → VPN & Device Management → Trust
5. **Renovar:** Repetir passo 3 a cada 7 dias

---

## 🎉 Parabéns!

Agora você sabe como:
- ✅ Compilar iOS sem Mac
- ✅ Testar via screenshots
- ✅ Instalar no iPhone sem conta paga
- ✅ Renovar o app quando necessário

**Boa sorte com seu app!** 🚀

---

**Última atualização:** 2024  
**Versão do guia:** 1.0

