# Zombie Plague Server Installation Guide

This guide will walk you through installing all necessary components to set up a Zombie Plague server with AI capabilities on your ReHLDS/ReGameDLL installation.

## Prerequisites
✅ ReHLDS installed and running
✅ ReGameDLL installed
✅ All required files in `downloads/` folder

## Step 1: Install Metamod-R

Metamod-R is required to load AMX Mod X and other plugins.

1. **Stop the server** if it's running (close the HLDS console window)

2. **Extract Metamod-R:**
   ```powershell
   # In PowerShell, from the project root:
   cd downloads
   Expand-Archive -Path "Metamod-r.zip" -DestinationPath "Metamod-r_temp" -Force
   ```

3. **Copy Metamod-R files to HLDS:**
   ```powershell
   # Copy the addons folder
   Copy-Item -Path "Metamod-r_temp\addons" -Destination "..\hlds\cstrike\" -Recurse -Force
   ```

4. **Configure ReGameDLL to load Metamod-R:**
   - Open `hlds\cstrike\game.cfg` (create if it doesn't exist)
   - Add this line:
   ```
   gamedll_linux "addons/metamod/metamod_i386.so"
   gamedll "addons\metamod\metamod.dll"
   ```

   OR if using liblist.gam:
   - Open `hlds\cstrike\liblist.gam`
   - Find the line starting with `gamedll`
   - Change it to: `gamedll "addons\metamod\metamod.dll"`

## Step 2: Install AMX Mod X

AMX Mod X provides the plugin framework for Zombie Plague.

1. **Extract AMX Mod X Base:**
   ```powershell
   # From downloads folder:
   Expand-Archive -Path "amxmodx-1.8.2-base-windows.zip" -DestinationPath "amxmod_temp" -Force
   ```

2. **Extract AMX Mod X Counter-Strike addon:**
   ```powershell
   Expand-Archive -Path "amxmodx-1.8.2-cstrike-windows.zip" -DestinationPath "amxmod_temp" -Force
   ```

3. **Copy AMX Mod X files:**
   ```powershell
   # Copy the addons folder (this merges with Metamod-R's addons)
   Copy-Item -Path "amxmod_temp\addons\*" -Destination "..\hlds\cstrike\addons\" -Recurse -Force
   ```

4. **Configure Metamod-R to load AMX Mod X:**
   - Create/edit `hlds\cstrike\addons\metamod\plugins.ini`
   - Add this line:
   ```
   win32 addons/amxmodx/dlls/amxmodx_mm.dll
   ```

## Step 3: Install Zombie Plague 5.0

1. **Extract Zombie Plague files:**
   ```powershell
   # Use the patched version for better compatibility
   Expand-Archive -Path "zp_plugin_50_patched.zip" -DestinationPath "zp50_temp" -Force
   ```

2. **Copy Zombie Plague files:**
   ```powershell
   # Copy all contents to cstrike folder
   Copy-Item -Path "zp50_temp\*" -Destination "..\hlds\cstrike\" -Recurse -Force
   ```

3. **Extract and copy Zombie Plague resources:**
   ```powershell
   Expand-Archive -Path "zp_resources.zip" -DestinationPath "zp_resources_temp" -Force
   Copy-Item -Path "zp_resources_temp\*" -Destination "..\hlds\cstrike\" -Recurse -Force
   ```

4. **Enable Zombie Plague plugins:**
   - Check `hlds\cstrike\addons\amxmodx\configs\plugins-zp50.ini` exists
   - This file should list all ZP50 plugins to load

## Step 4: Install YaPB Bots

1. **Extract YaPB:**
   ```powershell
   Expand-Archive -Path "yapb-4.5.1199-windows.zip" -DestinationPath "yapb_temp" -Force
   Expand-Archive -Path "yapb-4.5.1199-extras.zip" -DestinationPath "yapb_extras_temp" -Force
   ```

2. **Copy YaPB files:**
   ```powershell
   # Copy YaPB to addons
   Copy-Item -Path "yapb_temp\addons\*" -Destination "..\hlds\cstrike\addons\" -Recurse -Force

   # Copy extras (waypoints, etc.)
   Copy-Item -Path "yapb_extras_temp\*" -Destination "..\hlds\cstrike\" -Recurse -Force
   ```

3. **Configure Metamod-R to load YaPB:**
   - Edit `hlds\cstrike\addons\metamod\plugins.ini`
   - Add this line:
   ```
   win32 addons/yapb/bin/yapb.dll
   ```

## Step 5: Configure Server Settings

1. **Edit server.cfg:**
   Add to `hlds\cstrike\server.cfg`:
   ```
   // Zombie Plague Settings
   hostname "Zombie Plague AI Server"
   sv_password ""
   rcon_password "changeme"

   // Game Settings
   mp_timelimit 0
   mp_roundtime 5
   mp_freezetime 3
   mp_limitteams 0
   mp_autoteambalance 0

   // Bot Settings
   yapb_quota 10
   yapb_auto_vacate 1

   // Load Zombie Plague
   amx_plugins load
   ```

2. **Configure AMX Mod X modules:**
   - Edit `hlds\cstrike\addons\amxmodx\configs\modules.ini`
   - Ensure these modules are enabled (no semicolon at start):
   ```
   engine
   fakemeta
   hamsandwich
   cstrike
   csx
   fun
   sockets
   ```

## Step 6: Install AI Bridge Plugin

1. **Copy the AI Bridge source:**
   ```powershell
   Copy-Item -Path "..\addons\amxmodx\scripting\ai_bridge.sma" -Destination "..\hlds\cstrike\addons\amxmodx\scripting\"
   ```

2. **Compile the plugin:**
   ```powershell
   cd ..\hlds\cstrike\addons\amxmodx\scripting
   .\compile.exe ai_bridge.sma
   ```

3. **Install the compiled plugin:**
   ```powershell
   Copy-Item -Path "compiled\ai_bridge.amxx" -Destination "..\plugins\"
   ```

4. **Add to plugins.ini:**
   - Edit `hlds\cstrike\addons\amxmodx\configs\plugins.ini`
   - Add at the end:
   ```
   ai_bridge.amxx
   ```

5. **Copy AI Bridge configuration:**
   ```powershell
   Copy-Item -Path "..\..\..\..\addons\amxmodx\configs\ai_bridge.cfg" -Destination "..\configs\"
   ```

## Step 7: Verify Installation

1. **Start the server:**
   ```powershell
   cd C:\Projects\cs_zombie_ai
   .\scripts\start_server.bat
   ```

2. **Check the console for:**
   - Metamod-R loading message
   - AMX Mod X version display
   - Zombie Plague loading confirmation
   - YaPB initialization
   - No error messages about missing files

3. **In the server console, type:**
   ```
   meta list
   ```
   You should see:
   - AMX Mod X
   - YaPB

4. **Type:**
   ```
   amxx plugins
   ```
   You should see the Zombie Plague plugins and ai_bridge listed

## Step 8: Test the Server

1. **Add bots:**
   In server console: `yapb add`

2. **Check Zombie Plague:**
   - Bots should spawn as humans/zombies
   - Round should start with infection countdown

3. **For AI functionality:**
   - Start the Python sidecar service (separate guide)
   - Check for "[ai_bridge] sent snapshot" messages

## Troubleshooting

- **"Metamod not loaded"**: Check liblist.gam or game.cfg configuration
- **"Module not found"**: Enable required modules in modules.ini
- **"Plugin failed to load"**: Check compilation and file paths
- **"Sockets module required"**: Uncomment sockets in modules.ini
- **Bots not joining**: Check yapb.dll is loaded in metamod plugins

## Next Steps

After successful installation:
1. Configure Python AI sidecar service
2. Train the XGBoost model
3. Test AI-controlled zombie behavior
4. Customize Zombie Plague settings in `zombieplague.cfg`