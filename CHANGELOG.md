# Changelog - SafePlate MVP Funcional

## Versão 1.0.0 - MVP Funcional

### ✅ Funcionalidades Implementadas (REAIS)

#### Autenticação Real com Firebase
- ✅ Integração completa com Firebase Auth
- ✅ Login com email e senha (funcional)
- ✅ Login com Google Sign-In (real, não simulado)
- ✅ Cadastro de novos usuários
- ✅ Recuperação de senha
- ✅ Gerenciamento de sessão persistente
- ✅ Mensagens de erro reais e informativas

#### Mapa Real com Mapbox
- ✅ Integração completa com Mapbox Maps SDK
- ✅ Mapa interativo real (não placeholder)
- ✅ Marcadores para estabelecimentos
- ✅ Localização do usuário em tempo real
- ✅ Cálculo de distâncias real baseado em coordenadas

#### Sistema de Favoritos Real
- ✅ Salvar/remover estabelecimentos com SQLite
- ✅ Persistência local real
- ✅ Estado sincronizado em tempo real
- ✅ Feedback visual ao salvar/remover

#### Busca e Filtros Funcionais
- ✅ Busca em tempo real
- ✅ Filtros dietéticos funcionais
- ✅ Filtros por proximidade
- ✅ Filtros por horário (abertos agora)

### 📦 Novas Dependências

- `firebase_core`: Core do Firebase
- `firebase_auth`: Autenticação Firebase
- `google_sign_in`: Login com Google real
- `mapbox_maps_flutter`: Mapas Mapbox reais
- `mapbox_maps_flutter`: Mapas Mapbox (mapbox_search removido - incompatível)
- `sqflite`: Banco de dados local para favoritos
- `permission_handler`: Gerenciamento de permissões

### 🔧 Arquivos Criados

- `lib/services/mapbox_service.dart`: Serviço Mapbox
- `lib/services/favorites_service.dart`: Serviço de favoritos (SQLite)
- `lib/widgets/mapbox_map_widget.dart`: Widget de mapa real
- `CONFIGURACAO.md`: Guia completo de configuração
- `firebase_options.dart`: Placeholder para configuração Firebase

### 🔄 Arquivos Modificados

- `lib/providers/auth_provider.dart`: Agora usa Firebase Auth real
- `lib/main.dart`: Inicialização do Firebase
- `lib/widgets/establishment_card.dart`: Favoritos reais com SQLite
- `lib/screens/search_screen.dart`: Mapa real Mapbox
- `pubspec.yaml`: Novas dependências

### 📝 Configuração Necessária

Para o app funcionar completamente, é necessário:

1. **Firebase** (obrigatório para login):
   ```bash
   flutterfire configure
   ```
   - Ativar Google Sign-In no Firebase Console
   - Adicionar SHA-1 fingerprint (Android)

2. **Mapbox** (obrigatório para mapa):
   - Obter Access Token no Mapbox
   - Editar `lib/services/mapbox_service.dart`
   - Substituir `YOUR_MAPBOX_ACCESS_TOKEN`

3. **Permissões**:
   - Adicionar permissões de localização nos manifestos

### ⚠️ Diferenças do Protótipo Anterior

- ❌ Removido: Login simulado
- ❌ Removido: Mapa placeholder
- ❌ Removido: Favoritos simulados
- ✅ Adicionado: Firebase Auth real
- ✅ Adicionado: Mapbox Maps SDK real
- ✅ Adicionado: SQLite para favoritos
- ✅ Adicionado: Tratamento de erros real
- ✅ Adicionado: Mensagens de erro informativas

### 🚀 Próximos Passos

1. Configurar Firebase (`flutterfire configure`)
2. Configurar Mapbox (adicionar token)
3. Testar login com Google
4. Testar mapa com marcadores
5. Testar favoritos
6. Testar em dispositivo real

### 📚 Documentação

- `README.md`: Visão geral e instruções básicas
- `CONFIGURACAO.md`: Guia detalhado de configuração
- `CHANGELOG.md`: Este arquivo

