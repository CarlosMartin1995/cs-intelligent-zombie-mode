@echo off
echo ========================================
echo  Compiling AI Bridge Plugin
echo ========================================

REM Copy source to HLDS scripting folder
echo [1/4] Copying source file...
copy /Y "addons\amxmodx\scripting\ai_bridge.sma" "hlds\cstrike\addons\amxmodx\scripting\ai_bridge.sma"

REM Navigate to scripting folder
cd /d "hlds\cstrike\addons\amxmodx\scripting"

REM Compile
echo [2/4] Compiling plugin...
compile.exe ai_bridge.sma

REM Check if compilation succeeded
if not exist "compiled\ai_bridge.amxx" (
    echo.
    echo [ERROR] Compilation failed!
    echo Check the error messages above.
    pause
    exit /b 1
)

echo [3/4] Installing plugin...
copy /Y "compiled\ai_bridge.amxx" "..\plugins\ai_bridge.amxx"

echo [4/4] Verifying installation...
if exist "..\plugins\ai_bridge.amxx" (
    echo.
    echo ========================================
    echo  SUCCESS! Plugin compiled and installed
    echo ========================================
    echo.
    echo Next steps:
    echo 1. Make sure ai_bridge.amxx is in plugins.ini
    echo 2. Make sure sockets module is enabled in modules.ini
    echo 3. Restart the server to load the plugin
) else (
    echo [ERROR] Plugin installation failed!
)

echo.
pause
