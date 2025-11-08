@echo off
chcp 65001 >nul
echo ========================================
echo  Instalando dependências do SafePlate
echo ========================================
echo.

REM Verificar se Flutter esta instalado
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ❌ ERRO: Flutter não encontrado no PATH!
    echo.
    echo 📖 Para instalar o Flutter no Windows:
    echo    1. Baixe em: https://docs.flutter.dev/get-started/install/windows
    echo    2. Extraia em C:\src\flutter (ou outro caminho sem espaços)
    echo    3. Adicione C:\src\flutter\bin ao PATH do sistema
    echo.
    echo 💡 Veja o guia completo em: GUIA_INSTALACAO_FLUTTER_WINDOWS.md
    echo.
    pause
    exit /b 1
)

echo ✅ Flutter encontrado!
echo.
flutter --version
echo.
echo ========================================
echo  Instalando dependências...
echo ========================================
echo.

flutter pub get

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo  ✅ Dependências instaladas com sucesso!
    echo ========================================
    echo.
    echo 📝 Próximos passos:
    echo.
    echo 1. Configurar Firebase:
    echo    flutterfire configure
    echo.
    echo 2. Mapbox já está configurado! ✓
    echo    Token adicionado: pk.eyJ...VerqjA
    echo.
    echo 3. Executar o app:
    echo    flutter run
    echo.
    echo ========================================
    pause
) else (
    echo.
    echo ❌ ERRO ao instalar dependências!
    echo.
    echo Verifique:
    echo - Flutter está instalado corretamente
    echo - Você está na pasta correta do projeto
    echo - Sua conexão com internet está funcionando
    echo.
    pause
    exit /b 1
)
