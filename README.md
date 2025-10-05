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

## Setup AI Bridge (First Time Only)

### 1. Generate Waypoints for zm_dust2

Start the server and auto-generate waypoints:

```powershell
# Start server
scripts\start_server.bat

# In server console or game console:
yb graph analyze
```

Wait 5-15 minutes for waypoint generation to complete. Waypoints will be saved automatically.

### 2. Compile AI Bridge Plugin

```powershell
scripts\compile_ai_bridge.bat
```

This will compile and install the `ai_bridge.amxx` plugin.

### 3. Setup Python Environment

```powershell
cd python_sidecar
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
```

## Running the AI System

### Terminal 1: Start Python AI Sidecar
```powershell
scripts\start_python_sidecar.bat
```

### Terminal 2: Start CS 1.6 Server
```powershell
scripts\start_server.bat
```

### Add Bots
In server console:
```
yb add 8
```

You should see `[ai_bridge] sent snapshot` messages indicating communication is working.

## Files Structure
- [addons/amxmodx/scripting/ai_bridge.sma](addons/amxmodx/scripting/ai_bridge.sma) - AMXX plugin source
- [python_sidecar/ai_server.py](python_sidecar/ai_server.py) - Python AI decision service
- [python_sidecar/train/](python_sidecar/train/) - ML training pipeline
- [scripts/](scripts/) - Startup and compilation batch files
- [docs/WAYPOINT_AND_AI_SETUP.md](docs/WAYPOINT_AND_AI_SETUP.md) - Detailed waypoint and AI bridge setup guide

## Configuration
Edit [addons/amxmodx/configs/ai_bridge.cfg](addons/amxmodx/configs/ai_bridge.cfg) to adjust:
- UDP port (default: 31337)
- Tick rate (default: 150ms)
- Logging options

## Documentation
- [Waypoint & AI Bridge Setup Guide](docs/WAYPOINT_AND_AI_SETUP.md) - Complete guide to waypoints and AI integration
- [CLAUDE.md](CLAUDE.md) - Project instructions for Claude Code