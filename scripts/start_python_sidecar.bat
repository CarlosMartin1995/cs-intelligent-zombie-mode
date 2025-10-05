@echo off
echo ========================================
echo  Starting Python AI Sidecar
echo ========================================
echo.

cd /d "%~dp0..\python_sidecar"

REM Check if venv exists
if not exist ".venv\Scripts\activate.bat" (
    echo [ERROR] Python virtual environment not found!
    echo.
    echo Please run setup first:
    echo   cd python_sidecar
    echo   python -m venv .venv
    echo   .venv\Scripts\activate
    echo   pip install -r requirements.txt
    echo.
    pause
    exit /b 1
)

REM Activate venv and run
call .venv\Scripts\activate.bat

echo Starting ai_server.py...
echo Press Ctrl+C to stop
echo.

python ai_server.py
