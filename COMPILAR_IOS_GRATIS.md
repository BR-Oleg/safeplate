# 🍎 Compilar iOS GRÁTIS - Guia Completo

Este guia mostra como compilar e testar o app **Prato Seguro** no iOS **SEM** precisar de:
- ❌ Mac físico
- ❌ Conta Apple Developer paga ($99/ano)
- ❌ iPhone físico (inicialmente)
- ❌ Dinheiro

## 🎯 Solução: GitHub Actions (100% Grátis)

O GitHub Actions oferece **2000 minutos/mês grátis** para repositórios privados (ilimitado para públicos), o que é mais que suficiente para compilar iOS.

---

## 📋 Pré-requisitos

1. ✅ Conta no GitHub (grátis)
2. ✅ Repositório do projeto no GitHub
3. ✅ iPhone do cliente (para testar)
4. ✅ Computador Windows (o seu)

---

## 🚀 Passo a Passo Completo

### **Passo 1: Preparar o Repositório**

```bash
# No seu computador
cd c:\apkpratoseguro
git add .
git commit -m "Preparar para build iOS"
git push origin main
```

### **Passo 2: Executar Build no GitHub**

1. Acesse seu repositório no GitHub
2. Vá em **Actions** (menu superior)
3. Selecione **"Build iOS App"** no menu lateral
4. Clique em **"Run workflow"** → **"Run workflow"**
5. Aguarde ~10-15 minutos

### **Passo 3: Baixar o IPA**

1. Após o build completar, clique no workflow executado
2. Role até **"Artifacts"**
3. Baixe **"ios-build-X"** (arquivo ZIP)
4. Extraia o ZIP
5. Você terá o arquivo **`PratoSeguro-ios-X.ipa`**

---

## 📱 Instalar no iPhone (SEM Conta Paga)

### **Opção A: AltStore (Recomendado - Mais Fácil)**

#### **1. Instalar AltStore no iPhone**

1. No iPhone, abra o Safari
2. Acesse: **https://altstore.io**
3. Toque em **"Download AltStore"**
4. Instale o perfil de confiança (Settings → General → VPN & Device Management)
5. Abra o AltStore

#### **2. Conectar iPhone ao Computador**

1. Conecte o iPhone ao computador via USB
2. Abra o **iTunes** (Windows) ou **Finder** (Mac)
3. Confie no computador no iPhone

#### **3. Instalar AltServer no Windows**

1. Baixe: **https://altstore.io/AltInstaller.exe**
2. Execute o instalador
3. Abra o **AltServer** (ícone na bandeja do sistema)
4. Clique com botão direito → **"Install AltStore"** → Selecione seu iPhone

#### **4. Instalar o App**

1. No iPhone, abra o **AltStore**
2. Toque em **"My Apps"** → **"+"** (canto superior direito)
3. Selecione o arquivo **`PratoSeguro-ios-X.ipa`**
4. Aguarde a instalação

**⚠️ IMPORTANTE:** O app expira em **7 dias**. Para renovar:
- Abra o AltStore no iPhone
- Toque em **"Refresh All"**
- Ou conecte o iPhone ao computador e renove via AltServer

---

### **Opção B: Sideloadly (Alternativa)**

#### **1. Baixar Sideloadly**

1. Acesse: **https://sideloadly.io**
2. Baixe para Windows
3. Instale

#### **2. Instalar o App**

1. Conecte o iPhone ao computador
2. Abra o **Sideloadly**
3. Arraste o arquivo **`PratoSeguro-ios-X.ipa`** para o Sideloadly
4. Selecione seu iPhone
5. Clique em **"Start"**
6. Digite sua **Apple ID** e senha (não precisa ser paga!)
7. Aguarde a instalação

**⚠️ IMPORTANTE:** O app expira em **7 dias**. Renove repetindo o processo.

---

## 🔄 Renovação Automática (AltStore)

Para renovar automaticamente:

1. No Windows, abra o **AltServer**
2. Clique com botão direito → **"Install Mail Plug-in"**
3. Configure o **Mail** do Windows (se necessário)
4. O AltStore renovará automaticamente quando o iPhone estiver na mesma rede Wi-Fi

---

## 🐛 Solução de Problemas

### **Erro: "Unable to verify app"**

**Solução:**
1. Vá em **Settings → General → VPN & Device Management**
2. Toque no seu perfil de desenvolvedor
3. Toque em **"Trust"**

### **Erro: "App expired"**

**Solução:**
- Renove o app via AltStore ou Sideloadly (veja acima)

### **Build falha no GitHub Actions**

**Solução:**
1. Verifique os logs do workflow
2. Verifique se o `pubspec.yaml` está correto
3. Verifique se todas as dependências estão atualizadas

### **iPhone não aparece no AltServer/Sideloadly**

**Solução:**
1. Desconecte e reconecte o iPhone
2. Confie no computador no iPhone
3. Verifique se o cabo USB está funcionando
4. Tente outro cabo USB

---

## 📊 Comparação de Métodos

| Método | Custo | Facilidade | Renovação | Recomendado |
|--------|-------|------------|-----------|-------------|
| **AltStore** | Grátis | ⭐⭐⭐⭐⭐ | Automática | ✅ Sim |
| **Sideloadly** | Grátis | ⭐⭐⭐⭐ | Manual | ✅ Sim |
| **TestFlight** | $99/ano | ⭐⭐⭐ | Automática | ❌ Requer pago |
| **App Store** | $99/ano | ⭐⭐⭐⭐⭐ | Permanente | ❌ Requer pago |

---

## 🎯 Para o Cliente

### **Instruções para o Cliente (Versão Simples)**

Envie estas instruções para o cliente:

```
📱 Como Instalar o Prato Seguro no iPhone

1. Conecte seu iPhone ao computador via cabo USB
2. Abra o arquivo "PratoSeguro-ios-X.ipa" no Sideloadly
   (ou envie o arquivo para o cliente instalar via AltStore)
3. Siga as instruções na tela
4. No iPhone: Settings → General → VPN & Device Management → Trust

⚠️ O app expira em 7 dias. Para renovar, repita o processo.
```

---

## 🔐 Segurança

- ✅ O app é assinado com sua Apple ID (não paga)
- ✅ Funciona apenas no iPhone que você configurou
- ✅ Não requer jailbreak
- ✅ Totalmente seguro e legal

---

## 📞 Suporte

Se tiver problemas:
1. Verifique os logs do GitHub Actions
2. Verifique se o iPhone está conectado corretamente
3. Tente outro método (AltStore ou Sideloadly)

---

## ✅ Checklist Final

- [ ] Repositório no GitHub
- [ ] Build executado no GitHub Actions
- [ ] IPA baixado
- [ ] AltStore ou Sideloadly instalado
- [ ] iPhone conectado
- [ ] App instalado no iPhone
- [ ] App testado e funcionando
- [ ] Cliente instruído sobre renovação

---

**🎉 Pronto! Agora você pode compilar e testar iOS sem Mac e sem conta paga!**

