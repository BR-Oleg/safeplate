@echo off
chcp 65001 > nul
echo ====================================
echo  COMPILAR APK - SafePlate MVP
echo ====================================
echo.

echo Escolha uma opção:
echo.
echo 1. APK Debug (Desenvolvimento - Mais rápido)
echo 2. APK Release (Produção - Recomendado) ⭐
echo 3. APK Split por ABI (Menor - Específico para dispositivo)
echo 4. Compilar e Instalar via USB (Release)
echo 5. Sair
echo.

set /p escolha="Digite o número da opção (1-5): "

if "%escolha%"=="1" (
    echo.
    echo Compilando APK Debug...
    flutter build apk --debug
    if %errorlevel%==0 (
        echo.
        echo ✅ APK compilado com sucesso!
        echo.
        echo 📁 Arquivo localizado em:
        echo    build\app\outputs\flutter-apk\app-debug.apk
        echo.
    ) else (
        echo.
        echo ❌ Erro ao compilar APK!
        echo.
    )
)

if "%escolha%"=="2" (
    echo.
    echo Compilando APK Release...
    flutter build apk --release
    if %errorlevel%==0 (
        echo.
        echo ✅ APK compilado com sucesso!
        echo.
        echo 📁 Arquivo localizado em:
        echo    build\app\outputs\flutter-apk\app-release.apk
        echo.
        echo 💡 Para instalar no telefone:
        echo    1. Copie o arquivo para o telefone
        echo    2. Abra o arquivo APK
        echo    3. Permita instalação de fontes desconhecidas
        echo    4. Instale!
        echo.
    ) else (
        echo.
        echo ❌ Erro ao compilar APK!
        echo.
    )
)

if "%escolha%"=="3" (
    echo.
    echo Compilando APK Split por ABI...
    flutter build apk --split-per-abi --release
    if %errorlevel%==0 (
        echo.
        echo ✅ APK compilado com sucesso!
        echo.
        echo 📁 Arquivos localizados em:
        echo    build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk (32-bit)
        echo    build\app\outputs\flutter-apk\app-arm64-v8a-release.apk (64-bit) ⭐
        echo.
        echo 💡 Use o arquivo arm64-v8a para telefones modernos (64-bit)
        echo.
    ) else (
        echo.
        echo ❌ Erro ao compilar APK!
        echo.
    )
)

if "%escolha%"=="4" (
    echo.
    echo Verificando dispositivos conectados...
    flutter devices
    echo.
    echo Compilando e instalando APK Release...
    flutter build apk --release
    if %errorlevel%==0 (
        echo.
        echo Instalando no dispositivo...
        flutter install
        if %errorlevel%==0 (
            echo.
            echo ✅ APK instalado com sucesso no telefone!
            echo.
        ) else (
            echo.
            echo ⚠️ APK compilado, mas não foi possível instalar automaticamente.
            echo    Certifique-se de que:
            echo    - O telefone está conectado via USB
            echo    - Depuração USB está ativada
            echo    - Execute 'flutter devices' para verificar
            echo.
        )
    ) else (
        echo.
        echo ❌ Erro ao compilar APK!
        echo.
    )
)

if "%escolha%"=="5" (
    echo.
    echo Saindo...
    exit /b 0
)

echo.
pause

