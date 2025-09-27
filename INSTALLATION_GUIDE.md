# CS 1.6 Zombie AI Server - Installation Guide

This guide explains how to set up the complete server environment from a fresh clone of the repository.

## Prerequisites

1. **Windows 10/11** with PowerShell
2. **Python 3.10+** installed
3. **~2GB free disk space**
4. **Counter-Strike 1.6 client** (for testing)

## Quick Start

### Step 1: Clone Repository
```bash
git clone https://github.com/yourusername/cs_zombie_ai.git
cd cs_zombie_ai
```

### Step 2: Download Resource Pack
Download the resource pack (`cs16_zombie_ai_resources.zip`) from the releases page and extract it to the `downloads/` folder.

The resource pack contains:
- ReHLDS.zip (3.1 MB)
- Metamod-r.zip (870 KB)
- AMX Mod X files (4.5 MB + 355 KB)
- YaPB bot files (7.6 MB)
- Zombie Plague files (3.5 MB)
- SteamCMD.exe (4.3 MB)

### Step 3: Run Complete Setup
```powershell
powershell -ExecutionPolicy Bypass -File scripts\COMPLETE_SETUP.ps1
```

This script will:
1. Install HLDS via SteamCMD (~900 MB download)
2. Install ReHLDS (optimized engine)
3. Install and configure Metamod-r
4. Install AMX Mod X
5. Install and configure YaPB bots
6. Install and compile Zombie Plague 5.0
7. Configure all server settings
8. Setup Python environment for AI

## Manual Installation Steps

If you prefer manual installation or need to fix specific components:

### 1. Install HLDS
```powershell
scripts\install_hlds.bat
```

### 2. Install Server Components
```powershell
# Install ReHLDS and Metamod
powershell -ExecutionPolicy Bypass -File scripts\install_server_files.ps1

# Install Zombie Plague
powershell -ExecutionPolicy Bypass -File scripts\install_zombie_plague.ps1

# Apply configurations
powershell -ExecutionPolicy Bypass -File scripts\apply_configurations.ps1
```

### 3. Setup Python Environment
```powershell
cd python_sidecar
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
```

## Configuration Files

All server configurations are stored in the `configs/` folder:

- `liblist.gam` - Enables Metamod
- `server.cfg` - Server settings
- `metamod/plugins.ini` - Loaded plugins (AMX Mod X, YaPB)
- `amxmodx/plugins.ini` - AMX Mod X plugins
- `amxmodx/modules.ini` - AMX Mod X modules

## File Structure After Installation

```
cs_zombie_ai/
├── configs/              # Configuration templates
├── downloads/            # Resource files (not in Git)
├── hlds/                 # Game server (not in Git)
│   └── cstrike/
│       ├── addons/
│       │   ├── amxmodx/  # AMX Mod X
│       │   ├── metamod/  # Metamod-r
│       │   └── yapb/     # YaPB bots
│       ├── models/       # Zombie models
│       └── sound/        # Zombie sounds
├── python_sidecar/       # AI service
├── scripts/              # Setup & utility scripts
└── addons/               # Source files for AI bridge

## Running the Server

### Basic Zombie Mode (No AI)
```batch
scripts\start_server.bat
```

### With AI Features
```batch
# Terminal 1
scripts\start_python_sidecar.bat

# Terminal 2
scripts\start_server.bat
```

Then edit `hlds\cstrike\addons\amxmodx\configs\plugins.ini` and uncomment `ai_bridge.amxx`.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "steamcmd not found" | Run `scripts\download_steamcmd.ps1` |
| "metamod.dll not found" | Run `scripts\apply_configurations.ps1` |
| Zombie Plague not working | Check if `zp50_core.amxx` is in plugins.ini |
| Bots not joining | Check if YaPB is in metamod plugins.ini |
| Socket error in AMXX | Sockets module is already enabled in modules.ini |

## Server Details

- **Hostname**: CS16 Zombie AI Lab
- **Port**: 27015
- **RCON Password**: zombie_ai_2024
- **Bot Count**: 8 (auto-fill)
- **Game Mode**: Zombie Plague 5.0

## Updating Configuration

After making changes to server files, copy them back to the repository:

```powershell
# Copy current liblist.gam
Copy-Item hlds\cstrike\liblist.gam configs\

# Copy current configs
Copy-Item hlds\cstrike\server.cfg configs\
Copy-Item hlds\cstrike\addons\metamod\plugins.ini configs\metamod\
Copy-Item hlds\cstrike\addons\amxmodx\configs\plugins.ini configs\amxmodx\
```

## Development Workflow

1. Make changes to configuration files in `configs/`
2. Run `scripts\apply_configurations.ps1` to apply them
3. Test the server
4. Commit configuration changes to Git

This ensures all developers can reproduce the exact same server state.