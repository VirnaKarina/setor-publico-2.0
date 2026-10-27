@echo off
setlocal
set "ROOT=%~dp0"
set "PYTHON=%ROOT%.tools\python\python.exe"

if not exist "%PYTHON%" (
    echo Runtime Python local nao encontrada.
    where py >nul 2>nul
    if errorlevel 1 (
        echo Instale o Python 3.10 ou superior e execute novamente.
        pause
        exit /b 1
    )
    if not exist "%ROOT%backend\.venv\Scripts\python.exe" py -3 -m venv "%ROOT%backend\.venv"
    set "PYTHON=%ROOT%backend\.venv\Scripts\python.exe"
    "%PYTHON%" -m pip install -r "%ROOT%backend\requirements.txt"
    if errorlevel 1 (
        echo Nao foi possivel instalar as dependencias.
        pause
        exit /b 1
    )
)

echo Preparando banco de dados local...
pushd "%ROOT%backend"
"%PYTHON%" manage.py migrate
if errorlevel 1 (
    popd
    echo Nao foi possivel preparar o banco de dados.
    pause
    exit /b 1
)
popd

start "SIGDEI - BACKEND" cmd /k "cd /d "%ROOT%backend" && "%PYTHON%" manage.py runserver 127.0.0.1:8000"
start "SIGDEI - FRONTEND" cmd /k "cd /d "%ROOT%frontend" && "%PYTHON%" -m http.server 5500 --bind 127.0.0.1"
timeout /t 2 /nobreak >nul
start "" "http://127.0.0.1:5500/index.html"

echo Servidores iniciados. Mantenha as duas janelas abertas enquanto usar o sistema.
