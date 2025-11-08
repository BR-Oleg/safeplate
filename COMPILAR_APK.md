# 📱 COMPILAR E INSTALAR APK - SafePlate MVP

## 🎯 COMPILAR APK

### Opção 1: APK Debug (Desenvolvimento - Mais Rápido)

```bash
flutter build apk --debug
```

**Onde encontrar:**
- Arquivo: `build/app/outputs/flutter-apk/app-debug.apk`
- Tamanho: ~40-50 MB

### Opção 2: APK Release (Produção - Menor e Otimizado) ⭐ RECOMENDADO

```bash
flutter build apk --release
```

**Onde encontrar:**
- Arquivo: `build/app/outputs/flutter-apk/app-release.apk`
- Tamanho: ~30-40 MB
- **Melhor para apresentar ao cliente!**

### Opção 3: APK Split por ABI (Menor ainda - Específico para seu dispositivo)

```bash
flutter build apk --split-per-abi --release
```

**Onde encontrar:**
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (32-bit)
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (64-bit) ⭐
- Tamanho: ~15-20 MB cada

## 📲 INSTALAR NO TELEFONE

### Método 1: Via USB (Mais Fácil) ⭐

**Pré-requisitos:**
1. Ative **"Depuração USB"** no telefone:
   - Configurações > Sobre o telefone > Toque 7x em "Número da versão"
   - Configurações > Opções do desenvolvedor > Ative "Depuração USB"

2. Conecte o telefone via USB ao computador

3. Verifique se o telefone foi detectado:
   ```bash
   flutter devices
   ```
   Você deve ver algo como:
   ```
   Android Phone (mobile) • <device-id> • android-arm64
   ```

4. Instale diretamente:
   ```bash
   flutter install
   ```
   
   **OU** após compilar:
   ```bash
   flutter build apk --release
   flutter install
   ```

### Método 2: Transferir Arquivo APK (Mais Simples)

1. **Compile o APK:**
   ```bash
   flutter build apk --release
   ```

2. **Encontre o arquivo:**
   - Caminho: `build/app/outputs/flutter-apk/app-release.apk`
   - Ou: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (se usou --split-per-abi)

3. **Copie para o telefone:**
   - **Via USB:** Copie o arquivo APK para a pasta Downloads do telefone
   - **Via email:** Envie o APK por email para você mesmo e abra no telefone
   - **Via Google Drive/OneDrive:** Faça upload e baixe no telefone
   - **Via Bluetooth:** Envie via Bluetooth

4. **Instale no telefone:**
   - Abra o arquivo APK no telefone
   - **Permitir instalação de fontes desconhecidas** quando solicitado:
     - Configurações > Segurança > Fontes desconhecidas (varia por dispositivo)
   - Toque em **"Instalar"**

## 🚀 COMANDO RÁPIDO (Tudo em um)

```bash
# Compilar e instalar automaticamente via USB
flutter build apk --release && flutter install
```

## ⚠️ TROUBLESHOOTING

### Problema: "Android SDK not found"
**Solução:**
- Instale Android Studio
- Configure Android SDK
- Execute: `flutter doctor --android-licenses` e aceite as licenças

### Problema: "Telefone não detectado"
**Solução:**
1. Ative Depuração USB no telefone
2. Instale drivers USB do telefone (geralmente automático)
3. Tente: `adb devices` para verificar conexão

### Problema: "Erro ao compilar"
**Solução:**
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Problema: "Não consigo instalar APK"
**Solução:**
- Permita instalação de fontes desconhecidas:
  - Android 8+: Configurações > Apps > Acesso especial > Instalar apps desconhecidos
  - Selecione o app usado para abrir o APK (Files/Arquivos)

## 📊 RESUMO DAS OPÇÕES

| Método | Comando | Tamanho | Quando Usar |
|--------|---------|---------|--------------|
| Debug | `flutter build apk --debug` | ~50 MB | Testes rápidos |
| Release | `flutter build apk --release` | ~35 MB | **Apresentação ao cliente** ⭐ |
| Split ABI | `flutter build apk --split-per-abi --release` | ~20 MB | Distribuição específica |

## ✅ CHECKLIST ANTES DE COMPILAR

- [ ] Google Sign-In ativado no Firebase Console ✅
- [ ] `google-services.json` em `android/app/` ✅
- [ ] `firebase_options.dart` criado ✅
- [ ] Permissões configuradas ✅
- [ ] Mapbox token configurado ✅
- [ ] Código sem erros críticos ✅

## 🎉 PRONTO!

Depois de compilar, você terá um APK instalável no telefone!

**Recomendação:** Use `flutter build apk --release` para ter o melhor APK otimizado para apresentar ao cliente!

