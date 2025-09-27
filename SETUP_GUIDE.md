# CS 1.6 Zombie AI Server - Setup Guide

## Prerequisites Checklist
- [ ] Windows 11 with Administrator privileges
- [ ] Python 3.10+ installed
- [ ] ~2GB free disk space
- [ ] Internet connection for downloads

## Setup Steps (Updated Process)

### 1. Download SteamCMD
```powershell
powershell -ExecutionPolicy Bypass -File scripts\download_steamcmd.ps1
```

### 2. Run Complete Server Setup
```powershell
powershell -ExecutionPolicy Bypass -File scripts\setup_complete_server.ps1
```
This will:
- Install HLDS base files via SteamCMD (✓ Completed)
- Download ReHLDS and Metamod-r (✓ Completed)
- AMX Mod X must be downloaded manually (see below)

### 3. Manual Downloads Required

#### AMX Mod X
- Download from: https://www.amxmodx.org/downloads.php
- Get TWO files: base-windows.zip and cstrike-windows.zip
- Place in: `C:\Projects\cs_zombie_ai\amxmod\`
- Extract with: `powershell -ExecutionPolicy Bypass -File scripts\extract_and_install_amx.ps1`

### 4. Complete Installation (After Manual Downloads)

Run this to install ReHLDS and configure Metamod:
```powershell
powershell -ExecutionPolicy Bypass -File scripts\install_server_files.ps1
```

This script will:
- Install ReHLDS engine files
- Configure Metamod-r
- Update liblist.gam automatically
- Create plugins.ini
- Set up server.cfg

### 5. Install Zombie Plague and YaPB

#### Download Links:
- **Zombie Plague 5.0.8**: https://forums.alliedmods.net/showthread.php?t=72505
- **YaPB**: https://github.com/yapb/yapb/releases

#### Installation:
1. Extract Zombie Plague to `hlds\cstrike\`
2. Extract YaPB to `hlds\cstrike\addons\yapb\`
3. Add YaPB to `hlds\cstrike\addons\metamod\plugins.ini`:
   ```
   win32 addons\yapb\bin\yapb.dll
   ```

### 6. Setup Python Environment
```powershell
cd C:\Projects\cs_zombie_ai\python_sidecar
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
```

### 7. Compile AI Bridge Plugin
```powershell
# Copy source file
copy C:\Projects\cs_zombie_ai\addons\amxmodx\scripting\ai_bridge.sma C:\Projects\cs_zombie_ai\hlds\cstrike\addons\amxmodx\scripting\

# Compile
cd C:\Projects\cs_zombie_ai\hlds\cstrike\addons\amxmodx\scripting
.\compile.exe ai_bridge.sma

# Install compiled plugin
copy compiled\ai_bridge.amxx ..\plugins\

# Copy configs
copy C:\Projects\cs_zombie_ai\addons\amxmodx\configs\*.* C:\Projects\cs_zombie_ai\hlds\cstrike\addons\amxmodx\configs\
```

### 8. Configure Waypoints (For YaPB)
1. Download waypoint packs for your maps
2. Place `.pwf` files in `hlds\cstrike\addons\yapb\data\pwf\`

## Running the Server

### Start Order:
1. **Terminal 1 - Python AI Service:**
   ```
   scripts\start_python_sidecar.bat
   ```
   Wait for: `[sidecar] listening on udp://127.0.0.1:31337`

2. **Terminal 2 - CS Server:**
   ```
   scripts\start_server.bat
   ```

### Verification:
- HLDS console should show: `[ai_bridge] sent snapshot`
- Python console should show received packets
- Join server: `connect localhost:27015` in CS 1.6

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "steamcmd not found" | Run `download_steamcmd.ps1` first |
| "metamod.dll not found" | Check liblist.gam path is correct |
| "Socket error" in AMXX | Enable sockets module in modules.ini |
| Bots don't join | Add bots manually: `yb add` in console |
| No AI commands | Check Python sidecar is running |

## Port Configuration
- **27015**: CS 1.6 game server (UDP)
- **31337**: AI Bridge UDP communication (local only)

## Testing Checklist
- [ ] Server starts without errors
- [ ] Can connect as player
- [ ] Bots join the game
- [ ] Zombie mode activates
- [ ] Python sidecar receives snapshots
- [ ] Bots receive AI commands