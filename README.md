# CS 1.6 Zombie AI Server

AI-powered Counter-Strike 1.6 server with intelligent zombie gameplay using XGBoost ML models.

## Architecture

```
[Windows 11 host]
 ├─ HLDS/ReHLDS (CS 1.6 Dedicated Server)
 │   └─ Metamod-R
 │       └─ AMX Mod X
 │           ├─ Zombie Mod
 │           ├─ YaPB (bots)
 │           └─ ai_bridge.amxx
 └─ Python Sidecar (ai_server.py)
     └─ XGBoost Model
```

## Quick Start

### Prerequisites
1. Windows 10+ computer
2. Python 3.10 installed

### Commands

With the following command you can start the server locally:
```bash
scripts\start_server.bat
```

By default it starts the server in de_dust2.

The server is already configured with YaPB bots and Zombie Plague 5.0.

## Python Stage WIP

### Setup Python Environment
```powershell
cd python_sidecar
py -3 -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
```

### Run Services
1. Start Python sidecar: `scripts\start_python_sidecar.bat`
2. Start CS server: `scripts\start_server.bat`

## Files Structure
- `addons/amxmodx/scripting/ai_bridge.sma` - AMXX plugin source
- `python_sidecar/ai_server.py` - Python AI decision service
- `python_sidecar/train/` - ML training pipeline
- `scripts/` - Startup batch files

## Configuration
Edit `addons/amxmodx/configs/ai_bridge.cfg` to adjust:
- UDP port (default: 31337)
- Tick rate (default: 150ms)
- Logging options