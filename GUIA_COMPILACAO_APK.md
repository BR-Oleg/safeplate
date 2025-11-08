# 📱 GUIA COMPLETO: Compilar e Instalar APK no Telefone

## ⚠️ IMPORTANTE: Você precisa do Android SDK

Para compilar o APK, você precisa instalar o **Android Studio** (que inclui o Android SDK).

### Opção 1: Instalar Android Studio (Recomendado para compilar)

1. **Baixar Android Studio:**
   - https://developer.android.com/studio
   - Baixe e instale

2. **Configurar no Flutter:**
   ```bash
   flutter doctor
   ```
   - Ele vai mostrar o que falta
   - Execute: `flutter doctor --android-licenses` e aceite todas as licenças

3. **Compilar o APK:**
   ```bash
   flutter build apk --release
   ```

### Opção 2: Compilar sem Android Studio (Alternativa)

Se você tiver outro computador com Android Studio configurado, pode compilar lá e transferir o APK.

---

## 🚀 COMPILANDO O APK (Quando tiver Android SDK)

### Método 1: Usando o Script (Mais Fácil) ⭐

1. **Execute:**
   ```bash
   COMPILAR_APK.bat
   ```

2. **Escolha a opção 2** (APK Release - Recomendado)

### Método 2: Comando Direto

```bash
flutter build apk --release
```

**O arquivo estará em:**
- `build\app\outputs\flutter-apk\app-release.apk`

### Método 3: APK Menor (Split por ABI)

```bash
flutter build apk --split-per-abi --release
```

**Arquivos:**
- `build\app\outputs\flutter-apk\app-arm64-v8a-release.apk` (64-bit - Use este!) ⭐
- `build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk` (32-bit)

---

## 📲 INSTALANDO NO TELEFONE

### Método 1: Via USB (Automático) ⭐

**Pré-requisitos:**
1. **Ative Depuração USB no telefone:**
   - Configurações > Sobre o telefone
   - Toque 7 vezes em "Número da versão" (ativa Opções do Desenvolvedor)
   - Configurações > Sistema > Opções do desenvolvedor
   - Ative "Depuração USB"

2. **Conecte o telefone via USB ao computador**

3. **Verifique conexão:**
   ```bash
   flutter devices
   ```
   Você deve ver seu telefone na lista!

4. **Compile e instale automaticamente:**
   ```bash
   flutter build apk --release
   flutter install
   ```
   
   **OU use o script:**
   ```
   COMPILAR_APK.bat
   ```
   Escolha opção 4 (Compilar e Instalar via USB)

### Método 2: Transferir Arquivo APK (Mais Simples) ⭐⭐⭐

**Este método funciona SEM Android SDK instalado!**

Se você compilar em outro computador ou usar um serviço de compilação:

1. **Tenha o arquivo APK** (de outro computador ou serviço)

2. **Copie para o telefone:**
   - **Via Email:** Envie o APK por email para você mesmo e abra no telefone
   - **Via USB:** Conecte telefone, copie APK para pasta Downloads
   - **Via Google Drive/OneDrive:** Faça upload e baixe no telefone
   - **Via Bluetooth:** Envie via Bluetooth
   - **Via WhatsApp Web:** Envie para você mesmo

3. **Instale no telefone:**
   - Abra o **gerenciador de arquivos** no telefone
   - Navegue até onde salvou o APK
   - Toque no arquivo APK
   - Quando perguntar sobre **"Fontes desconhecidas"**:
     - Toque em **"Configurações"**
     - Ative **"Permitir desta fonte"**
     - Volte e toque em **"Instalar"**

4. **Pronto!** O app estará instalado!

### Método 3: Instalar APK já compilado via USB

Se você já tem o APK compilado:

1. **Conecte telefone via USB**
2. **Copie APK para telefone:**
   ```bash
   # No Windows, arraste e solte o APK na pasta do telefone
   # Ou use:
   adb install build\app\outputs\flutter-apk\app-release.apk
   ```

---

## 🎯 COMANDOS RÁPIDOS

### Compilar APK Release (Recomendado)
```bash
flutter build apk --release
```

### Compilar e Instalar Automaticamente
```bash
flutter build apk --release && flutter install
```

### Compilar APK Menor (Split)
```bash
flutter build apk --split-per-abi --release
```

### Verificar Dispositivos Conectados
```bash
flutter devices
```

### Instalar APK já compilado
```bash
flutter install
```

---

## ⚠️ TROUBLESHOOTING

### Problema: "Android SDK not found"

**Solução:**
1. Instale Android Studio: https://developer.android.com/studio
2. Abra Android Studio e complete a configuração
3. Execute:
   ```bash
   flutter doctor
   flutter doctor --android-licenses
   ```

### Problema: "Telefone não detectado"

**Solução:**
1. Ative Depuração USB no telefone (veja Método 1 acima)
2. Instale drivers USB do telefone (geralmente automático no Windows)
3. Verifique:
   ```bash
   adb devices
   ```
4. Se ainda não aparecer, tente:
   - Desconecte e reconecte o cabo USB
   - Use outra porta USB
   - Tente outro cabo USB

### Problema: "Não consigo instalar APK"

**Solução:**
1. **Permita instalação de fontes desconhecidas:**
   - Android 8+: Configurações > Apps > Acesso especial > Instalar apps desconhecidos
   - Selecione o app usado para abrir APK (Files/Arquivos/Downloads)
   - Ative a permissão

2. **Se ainda não funcionar:**
   - Tente outro gerenciador de arquivos (Files, ES File Explorer, etc.)
   - Verifique se o APK não está corrompido

### Problema: "Erro ao compilar"

**Solução:**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## 📊 COMPARANDO OS MÉTODOS

| Método | Precisa Android SDK? | Precisa Cabo USB? | Dificuldade |
|--------|----------------------|-------------------|-------------|
| **Compilar no PC + Transferir** | ✅ Sim | ❌ Não | ⭐ Fácil |
| **Compilar e Instalar via USB** | ✅ Sim | ✅ Sim | ⭐⭐ Médio |
| **APK de outro PC** | ❌ Não | ❌ Não | ⭐⭐⭐ Muito Fácil |

---

## 💡 RECOMENDAÇÃO

**Para você agora:**

1. **Se tiver Android Studio instalado:**
   - Use `COMPILAR_APK.bat` → Opção 2 (Release)
   - Depois transfira o APK para o telefone (Método 2)

2. **Se NÃO tiver Android Studio:**
   - Instale Android Studio primeiro (15-20 minutos)
   - OU peça para alguém compilar o APK para você
   - Depois transfira via email/Drive para o telefone

---

## ✅ CHECKLIST ANTES DE COMPILAR

- [ ] Google Sign-In ativado no Firebase Console ✅
- [ ] `google-services.json` em `android/app/` ✅
- [ ] `firebase_options.dart` criado ✅
- [ ] Permissões configuradas ✅
- [ ] Mapbox token configurado ✅
- [ ] Android SDK instalado (para compilar)
- [ ] Depuração USB ativada (para instalar via USB)

---

## 🎉 PRONTO!

Depois de compilar, você terá um APK instalável!

**O APK estará em:** `build\app\outputs\flutter-apk\app-release.apk`

**Tamanho aproximado:** 30-40 MB

**Recomendado para apresentar ao cliente:** APK Release (otimizado e menor)

