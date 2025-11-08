@echo off
chcp 65001 > nul
echo ====================================
echo  RODAR APP NO TELEFONE (USB)
echo ====================================
echo.

echo Verificando dispositivos conectados...
echo.
flutter devices
echo.

echo.
echo ⚠️ IMPORTANTE: Se aparecer erro de licenças, aceite-as primeiro:
echo    Execute: flutter doctor --android-licenses
echo    (Digite 'y' para cada licença)
echo.
echo.

set /p continuar="Telefone conectado e detectado? (S/N): "

if /i "%continuar%"=="N" (
    echo.
    echo ⚠️ Certifique-se de que:
    echo    - Depuração USB está ATIVADA no telefone
    echo    - Telefone está conectado via USB
    echo    - Depuração USB foi PERMITIDA (popup no telefone)
    echo.
    pause
    exit /b 0
)

echo.
echo Verificando se precisa aceitar licenças...
flutter doctor --android-licenses < nul 2>&1 | findstr /C:"Review licenses" > nul
if %errorlevel%==0 (
    echo.
    echo ⚠️ Você precisa aceitar licenças Android primeiro!
    echo    Execute: flutter doctor --android-licenses
    echo    (Digite 'y' para cada licença)
    echo.
    pause
    exit /b 0
)

echo.
echo Compilando e executando no telefone...
echo ⏳ Isso pode levar alguns minutos na primeira vez...
echo.
echo 💡 Dicas:
echo    - Pressione 'r' para Hot Reload (recarregar mudanças)
echo    - Pressione 'R' para Hot Restart (reiniciar app)
echo    - Pressione 'q' para sair
echo.
echo ====================================
echo.

flutter run

echo.
echo ====================================
echo App finalizado!
echo ====================================
echo.
pause

