# Quick Start Guide - Getting Waypoints & AI Working

## Current Status
✅ HLDS server working with Metamod-R, AMX Mod X, ReHLDS
✅ Zombie Plague 5.0 installed
✅ YaPB bots installed
✅ zm_dust2 map added
❌ **Waypoints not generated** (you need to do this)
❌ **AI bridge not compiled** (you need to do this)

## 3-Step Setup Process

### Step 1: Generate Waypoints (MUST DO FIRST)

**Why?** Bots need navigation graphs to know where to walk on zm_dust2.

**How:**

1. Start the server:
   ```powershell
   scripts\start_server.bat
   ```

2. In the **server console window**, type:
   ```
   yb graph analyze
   ```

3. **Wait 5-15 minutes** while YaPB automatically:
   - Walks around the entire map
   - Creates navigation nodes
   - Connects nodes together
   - Saves to `hlds\cstrike\addons\yapb\data\graph\zm_dust2.pwf`

4. You'll see progress messages like:
   ```
   [YaPB] Analyzing... 25%
   [YaPB] Analyzing... 50%
   [YaPB] Analyzing... 100%
   [YaPB] Graph saved for zm_dust2
   ```

5. **Verify** waypoints exist:
   ```powershell
   # Check if file was created
   dir hlds\cstrike\addons\yapb\data\graph
   ```

**Alternative:** Download pre-made waypoints from https://github.com/yapb/graph if available for zm_dust2.

---

### Step 2: Compile AI Bridge Plugin

**Why?** The AI bridge connects your game server to the Python ML service via UDP.

**How:**

Run the compilation script:
```powershell
scripts\compile_ai_bridge.bat
```

This will:
- Copy `ai_bridge.sma` to HLDS scripting folder
- Compile it to `ai_bridge.amxx`
- Install it to plugins folder

**Verify:**
```powershell
dir hlds\cstrike\addons\amxmodx\plugins\ai_bridge.amxx
```

**Enable the plugin:**
Edit `hlds\cstrike\addons\amxmodx\configs\plugins.ini` and add:
```
ai_bridge.amxx
```

**Enable sockets module:**
Edit `hlds\cstrike\addons\amxmodx\configs\modules.ini` and ensure this line is **not commented**:
```
sockets
```

---

### Step 3: Setup Python Environment

**One-time setup:**
```powershell
cd python_sidecar
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
deactivate
```

---

## Running the System

### Terminal 1: Python AI (Start This First)
```powershell
scripts\start_python_sidecar.bat
```

**Expected output:**
```
[sidecar] listening on udp://127.0.0.1:31337
```

### Terminal 2: CS 1.6 Server
```powershell
scripts\start_server.bat
```

**Expected output:**
```
[ai_bridge] sent snapshot (234 bytes)
[ai_bridge] sent snapshot (241 bytes)
...
```

### Add Bots
In server console:
```
yb add 8
```

---

## Troubleshooting

### "No waypoints found for map"
- Run `yb graph analyze` in server console
- Wait for completion
- Check `hlds\cstrike\addons\yapb\data\graph\` folder

### "Plugin 'ai_bridge.amxx' failed to load"
- Make sure you ran `scripts\compile_ai_bridge.bat`
- Check `plugins.ini` has `ai_bridge.amxx` listed
- Check `modules.ini` has `sockets` enabled (no `;` in front)

### "Python sidecar not receiving data"
- Start Python sidecar **before** starting server
- Check firewall isn't blocking UDP port 31337
- Verify `ai_bridge.cfg` has correct port (31337)

### Bots don't move intelligently
- Make sure waypoints exist (Step 1)
- In server console, test with: `yb_debug_goal 50` (forces bots to waypoint 50)
- Check Python console shows received snapshots and sent commands

---

## Understanding the System Flow

```
1. Game Server (AMXX) collects game state every 150ms
   ↓
2. ai_bridge.amxx sends JSON snapshot via UDP to 127.0.0.1:31337
   ↓
3. Python ai_server.py receives snapshot
   ↓
4. Extracts features (distances, player counts, etc.)
   ↓
5. XGBoost model predicts attack probability
   ↓
6. Converts prediction to waypoint goal ID
   ↓
7. Sends JSON command back via UDP
   ↓
8. ai_bridge.amxx receives command
   ↓
9. Sets bot goal using YaPB command (yb_debug_goal)
   ↓
10. Bots navigate to waypoint using A* pathfinding
```

---

## Next Steps After Basic Setup Works

1. **Map waypoint IDs to tactical zones**
   - Use `yb_debug 3` to see waypoint IDs in-game
   - Note down IDs for CT spawn, mid, tunnels, bombsites
   - Update `python_sidecar/waypoint_map.py` with actual IDs

2. **Improve feature engineering**
   - Add more features to snapshot (HP, ammo, grenades)
   - Enhance Python featurization

3. **Train actual ML model**
   - Collect gameplay logs
   - Run `python_sidecar/train/make_dataset.py`
   - Run `python_sidecar/train/train_xgb.py`

4. **Per-bot control** (advanced)
   - Research YaPB natives for individual bot control
   - Update ai_bridge.sma to control each bot separately

---

## Key Files Reference

- **Waypoints:** `hlds\cstrike\addons\yapb\data\graph\zm_dust2.pwf`
- **Plugin source:** `addons\amxmodx\scripting\ai_bridge.sma`
- **Compiled plugin:** `hlds\cstrike\addons\amxmodx\plugins\ai_bridge.amxx`
- **Plugin config:** `addons\amxmodx\configs\ai_bridge.cfg`
- **Python AI:** `python_sidecar\ai_server.py`
- **YaPB config:** `hlds\cstrike\addons\yapb\conf\yapb.cfg`

---

## Useful Console Commands

### YaPB Commands
```
yb add 8                    # Add 8 bots
yb kick                     # Kick all bots
yb graph analyze            # Auto-generate waypoints
yb graph info               # Show waypoint count
yb_debug 3                  # Show waypoint IDs in 3D
yb_debug_goal 50            # Force all bots to waypoint 50
yb_debug_goal -1            # Restore normal behavior
```

### AMXX Commands
```
amx_plugins                 # List loaded plugins
amx_modules                 # List loaded modules
meta list                   # List Metamod plugins
```

### Server Commands
```
status                      # Show connected players/bots
map zm_dust2                # Change map
sv_restart 1                # Restart round
```

---

## Getting Help

If you're stuck:

1. Check [docs/WAYPOINT_AND_AI_SETUP.md](docs/WAYPOINT_AND_AI_SETUP.md) for detailed explanations
2. Review server console for error messages
3. Check Python console for exceptions
4. Verify all files are in correct locations
5. Make sure you completed all 3 setup steps in order
