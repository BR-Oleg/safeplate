@echo off
chcp 65001 >nul
echo ========================================
echo  Configurando Firebase para SafePlate
echo ========================================
echo.

REM Verificar se FlutterFire CLI está instalado
dart pub global list | findstr flutterfire_cli >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo 📦 Instalando FlutterFire CLI...
    dart pub global activate flutterfire_cli
    echo.
    if %ERRORLEVEL% NEQ 0 (
        echo ❌ Erro ao instalar FlutterFire CLI!
        echo.
        pause
        exit /b 1
    )
    echo ✅ FlutterFire CLI instalado!
    echo.
) else (
    echo ✅ FlutterFire CLI já está instalado!
    echo.
)

echo ========================================
echo  PRÉ-REQUISITOS
echo ========================================
echo.
echo Antes de continuar, certifique-se de:
echo.
echo 1. ✅ Estar logado no Firebase:
echo    firebase login
echo.
echo 2. ✅ Ter um projeto criado no Firebase Console
echo    https://console.firebase.google.com/
echo.
echo 3. ✅ Ter baixado google-services.json para:
echo    android/app/google-services.json
echo.
echo 4. ✅ Ter baixado GoogleService-Info.plist para:
echo    ios/Runner/GoogleService-Info.plist (se iOS)
echo.
echo ========================================
echo.

set /p resposta="Já completou os pré-requisitos? (S/N): "
if /i not "%resposta%"=="S" (
    echo.
    echo 📖 Consulte o arquivo CONFIGURAR_FIREBASE.md para instruções detalhadas!
    echo.
    pause
    exit /b 0
)

echo.
echo ========================================
echo  Executando flutterfire configure...
echo ========================================
echo.
echo ⚠️  Este comando é INTERATIVO!
echo    Você precisará selecionar seu projeto Firebase
echo.
pause

flutterfire configure

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  ✅ Firebase configurado com sucesso!
    echo ========================================
    echo.
    echo Próximos passos:
    echo 1. Ativar Google Sign-In no Firebase Console
    echo 2. Adicionar SHA-1 fingerprint (para Android)
    echo 3. Testar o app: flutter run
    echo.
    echo 📖 Veja CONFIGURAR_FIREBASE.md para mais detalhes
    echo.
) else (
    echo.
    echo ❌ Erro ao configurar Firebase!
    echo.
    echo Verifique:
    echo - Está logado no Firebase? (firebase login)
    echo - Tem um projeto criado no Firebase Console?
    echo - Os arquivos google-services.json estão no lugar certo?
    echo.
    echo 📖 Veja CONFIGURAR_FIREBASE.md para ajuda
    echo.
)

pause

