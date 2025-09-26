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