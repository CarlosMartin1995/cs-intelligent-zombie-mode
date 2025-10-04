# Manual Download Links for CS 1.6 Zombie AI Server

## Required Downloads

### 1. AMX Mod X (if automatic download fails)
Go to: https://www.amxmodx.org/downloads.php
- Download: **AMX Mod X 1.9** for Windows
- You need TWO files:
  - `amxmodx-1.9.0-git5271-base-windows.zip`
  - `amxmodx-1.9.0-git5271-cstrike-windows.zip`
- Extract BOTH to: `C:\Projects\cs_zombie_ai\hlds\cstrike\`

### 2. Zombie Plague
**Option A - Zombie Plague 5.0.8 (Recommended)**
- Download: https://forums.alliedmods.net/showthread.php?t=72505
- Extract to: `C:\Projects\cs_zombie_ai\hlds\cstrike\`

**Option B - Zombie Plague 4.3**
- Download: https://forums.alliedmods.net/showthread.php?p=1122111
- Simpler version, good for testing

### 3. YaPB (Yet Another POD Bot)
- Latest Release: https://github.com/yapb/yapb/releases/latest
- Download: `yapb-4.x.xxx.zip` (Windows version)
- Extract to: `C:\Projects\cs_zombie_ai\hlds\cstrike\addons\yapb\`

### 4. Waypoints for YaPB
- Official pack: https://github.com/yapb/graph
- Download the whole repository
- Copy `.pwf` files to: `C:\Projects\cs_zombie_ai\hlds\cstrike\addons\yapb\data\pwf\`

## Installation Order
1. AMX Mod X (base + cstrike)
2. Zombie Plague
3. YaPB
4. Waypoints

## After Manual Download
Run these commands to verify:
```powershell
# Check if AMX Mod X is installed
dir C:\Projects\cs_zombie_ai\hlds\cstrike\addons\amxmodx\

# Copy our AI bridge files
copy C:\Projects\cs_zombie_ai\addons\amxmodx\configs\*.* C:\Projects\cs_zombie_ai\hlds\cstrike\addons\amxmodx\configs\
copy C:\Projects\cs_zombie_ai\addons\amxmodx\scripting\ai_bridge.sma C:\Projects\cs_zombie_ai\hlds\cstrike\addons\amxmodx\scripting\
```