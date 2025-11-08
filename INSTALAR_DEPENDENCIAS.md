# Como Instalar as Dependências

## Opção 1: Executar o script (Windows)

Execute o arquivo `INSTALAR_DEPENDENCIAS.bat` (duplo clique).

## Opção 2: Comando manual

Abra o terminal na pasta do projeto e execute:

```bash
flutter pub get
```

## Verificar instalação

Após executar, verifique se foi criado o arquivo `pubspec.lock`. Isso indica que as dependências foram instaladas.

## Dependências que serão instaladas:

✅ **Firebase**
- firebase_core
- firebase_auth
- google_sign_in

✅ **Mapbox**
- mapbox_maps_flutter
- mapbox_maps_flutter (mapbox_search removido - incompatível com Dart 3.x)

✅ **Localização**
- geolocator
- permission_handler

✅ **Banco de Dados**
- sqflite

✅ **Outras**
- provider (gerenciamento de estado)
- http, dio (requisições)
- shared_preferences (armazenamento)
- url_launcher, image_picker
- flutter_spinkit (loading)

## Se o Flutter não for encontrado:

1. Certifique-se de que o Flutter está instalado
2. Adicione o Flutter ao PATH do sistema
3. Ou execute o comando com o caminho completo do Flutter

## Próximos passos após instalar:

1. **Configurar Firebase**: `flutterfire configure`
2. **Configurar Mapbox**: Editar `lib/services/mapbox_service.dart`
3. **Executar**: `flutter run`

