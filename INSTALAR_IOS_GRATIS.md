# 📱 Como Instalar App iOS GRATUITAMENTE (Sem Conta Paga)

Guia passo a passo para instalar o app no iPhone do cliente **SEM** pagar a conta Apple Developer.

## 🎯 Método Recomendado: AltStore

### Pré-requisitos:
- ✅ iPhone com iOS 12.2 ou superior
- ✅ Computador Windows/Mac
- ✅ iTunes instalado (Windows) ou Finder (Mac)
- ✅ Conta Apple ID (gratuita, a mesma do iPhone)

### Passo a Passo:

#### 1. Compilar o App (Sem Assinatura)

O workflow do GitHub Actions já está configurado para compilar sem assinatura.

**Opção A: Via GitHub Actions**
1. Vá para Actions no GitHub
2. Execute o workflow "Build iOS App"
3. Aguarde o build completar
4. Baixe o artifact `ios-build-XXX`
5. Extraia o arquivo `.app` ou `.ipa`

**Opção B: Localmente (se tiver Mac)**
```bash
flutter build ios --release --no-codesign
```

#### 2. Converter .app para .ipa (Se necessário)

Se você tem apenas o `.app`, precisa converter para `.ipa`:

**No Mac:**
```bash
mkdir -p Payload
cp -r build/ios/iphoneos/Runner.app Payload/
zip -r app.ipa Payload
```

**No Windows:**
- Use ferramentas online como: https://www.7-zip.org
- Ou scripts PowerShell

#### 3. Instalar AltStore

1. **Baixe AltServer**:
   - Windows: https://altstore.io/AltInstaller.exe
   - Mac: https://altstore.io/AltInstaller.dmg

2. **Instale AltServer** no computador

3. **Conecte iPhone** ao computador via USB

4. **Abra AltServer**:
   - Windows: Clique no ícone na bandeja do sistema
   - Mac: Abra o app AltServer

5. **Instale AltStore no iPhone**:
   - Clique em "Install AltStore" → Selecione seu iPhone
   - Entre com sua Apple ID
   - AltStore será instalado no iPhone

#### 4. Instalar o App

1. **Abra AltStore** no iPhone

2. **Toque em "+"** (canto superior direito)

3. **Selecione o arquivo .ipa**:
   - Pode estar no Files, iCloud, ou baixar direto

4. **Aguarde a instalação**

5. **Confie no desenvolvedor**:
   - Settings → General → VPN & Device Management
   - Toque no seu Apple ID
   - Toque em "Trust"

6. **Abra o app** normalmente

#### 5. Renovar a Cada 7 Dias

O app expira em 7 dias. Para renovar:

1. **Conecte iPhone** ao computador
2. **Abra AltStore** no iPhone
3. **Toque em "Refresh All"**
4. **Mantenha AltServer rodando** no computador

**Dica**: Configure AltServer para iniciar automaticamente.

## 🔄 Método Alternativo: Sideloadly

### Passo a Passo:

1. **Baixe Sideloadly**: https://sideloadly.io

2. **Conecte iPhone** ao computador

3. **Abra Sideloadly**

4. **Selecione o arquivo .ipa**

5. **Entre com Apple ID**:
   - Use sua conta Apple ID gratuita
   - Sideloadly criará um certificado temporário

6. **Clique em "Start"**

7. **Aguarde a instalação**

8. **Confie no desenvolvedor** (mesmo processo do AltStore)

## ⚠️ Limitações Importantes

### Com Conta Gratuita:

- ⚠️ **App expira em 7 dias**
  - Precisa reinstalar toda semana
  - Ou renovar via AltStore/Sideloadly

- ⚠️ **Máximo 3 apps** instalados simultaneamente
  - Precisa desinstalar outros para instalar novos

- ⚠️ **Notificações Push podem não funcionar**
  - Firebase Cloud Messaging pode precisar de certificados válidos
  - Alguns recursos podem ter limitações

- ⚠️ **Não pode usar TestFlight**
  - Cliente precisa instalar manualmente
  - Mais complicado para distribuição

## 💡 Dicas

### Para o Cliente:

1. **Instale AltStore** uma vez
2. **Renove a cada 7 dias** (conectando ao computador)
3. **Ou reinstale** se não renovar a tempo

### Para Você (Desenvolvedor):

1. **Teste no Android primeiro** (mais fácil)
2. **Use iOS grátis** para testes rápidos
3. **Pague a conta** quando for distribuir seriamente

## 🔧 Troubleshooting

### Erro: "Unable to verify app"
- **Solução**: Vá em Settings → General → VPN & Device Management → Trust

### Erro: "App expired"
- **Solução**: Renove via AltStore ou reinstale

### Erro: "Too many apps"
- **Solução**: Desinstale outros apps instalados via AltStore

### AltStore não renova
- **Solução**: Certifique-se que AltServer está rodando no computador
- Conecte iPhone ao computador
- Abra AltStore no iPhone e toque em "Refresh All"

## 📊 Comparação: Grátis vs Pago

| Recurso | Gratuito (AltStore) | Pago ($99/ano) |
|---------|---------------------|----------------|
| Instalar app | ✅ | ✅ |
| Validade | 7 dias | 1 ano |
| Renovação | Manual (semanal) | Automática |
| TestFlight | ❌ | ✅ |
| Máximo apps | 3 | Ilimitado |
| Distribuição | Manual | Fácil |
| Notificações | ⚠️ Limitado | ✅ Completo |

## ✅ Conclusão

**Para testar rapidamente**: Use AltStore (GRATUITO)
- ✅ Funciona imediatamente
- ✅ Não precisa pagar
- ⚠️ App expira em 7 dias
- ⚠️ Precisa renovar semanalmente

**Para testes sérios**: Pague a conta ($99/ano)
- ✅ App não expira
- ✅ TestFlight facilita distribuição
- ✅ Profissional

---

**Recomendação**: Teste grátis primeiro. Se funcionar bem e você precisar de testes mais longos, aí sim pague a conta.


