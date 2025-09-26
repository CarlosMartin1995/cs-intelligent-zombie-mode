import json
import socket
import time
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