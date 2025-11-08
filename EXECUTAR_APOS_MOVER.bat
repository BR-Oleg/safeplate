@echo off
chcp 65001 > nul
echo ====================================
echo  EXECUTAR APP APÓS MOVER
echo ====================================
echo.

cd /d C:\apkpratoseguro

if not exist "C:\apkpratoseguro" (
    echo ❌ Erro: A pasta C:\apkpratoseguro não existe!
    echo.
    echo 💡 Execute primeiro: MOVER_PROJETO.bat
    echo.
    pause
    exit /b 1
)

echo ✅ Projeto encontrado em: C:\apkpratoseguro
echo.
echo 🚀 Executando app com logs em tempo real...
echo.

set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
flutter run -d ZF524HHBBN

pause

