@echo off
echo ========================================
echo Executando App Prato Seguro
echo ========================================
echo.

cd /d "%~dp0"

echo Verificando dispositivos disponiveis...
flutter devices
echo.

echo Executando app...
flutter run
echo.

pause
