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