# CS 1.6 “Zombie AI” Server on Windows 11 — End-to-End Guide (with Claude Code Opus 4.1)

Build a Counter-Strike 1.6 server with Zombie gameplay, smart bot behaviors, and a Python sidecar that makes live tactical decisions (XGBoost).

---

## 0) What you’ll build (architecture)

```
[Windows 11 host]
 ├─ HLDS/ReHLDS (CS 1.6 Dedicated Server)
 │   └─ Metamod-R
 │       └─ AMX Mod X
 │           ├─ Zombie Mod (e.g., Zombie Plague)
 │           ├─ YaPB (bots + waypoints)
 │           └─ ai_bridge.amxx  ← sends/receives UDP messages
 └─ Python Sidecar (ai_server.py)
     ├─ Receives snapshots (JSON) from ai_bridge
     ├─ Runs a trained XGBoost model on features
     └─ Returns high-level orders to bots (flank/push/ambush)
```

Key ideas:
- **AMXX plugin** (`ai_bridge`) streams compact **snapshots** of the round to Python over **UDP** and applies returned **commands**.
- **YaPB** handles low-level movement/aim/pathfinding via **waypoints**. Your sidecar only decides *what* to do (not *how* to walk).
- **XGBoost**: train a small model offline on logs to decide *when* to push/flank.

---

## 1) Prerequisites

1) **Windows 11** with admin privileges.  
2) **SteamCMD** (for HLDS install).  
3) **HLDS / ReHLDS** base server for CS 1.6 (`cstrike` mod folder).  
4) **Metamod-R** + **AMX Mod X** (AMXX).  
5) **Zombie Mod** (e.g., Zombie Plague).  
6) **YaPB** (bot) + **waypoint packs** for your maps.  
7) **Python 3.10+** on Windows (`py` launcher available).  
8) **Claude Code Opus 4.1** (to run terminals/tasks & edit files comfortably).

> Tip: keep everything under `\cs_zombie_ai\` to avoid path issues.

---

## 2) Folder layout (create this now)

```
cs_zombie_ai\
├─ hlds\                         ← HLDS/ReHLDS installed here (contains \cstrike)
├─ addons\
│  └─ amxmodx\
│     ├─ configs\
│     │  ├─ ai_bridge.cfg
│     │  ├─ plugins.ini
│     │  └─ modules.ini
│     ├─ plugins\
│     │  ├─ ai_bridge.amxx
│     │  └─ zombie_plague.amxx    ← example
│     └─ scripting\
│        └─ ai_bridge.sma         ← source (compile to .amxx)
├─ python_sidecar\
│  ├─ requirements.txt
│  ├─ ai_server.py
│  ├─ models\
│  │  └─ xgb_zombie.json          ← produced by training
│  └─ train\
│     ├─ make_dataset.py
│     ├─ train_xgb.py
│     └─ schema.yaml
├─ waypoints\                     ← YaPB .pwf files per map
└─ scripts\
   └─ start_server.bat
```

Create the empty files now; paste content from this guide in later steps.

---

## 3) Install core server stack (once)

> Run these inside **Claude Code** integrated terminal or Windows Terminal (PowerShell).

### 3.1 HLDS / CS 1.6 via SteamCMD
```powershell
# Create stage folders
mkdir \steamcmd
mkdir \cs_zombie_ai\hlds

# Download steamcmd.zip manually and unzip to \steamcmd
# Then install HLDS (Half-Life Dedicated Server) with cstrike
cd \steamcmd
.\steamcmd.exe +login anonymous +force_install_dir "\cs_zombie_ai\hlds" +app_update 90 validate +quit
```

> After install, ensure `\cs_zombie_ai\hlds\cstrike\` exists.  
> (If `cstrike` folder is missing, install the Counter-Strike mod content for HLDS in the same dir.)

### 3.2 Install ReHLDS, Metamod-R, AMX Mod X, Zombie Mod, YaPB
1. **ReHLDS**: Copy `swds.dll` (and required DLLs) over HLDS binaries.  
2. **Metamod-R**: Put `metamod.dll` under `hlds\cstrike\dlls\` and edit `hlds\cstrike\liblist.gam` to point to it, e.g.:
   ```
   gamedll "dlls\metamod.dll"
   ```
3. **AMX Mod X**: Run the AMXX Windows installer targeting `\cs_zombie_ai\hlds\cstrike\`.  
   - Make sure `addons\amxmodx\` appears under `cstrike\addons\`.
4. **Zombie Mod (e.g., Zombie Plague)**: copy `.amxx` to `addons\amxmodx\plugins\` and its assets (models/sprites/sounds) to the paths the mod requires (usually under `cstrike\`).
5. **YaPB**: copy YaPB to `cstrike\addons\yapb\` (or as the package indicates) and add it to Metamod’s plugins.

**Metamod plugins file** — `\cs_zombie_ai\hlds\cstrike\addons\metamod\plugins.ini`
```
win32 addons\amxmodx\dlls\amxmodx_mm.dll
win32 addons\yapb\bin\yapb.dll
```

**AMXX plugins** — `\cs_zombie_ai\hlds\cstrike\addons\amxmodx\configs\plugins.ini`
```
; base
admin.amxx
; zombie gameplay
zombie_plague.amxx
; our bridge
ai_bridge.amxx
```

**AMXX modules** — `\cs_zombie_ai\hlds\cstrike\addons\amxmodx\configs\modules.ini`
```
; enable sockets module
sockets
; (you’ll likely also use fakemeta / hamsandwich depending on your mod)
fakemeta
hamsandwich
```

**Server config** — `\cs_zombie_ai\hlds\cstrike\server.cfg` (minimal)
```cfg
hostname "CS16 Zombie AI Lab"
rcon_password "CHANGE_ME_STRONG"
sv_lan 0
mp_autoteambalance 0
mp_limitteams 0
```

> **Firewall/Router**: Open/forward UDP **27015** to this PC. If local-only, keep `sv_lan 1`.

---

## 4) Start script (Windows)

`\cs_zombie_ai\scripts\start_server.bat`
```bat
@echo off
cd /d \cs_zombie_ai\hlds
start "" hlds.exe -game cstrike -console -port 27015 +maxplayers 16 +map de_dust2 +exec server.cfg
```

---

## 5) Configure the AI bridge (AMXX → Python)

### 5.1 Bridge config (edit values)
`\cs_zombie_ai\addons\amxmodx\configs\ai_bridge.cfg`
```cfg
aibridge_enabled 1
aibridge_host "127.0.0.1"
aibridge_port 31337
aibridge_tick_ms 150
aibridge_max_pkt 1200
aibridge_timeout_ms 400
aibridge_log 1
```

> Keep host on `127.0.0.1` for security. The plugin sends snapshots every `tick_ms` and listens for commands.

### 5.2 AMXX plugin source (skeleton)

`\cs_zombie_ai\addons\amxmodx\scripting\ai_bridge.sma`

> This is a **working skeleton** that:
> - Opens a UDP socket
> - Sends periodic **snapshots** (compact JSON)
> - Receives **commands** (a simple JSON array) and shows how to apply them
>
> **Note:** JSON parsing below is minimal and intentionally simple (pattern search). For production, swap in a proper JSON include if you use one. Also, YaPB control varies by version: prefer natives if available; else fall back to `server_cmd("yb ...")`.

```c
#include <amxmodx>
#include <fakemeta>
#include <sockets>

new g_sock, g_enabled, g_port, g_tick_ms, g_log;
new g_host[32];

public plugin_init() {
    register_plugin("AI Bridge", "0.1", "your_nick");

    // Cvars
    bind_pcvar_num( create_cvar("aibridge_enabled","1"), g_enabled );
    bind_pcvar_string( create_cvar("aibridge_host","127.0.0.1"), g_host, charsmax(g_host) );
    bind_pcvar_num( create_cvar("aibridge_port","31337"), g_port );
    bind_pcvar_num( create_cvar("aibridge_tick_ms","150"), g_tick_ms );
    bind_pcvar_num( create_cvar("aibridge_log","1"), g_log );

    // Open non-blocking UDP socket
    g_sock = socket_open(SOCKET_UDP, g_host, g_port, SOCKET_NONBLOCKING);

    set_task(float(g_tick_ms) / 1000.0, "tick_send_state", .flags="b");
    set_task(0.05, "tick_recv_cmds", .flags="b");
}

public plugin_end() {
    if (g_sock) socket_close(g_sock);
}

public tick_send_state() {
    if (!g_enabled || !g_sock) return;

    new buffer[1200], len = 0;
    new mapname[32]; get_mapname(mapname, charsmax(mapname));
    len += formatex(buffer[len], charsmax(buffer)-len, "{\"v\":0,\"t\":%d,\"map\":\"%s\",\"pl\":[", get_systime(), mapname);

    new maxp = get_maxplayers();
    new first = 1;
    for (new id = 1; id <= maxp; id++) {
        if (!is_user_connected(id)) continue;
        new is_alive = is_user_alive(id);
        new is_bot = is_user_bot(id);
        new team = get_user_team(id); // 1=T, 2=CT in vanilla
        new Float:origin[3]; pev(id, pev_origin, origin);
        if (!first) len += formatex(buffer[len], charsmax(buffer)-len, ",");
        first = 0;
        len += formatex(buffer[len], charsmax(buffer)-len,
            "{\"id\":%d,\"t\":%d,\"b\":%d,\"a\":%d,\"x\":%d,\"y\":%d,\"z\":%d}",
            id, team, is_bot, is_alive, floatround(origin[0]), floatround(origin[1]), floatround(origin[2]));
    }
    len += formatex(buffer[len], charsmax(buffer)-len, "]}" );

    socket_send(g_sock, buffer, len);

    if (g_log) server_print("[ai_bridge] sent snapshot (%d bytes)", len);
}

public tick_recv_cmds() {
    if (!g_enabled || !g_sock) return;

    new recvbuf[1200], fromip[32], fromport;
    new r = socket_recvfrom(g_sock, recvbuf, charsmax(recvbuf), fromip, fromport);
    if (r <= 0) return;

    // Expect a JSON of shape: {"cmds":[{"id":12,"goal_wp":134,"agg":0.9,"mode":"flank"}, ...]}
    // Minimal parse: find occurrences of "id": and "goal_wp":
    new i = 0;
    while ((i = containi(recvbuf[i], "\"id\":")) != -1) {
        i += 5; // move after "id":
        new bid = str_to_num(recvbuf[i]);  // crude; relies on well-formed JSON

        new j = containi(recvbuf[i], "\"goal_wp\":");
        if (j == -1) break;
        j += 10;
        new goal = str_to_num(recvbuf[j]);

        // TODO: if your YaPB exposes natives, call them here (preferred).
        // Fallback: issue a console command to steer a specific bot (version-dependent).
        // Example placeholder (replace with real YaPB command on your build):
        // server_cmd("yb aim 1"); // demo: turn some yb behavior on
        // server_cmd("yb_forcegoal %d %d", bid, goal); // imaginary; replace with actual

        if (g_log) server_print("[ai_bridge] cmd -> bot %d to wp %d", bid, goal);
    }
}
```

**Compile it**:  
- Use AMXX’s local compiler (`\cs_zombie_ai\hlds\cstrike\addons\amxmodx\scripting\compile.exe`)  
- Drop `ai_bridge.amxx` into `…\addons\amxmodx\plugins\` and ensure it’s listed in `plugins.ini`.

> **Note:** The minimal command application above is intentionally generic because YaPB control APIs differ across builds. Prefer official natives; if not available, use supported `yb ...` console commands documented with your YaPB version.

---

## 6) Python sidecar (real-time decision service)

### 6.1 Requirements

`\cs_zombie_ai\python_sidecar\requirements.txt`
```
xgboost
numpy
pandas
pyyaml
```

Install (inside Claude Code terminal):
```powershell
cd \cs_zombie_ai\python_sidecar
py -3 -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
```

### 6.2 Real-time server

`\cs_zombie_ai\python_sidecar\ai_server.py`
```python
import json, socket, time
import numpy as np
from xgboost import XGBClassifier

SIDE_HOST = "127.0.0.1"
SIDE_PORT = 31337
MODEL_PATH = "models/xgb_zombie.json"

model = XGBClassifier()
try:
    model.load_model(MODEL_PATH)
except Exception:
    # Cold start: if no model yet, make a dummy that outputs 0.5
    class Dummy:
        def predict_proba(self, X):
            return np.tile([0.5, 0.5], (X.shape[0], 1))
    model = Dummy()

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((SIDE_HOST, SIDE_PORT))
sock.setblocking(False)

def featurize(snapshot):
    pl = snapshot.get("pl", [])
    bots, feats = [], []
    for p in pl:
        # Consider alive bots as "zombies" for now; adapt if your mod uses flags
        if not (p.get("b") == 1 and p.get("a") == 1):
            continue

        # Feature examples: mean dist to alive humans, count within 600u, self hp (if sent)
        dists, near_h = [], 0
        for q in pl:
            if q.get("b") == 0 and q.get("a") == 1:  # human
                dx, dy = p["x"] - q["x"], p["y"] - q["y"]
                d = (dx*dx + dy*dy) ** 0.5
                dists.append(d)
                if d < 600: near_h += 1
        mean_dist = float(np.mean(dists)) if dists else 2000.0
        hp = float(p.get("hp", 100))
        feats.append([mean_dist, near_h, hp])
        bots.append(p["id"])
    X = np.array(feats, dtype=np.float32) if feats else np.zeros((0,3), dtype=np.float32)
    return bots, X

def decide(snapshot):
    bot_ids, X = featurize(snapshot)
    cmds = []
    if len(bot_ids) == 0: return {"cmds": cmds}
    proba = model.predict_proba(X)[:,1] if X.shape[0] else np.array([])
    for i, bid in enumerate(bot_ids):
        p_attack = float(proba[i]) if proba.size else 0.5
        goal_wp = 134 if p_attack > 0.6 else 78   # example: pick routes based on score
        mode = "flank" if p_attack > 0.7 else "pressure"
        agg = max(0.4, min(1.0, p_attack + 0.3))
        cmds.append({"id": bid, "goal_wp": goal_wp, "agg": agg, "mode": mode})
    return {"cmds": cmds}

print(f"[sidecar] listening on udp://{SIDE_HOST}:{SIDE_PORT}")
BUF = 2048

while True:
    try:
        data, addr = sock.recvfrom(BUF)
    except BlockingIOError:
        time.sleep(0.01); continue
    try:
        snapshot = json.loads(data.decode("utf-8"))
        out = decide(snapshot)
        sock.sendto(json.dumps(out).encode("utf-8"), addr)
    except Exception as e:
        # In production, add proper logging
        pass
```

Run it:
```powershell
cd \cs_zombie_ai\python_sidecar
.\.venv\Scripts\activate
py ai_server.py
```
> Keep this window open while the server is running.

---

## 7) Training with XGBoost (offline)

You’ll first **log gameplay** (add CSV logging in your AMXX plugin or generate labels heuristically), then build a **tabular dataset** and train.

### 7.1 Dataset builder

`\cs_zombie_ai\python_sidecar\train\make_dataset.py`
```python
import pandas as pd

# Assume you've exported round logs into logs/round_events.csv
# Each row could include:
# mean_dist_h, humans_within_600, z_alive, h_alive, phase_code, map_cp_density, y_attack_now
df = pd.read_csv("logs/round_events.csv")

# Example feature engineering
df["ratio_z_h"] = df["z_alive"] / df["h_alive"].clip(lower=1)

features = [
    "mean_dist_h",
    "humans_within_600",
    "ratio_z_h",
    "phase_code",
    "map_cp_density"
]
target = "y_attack_now"

df[features + [target]].to_csv("dataset.csv", index=False)
print("dataset.csv written")
```

### 7.2 Trainer

`\cs_zombie_ai\python_sidecar\train\train_xgb.py`
```python
import pandas as pd
from xgboost import XGBClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score

df = pd.read_csv("dataset.csv")
X = df.drop(columns=["y_attack_now"])
y = df["y_attack_now"]

Xtr, Xva, ytr, yva = train_test_split(X, y, test_size=0.2, stratify=y, random_state=7)

clf = XGBClassifier(
    n_estimators=300,
    max_depth=5,
    learning_rate=0.08,
    subsample=0.9,
    colsample_bytree=0.9,
    reg_lambda=1.0,
    tree_method="hist",
    eval_metric="logloss"
)
clf.fit(Xtr, ytr)
print("AUC:", roc_auc_score(yva, clf.predict_proba(Xva)[:,1]))

clf.save_model("../models/xgb_zombie.json")
print("Saved ../models/xgb_zombie.json")
```

Run the training:
```powershell
cd \cs_zombie_ai\python_sidecar
.\.venv\Scripts\activate
cd train
py make_dataset.py
py train_xgb.py
```

Restart `ai_server.py` to load the new model.

---

## 8) Waypoints & routes (YaPB)

- Install **waypoint packs** (`.pwf`) for your maps under `\cs_zombie_ai\waypoints\`.
- Ensure YaPB is actually using them (follow your YaPB build’s docs).
- For tactics, predefine **route IDs** or **waypoint clusters** (e.g., `WP_FLANK_A`, `WP_PRESSURE_MID`) and map them to numeric `goal_wp` IDs. Keep the mapping in your sidecar or a small config file.

---

## 9) Launch order & validation

1) **Start Python** sidecar:
```powershell
cd \cs_zombie_ai\python_sidecar
.\.venv\Scripts\activate
py ai_server.py
```

2) **Start CS server**:
```powershell
\cs_zombie_ai\scripts\start_server.bat
```

3) In the sidecar console you should see:
```
[sidecar] listening on udp://127.0.0.1:31337
```

4) In HLDS console (or `logs`), you should see periodic “[ai_bridge] sent snapshot …”.  
5) Join the server, add YaPB bots, start a Zombie round. Zombies should begin receiving simple orders (based on dummy `goal_wp` logic).  
6) Iterate: tweak tick rate, verify packets are under ~1200 bytes, refine features.

---

## 10) Managing with Claude Code Opus 4.1 (suggested workflow)

- **Workspace**: open `\cs_zombie_ai\` as a project.  
- **Terminals**:
  - Terminal A: `python_sidecar` venv active, run `ai_server.py`.
  - Terminal B: run `scripts\start_server.bat`.  
- **Tasks**:
  - Create tasks for “Start Sidecar” and “Start Server” for 1-click runs.
- **Editing**:
  - Modify `ai_bridge.sma` and re-compile via AMXX compiler in `…\scripting\`.
  - Keep a `CHANGELOG.md` for tweaks to features, routes, and model versions.

---

## 11) Performance & safety

- **Tick**: `aibridge_tick_ms = 150–250` is usually fine.  
- **UDP**: keep messages `< 1200 bytes` to avoid fragmentation.  
- **Local only**: bind sidecar to `127.0.0.1`. If you ever expose it, add firewall rules and message authentication (e.g., HMAC).  
- **Fallbacks**: if sidecar times out, the plugin stops applying orders and bots revert to native behavior.

---

## 12) Troubleshooting

- **No bots move to goals**: your YaPB build may not support the placeholder command; switch to official YaPB **natives** or the documented `yb` console commands for your version.  
- **AMXX “sockets” missing**: enable in `modules.ini`. Ensure `sockets` DLL is present in `addons\amxmodx\modules\`.  
- **No snapshots**: check `aibridge_enabled 1` and that the socket opened (log lines).  
- **Python can’t load model**: that’s fine on first run—Dummy model is used. Train and drop `xgb_zombie.json`.  
- **High CPU**: reduce tick rate, features, and player set considered; avoid sending HP/extra fields every tick unless needed.

---

## 13) Next steps (making it *really* smart)

- Define **map-specific route sets** (flank/pressure/ambush) and map them to **waypoint IDs**.  
- Expand features: local Z/H ratio, “chokepoint score”, recent gunfire heatmaps, time remaining.  
- Replace the crude JSON parse with a solid AMXX JSON include or a tiny custom protocol (CSV/MsgPack-like).  
- Log decisions and outcomes → iterate XGBoost with **supervised labels** (e.g., “push led to infection within 8s”).  
- Add **classes** (tanker/leaper/acid) with different orders per class.

---

## 14) Quick checklist (copy/paste)

- [ ] HLDS/ReHLDS installed under `hlds\` with `cstrike\`.  
- [ ] Metamod-R wired via `liblist.gam`.  
- [ ] AMX Mod X installed; `admin.amxx` loads.  
- [ ] Zombie mod `.amxx` enabled; assets in place.  
- [ ] YaPB installed; bots join and move via waypoints.  
- [ ] `ai_bridge.amxx` compiled and loaded; `sockets` module enabled.  
- [ ] `ai_server.py` running (venv active), prints “listening”.  
- [ ] Snapshots visible in HLDS logs, commands in sidecar logs.  
- [ ] Training scripts produce `models\xgb_zombie.json`.  
- [ ] Sidecar reloads model and issues smarter commands.

## Links

- SteamCMD: https://developer.valvesoftware.com/wiki/SteamCMD
- ReHLDS: https://github.com/rehlds/ReHLDS
- ReGameDDL_CS: https://github.com/rehlds/ReGameDLL_CS
- Metamod-R (releases): https://github.com/rehlds/Metamod-R/releases
- AMX Mod: https://www.amxmodx.org/doc/index.html?page=source%2Finstallation%2Fmanual.htm&utm_source=chatgpt.com
- Zombie Plague: https://forums.alliedmods.net/showthread.php?t=327327&utm_source=chatgpt.com
- Yapb: https://github.com/yapb/yapb?utm_source=chatgpt.com
