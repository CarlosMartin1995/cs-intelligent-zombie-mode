# YaPB Waypoints & AI Bridge Setup Guide

## Overview

This guide walks you through:
1. Generating waypoints for zm_dust2
2. Understanding YaPB waypoint system
3. Compiling and setting up the AI bridge
4. Connecting Python AI to control bots via waypoints

---

## Part 1: Generating Waypoints for zm_dust2

### What are Waypoints?

Waypoints (`.pwf` files) are navigation graphs that tell bots where they can walk, important positions (bomb sites, camping spots, goals), and how nodes connect. YaPB uses these for pathfinding.

### Option A: Download Existing Waypoints (Recommended)

YaPB can auto-download waypoints from their database:

1. **Enable auto-download** - Already configured in `yapb.cfg`:
   ```
   yb_graph_url "yapb.jeefo.net"
   ```

2. **Start server and let it download**:
   - YaPB will attempt to fetch `zm_dust2.pwf` automatically
   - Check console for download messages

3. **Manual download** (if auto-download fails):
   ```powershell
   # Download from YaPB repository
   # Check: https://github.com/yapb/graph
   # or http://yapb.jeefo.net/
   ```

### Option B: Generate Waypoints Automatically

If no waypoints exist, YaPB can auto-generate them:

1. **Start server** with zm_dust2:
   ```powershell
   scripts\start_server.bat
   ```

2. **Join the server** (console command):
   ```
   connect 127.0.0.1:27015
   ```

3. **Auto-generate waypoints** (in server console or client console):
   ```
   yb graph analyze
   ```

   This will:
   - Bot will walk around the map analyzing geometry
   - Create navigation nodes automatically
   - Save to `hlds\cstrike\addons\yapb\data\graph\zm_dust2.pwf`
   - Takes 5-15 minutes depending on map size

4. **Check progress** in console - you'll see analysis percentage

5. **When complete**, waypoints are auto-saved

### Option C: Create Waypoints Manually (Advanced)

For precise control:

1. **Enable waypoint editor**:
   ```
   yb wpteditor
   ```

2. **Editor commands**:
   - `yb waypoint add` - Add node at your position
   - `yb waypoint delete` - Remove nearest node
   - `yb waypoint setradius <value>` - Set node radius
   - `yb waypoint addflags <flags>` - Mark as camp/goal/etc
   - `yb waypoint save` - Save changes

3. **Key waypoint flags**:
   - `goal` - Important tactical positions (bomb sites, objectives)
   - `camp` - Camping/defensive positions
   - `rescue` - Hostage rescue zones
   - `sniper` - Good sniper positions
   - `terrorist` / `ct` - Team-specific nodes

---

## Part 2: Understanding YaPB Waypoint System

### Waypoint File Location

```
hlds\cstrike\addons\yapb\data\graph\zm_dust2.pwf
```

### Waypoint Node Structure

Each waypoint node contains:
- **Position** (x, y, z coordinates)
- **Radius** (how close bot must be)
- **Flags** (goal, camp, ladder, etc.)
- **Connections** (links to other nodes for pathfinding)
- **Connection flags** (normal, jump, crouch, etc.)

### How Bots Use Waypoints

1. **Pathfinding**: A* algorithm to find route from current node → goal node
2. **Goals**: Nodes marked with "goal" flag (bomb sites, camp spots)
3. **Tactical positions**: Nodes with special flags guide behavior

### Key YaPB Console Commands

```bash
# View waypoint info
yb graph info

# Set debug goal for all bots (force them to waypoint ID)
yb_debug_goal <waypoint_id>

# List nearby waypoints
yb waypoint showpath

# Enable debug visualization
yb_debug 3
```

---

## Part 3: Understanding Waypoint IDs for AI Control

### Finding Waypoint IDs

YaPB waypoints are numbered 0 to N (where N = total waypoints - 1).

**Method 1: In-game visualization**
```
yb_debug 3              # Enable debug mode
yb_graph_draw_distance 2000   # Increase view distance
```
This shows waypoint IDs in 3D space.

**Method 2: Console command**
```
yb graph info
```
Shows total waypoint count.

**Method 3: Force bots to specific waypoints**
```
yb_debug_goal 134       # All bots path to waypoint 134
yb_debug_goal -1        # Restore normal behavior
```

### Important Waypoints for Zombie Mod

For zm_dust2, you'll want to identify:
- **CT spawn area** waypoints (humans start here)
- **T spawn area** waypoints (zombies start here)
- **Chokepoints** (tunnels, doors)
- **Open areas** (mid, bombsite A/B)
- **Defensive positions** (corners, elevated spots)

### Strategy for AI Control

Your Python AI will send **goal waypoint IDs** to steer zombie bots:

```python
# Example from ai_server.py
goal_wp = 134 if p_attack > 0.6 else 78
```

**You need to map tactical decisions to waypoint IDs:**

```python
# Define strategic waypoint zones
WAYPOINT_ZONES = {
    "ct_spawn": [0, 1, 2, 3, 4],        # Human base
    "tunnels": [45, 46, 47, 48],         # Underground route
    "mid": [89, 90, 91, 92],             # Middle area
    "bombsite_a": [120, 121, 122, 123],  # Site A
    "bombsite_b": [150, 151, 152, 153],  # Site B
    "t_spawn": [200, 201, 202]           # Zombie spawn
}

def pick_attack_route(features):
    if features["humans_in_mid"] > 2:
        return random.choice(WAYPOINT_ZONES["tunnels"])  # Flank
    else:
        return random.choice(WAYPOINT_ZONES["mid"])       # Direct
```

---

## Part 4: Compiling the AI Bridge Plugin

### Step 1: Copy Source to HLDS

The plugin source is already at:
```
addons\amxmodx\scripting\ai_bridge.sma
```

Copy it to HLDS scripting folder:

```powershell
# Create directory if needed
New-Item -ItemType Directory -Force -Path "hlds\cstrike\addons\amxmodx\scripting"

# Copy source file
Copy-Item "addons\amxmodx\scripting\ai_bridge.sma" -Destination "hlds\cstrike\addons\amxmodx\scripting\ai_bridge.sma"
```

### Step 2: Compile the Plugin

**Option A: Use AMXX Compiler (Windows)**

```powershell
cd hlds\cstrike\addons\amxmodx\scripting
.\compile.exe ai_bridge.sma
```

The compiled `.amxx` file will be in `compiled\ai_bridge.amxx`

**Option B: Use batch script**

```powershell
cd hlds\cstrike\addons\amxmodx\scripting
.\amxxpc.exe ai_bridge.sma -ocompiled\ai_bridge.amxx
```

### Step 3: Install Compiled Plugin

```powershell
# Copy compiled plugin to plugins folder
Copy-Item "hlds\cstrike\addons\amxmodx\scripting\compiled\ai_bridge.amxx" -Destination "hlds\cstrike\addons\amxmodx\plugins\ai_bridge.amxx"
```

### Step 4: Enable Plugin

Edit `hlds\cstrike\addons\amxmodx\configs\plugins.ini` and add:

```ini
ai_bridge.amxx
```

### Step 5: Enable Sockets Module

Edit `hlds\cstrike\addons\amxmodx\configs\modules.ini` and ensure:

```ini
sockets
```

is **NOT** commented out (remove `;` if present).

---

## Part 5: Connecting YaPB to Your AI Bridge

### Current Issue: YaPB Control API

The `ai_bridge.sma` code has a **TODO** section:

```c
// TODO: if your YaPB exposes natives, call them here (preferred).
// Fallback: issue a console command to steer a specific bot (version-dependent).
```

### YaPB Control Options

**Option 1: Use `yb_debug_goal` (Global Control - Simple)**

This affects **ALL** bots at once:

```c
// In ai_bridge.sma
server_cmd("yb_debug_goal %d", goal_wp);
```

**Pros**: Easy, works immediately
**Cons**: All zombie bots go to same waypoint (not individual control)

**Option 2: Use YaPB Natives (Advanced - Per-Bot Control)**

YaPB 4.4 may expose natives for individual bot control. Check:

```c
#include <yapb>

// Hypothetical native (check yapb.inc if it exists)
native yapb_set_goal(bot_index, waypoint_id);
```

Look for `hlds\cstrike\addons\amxmodx\scripting\include\yapb.inc`

**Option 3: Hybrid Approach (Recommended for Now)**

Use global goals for groups:

```c
// ai_bridge.sma - tick_recv_cmds()
public tick_recv_cmds() {
    if (!g_enabled || !g_sock) return;

    new recvbuf[1200], fromip[32], fromport;
    new r = socket_recvfrom(g_sock, recvbuf, charsmax(recvbuf), fromip, fromport);
    if (r <= 0) return;

    // Parse JSON for goal_wp
    new i = containi(recvbuf, "\"goal_wp\":");
    if (i != -1) {
        i += 10;
        new goal = str_to_num(recvbuf[i]);

        // Apply to all bots (or filter by team)
        server_cmd("yb_debug_goal %d", goal);

        if (g_log) server_print("[ai_bridge] Set goal waypoint -> %d", goal);
    }
}
```

---

## Part 6: Testing the Full Pipeline

### Terminal 1: Start Python AI Sidecar

```powershell
cd python_sidecar
.\.venv\Scripts\activate
python ai_server.py
```

**Expected output:**
```
[sidecar] listening on udp://127.0.0.1:31337
```

### Terminal 2: Start CS 1.6 Server

```powershell
scripts\start_server.bat
```

**In server console, you should see:**
```
[ai_bridge] sent snapshot (234 bytes)
[ai_bridge] sent snapshot (241 bytes)
...
```

### Terminal 3: Connect as Client (Optional)

```
In CS 1.6 client:
console -> connect 127.0.0.1:27015
```

### Add Bots

In server console or game console:
```
yb add 8  # Add 8 YaPB bots
```

### Monitor Behavior

**Python console** should show:
- Receiving snapshots
- Processing features
- Sending commands

**Server console** should show:
- `[ai_bridge] sent snapshot`
- `[ai_bridge] cmd -> bot X to wp Y`

### Debug Commands

```bash
# See waypoint info
yb graph info

# Force specific goal to test
yb_debug_goal 50

# View bot debug info
yb_debug 3

# Check plugin is loaded
amx_plugins
```

---

## Part 7: Mapping Waypoints to Tactics

### Step 1: Export Waypoint Positions

**Create a helper AMXX plugin to dump waypoints:**

```c
// waypoint_dumper.sma
#include <amxmodx>

public plugin_init() {
    register_plugin("Waypoint Dumper", "1.0", "dev");
    register_srvcmd("dump_waypoints", "cmd_dump");
}

public cmd_dump() {
    // Use yb_graph commands to extract data
    server_cmd("yb graph info");
    return PLUGIN_HANDLED;
}
```

### Step 2: Create Waypoint Map in Python

```python
# python_sidecar/waypoint_map.py
WAYPOINT_TACTICS = {
    "zm_dust2": {
        "flank_route_a": [45, 46, 47, 120, 121],
        "pressure_mid": [89, 90, 91],
        "flank_route_b": [78, 79, 150, 151],
        "ct_base_attack": [0, 1, 2],
        "defensive_hold": [92, 93, 94]
    }
}

import random

def get_tactical_waypoint(map_name, tactic):
    """Get random waypoint from a tactical zone"""
    waypoints = WAYPOINT_TACTICS.get(map_name, {}).get(tactic, [])
    return random.choice(waypoints) if waypoints else -1
```

### Step 3: Use in ai_server.py

```python
from waypoint_map import get_tactical_waypoint

def decide(snapshot):
    map_name = snapshot.get("map", "zm_dust2")
    bot_ids, X = featurize(snapshot)
    cmds = []

    if len(bot_ids) == 0:
        return {"cmds": cmds}

    proba = model.predict_proba(X)[:,1] if X.shape[0] else np.array([])

    for i, bid in enumerate(bot_ids):
        p_attack = float(proba[i]) if proba.size else 0.5

        # Choose tactic based on ML prediction
        if p_attack > 0.7:
            tactic = "pressure_mid"
            mode = "aggressive"
        elif p_attack > 0.5:
            tactic = "flank_route_a"
            mode = "flank"
        else:
            tactic = "defensive_hold"
            mode = "defensive"

        goal_wp = get_tactical_waypoint(map_name, tactic)
        agg = max(0.4, min(1.0, p_attack + 0.3))

        cmds.append({
            "id": bid,
            "goal_wp": goal_wp,
            "agg": agg,
            "mode": mode
        })

    return {"cmds": cmds}
```

---

## Part 8: Improved AI Bridge (Per-Bot Control Attempt)

### Enhanced ai_bridge.sma

```c
public tick_recv_cmds() {
    if (!g_enabled || !g_sock) return;

    new recvbuf[1200], fromip[32], fromport;
    new r = socket_recvfrom(g_sock, recvbuf, charsmax(recvbuf), fromip, fromport);
    if (r <= 0) return;

    // Parse multiple bot commands
    new i = 0;
    while ((i = containi(recvbuf[i], "\"id\":")) != -1) {
        i += 5;
        new bid = str_to_num(recvbuf[i]);

        // Find goal_wp for this bot
        new j = containi(recvbuf[i], "\"goal_wp\":");
        if (j == -1) break;
        j += 10;
        new goal = str_to_num(recvbuf[j]);

        // Option 1: Global goal (simple)
        if (is_user_bot(bid) && is_user_alive(bid)) {
            server_cmd("yb_debug_goal %d", goal);
        }

        // Option 2: Per-bot control (if natives available)
        // yapb_set_goal(bid, goal);

        if (g_log) {
            server_print("[ai_bridge] bot #%d -> waypoint %d", bid, goal);
        }

        i += j;
    }
}
```

---

## Summary Checklist

- [ ] **Generate waypoints** for zm_dust2 (auto-analyze or download)
- [ ] **Verify waypoints** exist at `hlds\cstrike\addons\yapb\data\graph\zm_dust2.pwf`
- [ ] **Compile ai_bridge.sma** → `ai_bridge.amxx`
- [ ] **Copy plugin** to `plugins\` folder
- [ ] **Enable plugin** in `plugins.ini`
- [ ] **Enable sockets** module in `modules.ini`
- [ ] **Create waypoint map** for tactical zones (Python)
- [ ] **Test Python sidecar** receives snapshots
- [ ] **Test waypoint control** with `yb_debug_goal`
- [ ] **Map waypoint IDs** to tactical zones on zm_dust2
- [ ] **Integrate ML model** with waypoint selection logic

---

## Next Steps

1. **Generate waypoints first** - this is critical
2. **Compile and test AI bridge** - verify UDP communication
3. **Manually explore zm_dust2** with `yb_debug 3` to see waypoint IDs
4. **Map out key zones** (CT spawn, chokepoints, etc.) to waypoint IDs
5. **Update Python code** with actual waypoint mappings
6. **Test and iterate** on bot behavior

## Useful Resources

- YaPB GitHub: https://github.com/yapb/yapb
- YaPB Graph Database: https://github.com/yapb/graph
- AMXX Sockets: https://www.amxmodx.org/api/amxmodx/sockets
