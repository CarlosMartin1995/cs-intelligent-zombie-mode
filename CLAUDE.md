# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a CS 1.6 Zombie AI mod that integrates machine learning (XGBoost) with Counter-Strike 1.6 gameplay. The architecture consists of:
- HLDS/ReHLDS game server with Metamod-R and AMX Mod X
- Python sidecar service that processes game snapshots and returns AI decisions
- UDP communication bridge between the game server and Python AI service

## Key Commands

### Setup & Installation
```powershell
# Automated setup with downloads
.\scripts\AUTOMATED_SETUP.ps1

# Setup with existing HLDS installation
.\scripts\AUTOMATED_SETUP.ps1 -HLDSPath "C:\path\to\existing\hlds"

# Download SteamCMD (if needed)
powershell -ExecutionPolicy Bypass -File scripts\download_steamcmd.ps1

# Install server files after manual downloads
powershell -ExecutionPolicy Bypass -File scripts\install_server_files.ps1
```

### Python Environment
```powershell
# Setup Python virtual environment
cd python_sidecar
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
```

### Running Services
```batch
# Terminal 1: Start Python AI service (must run first)
scripts\start_python_sidecar.bat

# Terminal 2: Start CS 1.6 server
scripts\start_server.bat
```

### Compiling AMXX Plugin
```powershell
# Copy and compile the AI bridge plugin
copy addons\amxmodx\scripting\ai_bridge.sma hlds\cstrike\addons\amxmodx\scripting\
cd hlds\cstrike\addons\amxmodx\scripting
.\compile.exe ai_bridge.sma
copy compiled\ai_bridge.amxx ..\plugins\
```

### ML Model Training
```python
# Generate training dataset
cd python_sidecar\train
python make_dataset.py

# Train XGBoost model
python train_xgb.py
```

## Architecture Details

### Communication Flow
1. **Game Server (HLDS)** → Sends game snapshots via UDP every 150ms
2. **AI Bridge (ai_bridge.amxx)** → AMX Mod X plugin that collects game state
3. **Python Sidecar (ai_server.py)** → Receives snapshots on UDP port 31337
4. **XGBoost Model** → Processes features and returns attack probabilities
5. **Bot Commands** → Sent back to game server with waypoint goals and aggression levels

### UDP Protocol
- Port: 31337 (configurable in ai_bridge.cfg)
- Format: JSON messages with game state snapshots and AI commands
- Tick rate: 150ms (configurable)

### Key Files Structure
- `addons/amxmodx/scripting/ai_bridge.sma` - AMXX plugin source (needs compilation)
- `python_sidecar/ai_server.py` - Main Python AI decision service
- `python_sidecar/train/` - ML training pipeline
  - `make_dataset.py` - Dataset generation
  - `train_xgb.py` - Model training
  - `schema.yaml` - Feature definitions
- `scripts/AUTOMATED_SETUP.ps1` - Main installer script

### Feature Engineering
The AI model uses these features (defined in python_sidecar/train/schema.yaml):
- `mean_dist_h`: Mean distance to alive humans
- `humans_within_600`: Number of humans within 600 units
- `ratio_z_h`: Ratio of zombies to humans alive
- `phase_code`: Game phase (0=early, 1=mid, 2=late)
- `map_cp_density`: Map chokepoint density score

### Model Configuration
- Type: XGBoost binary classifier
- Location: `python_sidecar/models/xgb_zombie.json`
- Hyperparameters: n_estimators=300, max_depth=5, learning_rate=0.08

## Development Notes

### Required Manual Downloads
The automated setup requires these files in `downloads/` folder:
- ReHLDS.zip
- Metamod-r.zip
- AMX Mod X (base and cstrike packages)
- YaPB bot files
- Zombie Plague mod files

### Testing Checklist
- Server starts without errors
- Python sidecar shows "listening on udp://127.0.0.1:31337"
- HLDS console shows "[ai_bridge] sent snapshot" messages
- Bots join and respond to AI commands

### Common Issues
- **Socket errors**: Enable sockets module in modules.ini
- **No AI commands**: Ensure Python sidecar is running before starting server
- **Compilation errors**: Use compile.exe from AMX Mod X installation