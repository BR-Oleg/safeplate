# 🚀 Como Executar o App no Emulador

## Método 1: Via Android Studio (Mais Fácil)

1. **Abra o Android Studio**
2. **Abra o AVD Manager**:
   - Tools → Device Manager
   - Ou clique no ícone de dispositivo na barra de ferramentas
3. **Inicie um emulador**:
   - Clique no botão ▶️ (Play) ao lado do emulador
   - Aguarde o emulador inicializar completamente
4. **Execute o app**:
   - No Android Studio, clique em "Run" (▶️)
   - Ou use: `Run → Run 'main.dart'`

## Método 2: Via Terminal/CMD

### Opção A: Script Automático

1. **Execute o arquivo**: `EXECUTAR_EMULADOR.bat`
   - Ele vai iniciar o emulador e executar o app automaticamente

### Opção B: Comandos Manuais

1. **Inicie o emulador**:
   ```bash
   flutter emulators --launch Medium_Phone_API_36.1
   ```

2. **Aguarde o emulador inicializar** (30-60 segundos)

3. **Verifique dispositivos**:
   ```bash
   flutter devices
   ```

4. **Execute o app**:
   ```bash
   flutter run
   ```

## Método 3: Se Emulador Já Está Rodando

1. **Verifique dispositivos**:
   ```bash
   flutter devices
   ```

2. **Execute o app**:
   ```bash
   flutter run
   ```

   O Flutter vai detectar automaticamente o emulador rodando.

## ⚠️ Se Não Funcionar

### Problema: "No devices found"

**Solução**:
1. Verifique se o emulador está rodando
2. Aguarde mais tempo (emulador pode demorar para inicializar)
3. Reinicie o emulador
4. Verifique: `flutter devices`

### Problema: "Emulator is offline"

**Solução**:
1. Feche o emulador
2. Reinicie o emulador
3. Aguarde até aparecer a tela inicial do Android
4. Tente novamente: `flutter run`

### Problema: "ADB not found"

**Solução**:
1. Verifique se Android SDK está instalado
2. Adicione ao PATH: `C:\Users\Bruna B\AppData\Local\Android\Sdk\platform-tools`

## 📱 Verificar se Emulador Está Pronto

O emulador está pronto quando:
- ✅ Aparece a tela inicial do Android (home screen)
- ✅ Não mostra mais "ANDROID" na tela
- ✅ `flutter devices` mostra o emulador como "online"

## 🎯 Comando Rápido

Se você já tem o emulador rodando:

```bash
cd c:\apkpratoseguro
flutter run
```

O Flutter vai detectar automaticamente e executar no emulador!

---

**Dica**: Se o emulador estiver lento, feche outros programas ou reduza a RAM do emulador nas configurações do AVD Manager.


