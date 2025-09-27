# Current Installation Status

## ✅ Completed
- [x] SteamCMD installed
- [x] HLDS base files downloaded
- [x] ReHLDS downloaded
- [x] Metamod-r downloaded
- [x] AMX Mod X manually downloaded and extracted to `hlds\cstrike\addons\amxmodx\`

## 📋 Next Steps (In Order)

### 1. Install ReHLDS and Configure Server
```powershell
powershell -ExecutionPolicy Bypass -File C:\Projects\cs_zombie_ai\scripts\install_server_files.ps1
```

### 2. Set up Python Environment
```powershell
cd C:\Projects\cs_zombie_ai\python_sidecar
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
```

### 3. Compile AI Bridge Plugin
```powershell
# Copy files
copy C:\Projects\cs_zombie_ai\addons\amxmodx\scripting\ai_bridge.sma C:\Projects\cs_zombie_ai\hlds\cstrike\addons\amxmodx\scripting\
copy C:\Projects\cs_zombie_ai\addons\amxmodx\configs\*.* C:\Projects\cs_zombie_ai\hlds\cstrike\addons\amxmodx\configs\

# Compile
cd C:\Projects\cs_zombie_ai\hlds\cstrike\addons\amxmodx\scripting
.\compile.exe ai_bridge.sma
copy compiled\ai_bridge.amxx ..\plugins\
```

### 4. Test Basic Server
```powershell
cd C:\Projects\cs_zombie_ai\hlds
.\hlds.exe -game cstrike -console -port 27015 +maxplayers 16 +map de_dust2
```

## ⏳ Pending (Optional for Now)
- [ ] Download and install Zombie Plague
- [ ] Download and install YaPB bots
- [ ] Download waypoint files

## 📁 Current Directory Structure
```
C:\Projects\cs_zombie_ai\
├── hlds\                    ✅ HLDS installed
│   └── cstrike\
│       └── addons\
│           ├── amxmodx\     ✅ AMX Mod X installed
│           └── metamod\     ✅ Metamod-r installed
├── downloads\              ✅ ReHLDS and Metamod files ready
├── python_sidecar\         ✅ Python AI code ready
├── scripts\                ✅ All helper scripts created
└── addons\                 ✅ AI Bridge source files ready
```