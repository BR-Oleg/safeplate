@echo off
echo ========================================
echo   PRATO SEGURO - DASHBOARD ADMIN
echo ========================================
echo.
echo Este script vai ajudar voce a rodar o dashboard.
echo.
echo IMPORTANTE: Antes de rodar, certifique-se de que:
echo   1. Voce configurou o arquivo .env no backend
echo   2. Voce configurou o arquivo .env.local no frontend
echo.
pause

echo.
echo [1/2] Instalando dependencias do BACKEND...
cd backend
if not exist node_modules (
    call npm install
) else (
    echo Dependencias do backend ja instaladas.
)
cd ..

echo.
echo [2/2] Instalando dependencias do FRONTEND...
cd frontend
if not exist node_modules (
    call npm install
) else (
    echo Dependencias do frontend ja instaladas.
)
cd ..

echo.
echo ========================================
echo   CONCLUIDO!
echo ========================================
echo.
echo Agora voce precisa:
echo.
echo 1. Abrir um terminal e rodar o BACKEND:
echo    cd admin-dashboard\backend
echo    npm start
echo.
echo 2. Abrir OUTRO terminal e rodar o FRONTEND:
echo    cd admin-dashboard\frontend
echo    npm run dev
echo.
echo 3. Acessar no navegador:
echo    http://localhost:3000
echo.
pause


