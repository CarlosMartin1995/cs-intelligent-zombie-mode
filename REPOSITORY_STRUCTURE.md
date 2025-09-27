# Repository Structure for GitHub

## What Gets Committed to GitHub

### ✅ Code & Configuration (Small files)
```
cs_zombie_ai/
├── addons/                     # Custom plugin sources
│   └── amxmodx/
│       ├── configs/           # AI Bridge configs
│       └── scripting/         # ai_bridge.sma source
├── python_sidecar/            # Python AI server
│   ├── ai_server.py
│   ├── requirements.txt
│   └── train/                 # ML training scripts
├── scripts/                   # Setup & utility scripts
│   ├── AUTOMATED_SETUP.ps1   # Main installer
│   └── *.bat / *.ps1         # Helper scripts
├── .gitignore
├── README.md
├── SETUP_GUIDE.md
└── LICENSE
```

**Total Size**: < 1 MB

## What Goes to Google Drive

### 📦 Downloads Package (34 MB)
Create a ZIP file: `cs16_zombie_ai_resources.zip` containing:

```
downloads/
├── ReHLDS.zip                    # 3.1 MB
├── Metamod-r.zip                 # 870 KB
├── amxmod/
│   ├── amxmodx-*-base.zip       # 4.5 MB
│   └── amxmodx-*-cstrike.zip    # 355 KB
├── yapb-4.5.1199-windows.zip    # 2.0 MB
├── yapb-4.5.1199-extras.zip     # 5.6 MB
├── zp_plugin_50_patched.zip     # 298 KB
├── zp_resources.zip              # 3.2 MB
└── steamcmd.exe                  # 4.3 MB
```

## Installation Process

### For End Users:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/cs_zombie_ai.git
   cd cs_zombie_ai
   ```

2. **Download resources from Google Drive**:
   - Download: `cs16_zombie_ai_resources.zip` (link in README)
   - Extract to: `cs_zombie_ai/downloads/`

3. **Run automated setup**:
   ```powershell
   # Option A: Fresh install with SteamCMD
   .\scripts\AUTOMATED_SETUP.ps1

   # Option B: Use existing HLDS
   .\scripts\AUTOMATED_SETUP.ps1 -HLDSPath "C:\path\to\existing\hlds"
   ```

## Benefits of This Structure

1. **GitHub repository**: < 1 MB (fast to clone)
2. **Google Drive package**: 34 MB (one-time download)
3. **HLDS via SteamCMD**: 900 MB (automated download)
4. **Total setup time**: ~10-15 minutes

## Preparing for GitHub

### Commands to prepare clean repo:

```powershell
# Remove large directories
Remove-Item -Recurse -Force hlds
Remove-Item -Recurse -Force downloads\ReHLDS
Remove-Item -Recurse -Force downloads\Metamod-r

# Create .gitkeep files for structure
New-Item -ItemType File -Force python_sidecar\models\.gitkeep
New-Item -ItemType File -Force addons\amxmodx\plugins\.gitkeep

# Package downloads for Google Drive
Compress-Archive -Path downloads\* -DestinationPath cs16_zombie_ai_resources.zip
```