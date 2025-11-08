@echo off
chcp 65001 > nul
echo ====================================
echo  MOVER PROJETO PARA C:\
echo ====================================
echo.

echo ⚠️  ATENÇÃO: Feche todos os programas que possam estar usando o projeto:
echo    - Android Studio
echo    - VS Code / Cursor
echo    - Terminais PowerShell
echo    - Qualquer outro editor
echo.

pause

echo.
echo 📦 Movendo projeto...
echo    De: C:\Users\Bruna B\Desktop\apkpratoseguro
echo    Para: C:\apkpratoseguro
echo.

if exist "C:\apkpratoseguro" (
    echo ⚠️  A pasta C:\apkpratoseguro já existe!
    echo Removendo pasta existente...
    rmdir /s /q "C:\apkpratoseguro"
)

move "C:\Users\Bruna B\Desktop\apkpratoseguro" "C:\apkpratoseguro"

if %errorlevel%==0 (
    echo.
    echo ✅ Projeto movido com sucesso!
    echo.
    echo 📁 Novo caminho: C:\apkpratoseguro
    echo.
    echo 🚀 Agora execute:
    echo    cd C:\apkpratoseguro
    echo    flutter run -d ZF524HHBBN
    echo.
) else (
    echo.
    echo ❌ Erro ao mover projeto!
    echo.
    echo 💡 Certifique-se de que:
    echo    1. Todos os programas foram fechados
    echo    2. Nenhum terminal está aberto na pasta
    echo    3. Você tem permissões de administrador
    echo.
)

pause

