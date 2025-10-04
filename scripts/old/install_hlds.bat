@echo off
echo Installing HLDS (Half-Life Dedicated Server)...
cd /d C:\steamcmd
steamcmd.exe +login anonymous +force_install_dir "C:\Projects\cs_zombie_ai\hlds" +app_update 90 validate +quit
echo HLDS installation complete!
pause