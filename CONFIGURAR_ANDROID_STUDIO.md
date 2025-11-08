# 🔧 CONFIGURAR ANDROID STUDIO - Último Passo!

## ⚠️ Você precisa configurar o cmdline-tools

O Flutter detectou que falta o componente `cmdline-tools` do Android SDK.

## ✅ CONFIGURAR NO ANDROID STUDIO

### Passo 1: Abrir Android Studio

1. Abra o **Android Studio**
2. Se for a primeira vez, complete o assistente de configuração
3. Aceite todas as licenças quando solicitado

### Passo 2: Instalar SDK Components

1. **No Android Studio:**
   - File > Settings (ou Configure > Settings)
   - Appearance & Behavior > System Settings > **Android SDK**

2. **Na aba SDK Platforms:**
   - Marque a versão mais recente do Android (API 33, 34 ou 35)
   - Clique em **Apply** e aguarde instalar

3. **Na aba SDK Tools:**
   - Marque **Android SDK Command-line Tools (latest)**
   - Marque **Android SDK Platform-Tools**
   - Marque **Android SDK Build-Tools**
   - Clique em **Apply** e aguarde instalar

### Passo 3: Aceitar Licenças

1. **No terminal/PowerShell:**
   ```bash
   flutter doctor --android-licenses
   ```
   
2. **Para cada licença:**
   - Digite `y` (yes) e pressione Enter
   - Repita até aceitar todas

### Passo 4: Verificar Configuração

```bash
flutter doctor
```

Agora deve mostrar:
```
[√] Android toolchain - develop for Android devices
```

## 📱 CONFIGURAR TELEFONE

### Passo 1: Ativar Depuração USB no Telefone

1. **No telefone:**
   - Configurações > **Sobre o telefone**
   - Toque **7 vezes** em "Número da versão" (ou "Versão do Android")
   - Aparecerá: "Você se tornou um desenvolvedor!"

2. **Voltar:**
   - Configurações > **Sistema** > **Opções do desenvolvedor**
   - Ative **"Opções do desenvolvedor"** (toggle no topo)
   - Ative **"Depuração USB"**

### Passo 2: Conectar Telefone via USB

1. **Conecte o telefone ao computador via USB**

2. **Quando aparecer no telefone:**
   - "Permitir depuração USB?"
   - Marque **"Sempre permitir deste computador"**
   - Toque em **"Permitir"**

### Passo 3: Verificar Conexão

```bash
flutter devices
```

**Você deve ver algo como:**
```
Android Phone (mobile) • ABC123XYZ • android-arm64 • Android 13 (API 33)
```

## 🚀 EXECUTAR APP NO TELEFONE

Depois que tudo estiver configurado:

```bash
flutter run
```

O app vai:
- Compilar automaticamente
- Instalar no telefone
- Abrir automaticamente no telefone!

## ✅ CHECKLIST

- [ ] Android Studio instalado ✅
- [ ] cmdline-tools instalado (no Android Studio)
- [ ] Licenças aceitas (`flutter doctor --android-licenses`)
- [ ] Depuração USB ativada no telefone
- [ ] Telefone conectado via USB
- [ ] Depuração USB permitida (popup aceito)
- [ ] `flutter devices` mostra o telefone

## 🎯 PRÓXIMOS PASSOS

1. **Configure o cmdline-tools no Android Studio** (veja Passo 2 acima)
2. **Aceite as licenças:** `flutter doctor --android-licenses`
3. **Conecte o telefone e ative depuração USB**
4. **Execute:** `flutter run` ou `RODAR_NO_TELEFONE.bat`

---

**Depois disso, você pode testar o app diretamente no telefone!** 🎉

