# SafePlate - Prato Seguro MVP

Aplicativo Flutter funcional para encontrar estabelecimentos com opções seguras para pessoas com restrições alimentares.

## ⚡ Funcionalidades Implementadas (REAIS)

✅ **Login Real com Firebase**
- Login com email e senha (Firebase Auth)
- Login com Google Sign-In (real, não simulado)
- Cadastro de novos usuários
- Recuperação de senha
- Gerenciamento de sessão

✅ **Mapa Real com Mapbox**
- Integração completa com Mapbox Maps SDK
- Marcadores interativos nos mapas
- Localização do usuário em tempo real
- Cálculo de distâncias real

✅ **Sistema de Favoritos**
- Salvar/remover estabelecimentos favoritos
- Persistência local com SQLite
- Lista de favoritos salvos

✅ **Busca e Filtros Funcionais**
- Busca em tempo real de estabelecimentos
- Filtros dietéticos (Celíaco, Sem Lactose, Sem Amendoim, Vegano, Halal)
- Filtros por proximidade
- Filtros por horário (abertos agora)

✅ **Sistema de Selos**
- Níveis de certificação (Bronze, Prata, Ouro, Platina)
- Tags de dificuldade (Popular, Intermediário, Técnico)

## 🚀 Configuração Inicial

### 0. Instalar Flutter (se ainda não tiver)

**Veja o guia completo**: `GUIA_INSTALACAO_FLUTTER_WINDOWS.md`

Resumo rápido:
1. Baixe Flutter: https://docs.flutter.dev/get-started/install/windows
2. Extraia em `C:\src\flutter`
3. Adicione `C:\src\flutter\bin` ao PATH
4. Reinicie o terminal
5. Execute: `flutter doctor`

### 1. Instalar Dependências

**Opção 1**: Execute o script (Windows):
```
Duplo clique em INSTALAR_DEPENDENCIAS.bat
```

**Opção 2**: Pelo terminal:
```bash
flutter pub get
```

### 2. Configurar Firebase

**OBRIGATÓRIO para login funcionar:**

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar Firebase
flutterfire configure
```

Isso criará automaticamente:
- `lib/firebase_options.dart`
- Configurações para Android e iOS

**Configurar Google Sign-In:**
1. No Firebase Console: Authentication > Sign-in method > Ativar Google
2. Adicionar SHA-1 fingerprint (Android):
   ```bash
   cd android
   ./gradlew signingReport
   ```
3. Copiar SHA-1 e adicionar no Firebase Console

### 3. Configurar Mapbox

✅ **JÁ CONFIGURADO!** O token do Mapbox já foi adicionado ao projeto.

Token: `pk.eyJ1Ijoic2FmZXBsYXRlNTAwIiwiYSI6ImNtaGZoMXF2NTA1dDIya3B5dnljbXkzZG4ifQ.DgeBcy0YXvBdDLdPVerqjA`

Se precisar alterar, edite `lib/services/mapbox_service.dart`.

### 4. Permissões

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Precisamos da sua localização para mostrar estabelecimentos próximos</string>
```

## 📱 Executar o App

```bash
# Desenvolvimento
flutter run

# Release (Android)
flutter build apk --release

# Release (iOS)
flutter build ios --release
```

## 📂 Estrutura do Projeto

```
lib/
├── main.dart                    # Entry point + Firebase init
├── models/                      # Modelos de dados
│   ├── establishment.dart       # Estabelecimento
│   ├── user.dart               # Usuário
│   └── seal.dart               # Selos
├── providers/                   # Gerenciamento de estado
│   ├── auth_provider.dart      # Autenticação (Firebase)
│   └── establishment_provider.dart # Estabelecimentos
├── screens/                     # Telas
│   ├── splash_screen.dart       # Tela inicial
│   ├── login_screen.dart        # Login (real)
│   ├── home_screen.dart         # Home com navegação
│   ├── search_screen.dart       # Busca com mapa real
│   └── seal_screen.dart        # Selos
├── services/                    # Serviços
│   ├── mapbox_service.dart     # Serviço Mapbox
│   └── favorites_service.dart  # Favoritos (SQLite)
└── widgets/                     # Componentes
    ├── establishment_card.dart # Card com favoritos reais
    ├── dietary_filter_chip.dart # Filtro dietético
    └── mapbox_map_widget.dart  # Mapa real Mapbox
```

## 🔧 Tecnologias Utilizadas

- **Firebase Auth**: Autenticação real
- **Google Sign-In**: Login com Google real
- **Mapbox Maps**: Mapas interativos reais
- **SQLite (sqflite)**: Persistência local de favoritos
- **Provider**: Gerenciamento de estado
- **Geolocator**: Localização do usuário
- **SharedPreferences**: Configurações do usuário

## ⚠️ Importante

Este MVP é **FUNCIONAL** mas requer configuração:

1. **Firebase**: Sem configuração, o login não funcionará
2. **Mapbox**: Sem token, o mapa mostrará placeholder
3. **Permissões**: Sem permissões configuradas, localização não funcionará

Para mais detalhes de configuração, veja `CONFIGURACAO.md`.

## 📋 Checklist de Configuração

Antes de apresentar ao cliente, certifique-se:

- [ ] Firebase configurado (`flutterfire configure`)
- [ ] Google Sign-In ativado no Firebase Console
- [ ] SHA-1 fingerprint adicionado (Android)
- [ ] Mapbox Access Token configurado
- [ ] Permissões de localização adicionadas
- [ ] Testado login com email/senha
- [ ] Testado login com Google
- [ ] Testado mapa (verificar marcadores)
- [ ] Testado favoritos (salvar/remover)
- [ ] Testado filtros de busca
- [ ] Testado em dispositivo real

## 🐛 Troubleshooting

### Firebase não inicializa
- Verifique se `firebase_options.dart` existe
- Execute `flutterfire configure` novamente
- Verifique se `google-services.json` está em `android/app/`

### Google Sign-In não funciona
- Verifique SHA-1 fingerprint no Firebase Console
- Verifique se Google Sign-In está ativado no Firebase
- Teste em dispositivo real (não emulador)

### Mapbox não funciona
- Verifique se o token foi substituído
- Verifique permissões de localização
- Verifique logs do Flutter

### Erro de permissões
- Verifique manifestos (AndroidManifest.xml / Info.plist)
- Conceda permissões manualmente no dispositivo
- Teste em dispositivo real

## 📄 Licença

Este projeto é um MVP para demonstração.
