@echo off
echo ========================================
echo Executando App Prato Seguro no Emulador
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] Verificando Flutter...
flutter doctor --version
echo.

echo [2/4] Verificando dependencias...
flutter pub get
echo.

echo [3/4] Iniciando emulador...
flutter emulators --launch Medium_Phone_API_36.1
echo.
echo Aguardando emulador inicializar (30 segundos)...
timeout /t 30 /nobreak
echo.

echo [4/4] Verificando dispositivos disponiveis...
flutter devices
echo.

echo [5/5] Executando app no emulador...
flutter run -d emulator-5554
echo.

pause


