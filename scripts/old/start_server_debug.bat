@echo off
echo Starting CS 1.6 Server with Zombie Plague...
echo.
cd /d C:\Projects\cs_zombie_ai\hlds
hlds.exe -game cstrike -console -port 27015 +maxplayers 16 +map de_dust2 +exec server.cfg
echo.
echo ========================================
echo Server stopped or crashed!
echo Check the error messages above.
echo ========================================
pause