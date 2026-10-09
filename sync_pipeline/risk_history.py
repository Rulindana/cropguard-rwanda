#!/usr/bin/env python3
"""
CropGuard AI - Risk History & Trend Detection
=============================================
Criterion 3 (Tech Innovation): predictive trend layer — "risk momentum".

Appends every pipeline run's district scores to a rolling history file
(data/risk_history.json) and attaches a trend indicator to each district:

    delta   = current_score − previous_run_score
    trend   = rising   (delta >= +2)
            | falling  (delta <= −2)
            | stable   (|delta| < 2)
            | baseline (no previous run yet)

The Flutter app renders this as a momentum chip (e.g. "▲ +6.2 since
last run") so planners see risk *direction*, not just today's number.
"""

import json
import os
from datetime import datetime, timezone
from typing import Any

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
HISTORY_FILE = os.path.join(DATA_DIR, "risk_history.json")

# Rolling window per district (runs) — at 6-hourly runs, 60 ≈ 15 days
MAX_HISTORY_POINTS = 60

# Delta thresholds for rising / falling classification
RISE_THRESHOLD = 2.0
FALL_THRESHOLD = -2.0


def load_history() -> dict[str, list[dict[str, Any]]]:
    if not os.path.exists(HISTORY_FILE):
        return {}
    try:
        with open(HISTORY_FILE, "r") as f:
            return json.load(f)
    except (json.JSONDecodeError, OSError):
        return {}


def save_history(history: dict[str, list[dict[str, Any]]]) -> None:
    with open(HISTORY_FILE, "w") as f:
        json.dump(history, f, indent=2)


def classify_trend(delta: float) -> str:
    if delta >= RISE_THRESHOLD:
        return "rising"
    if delta <= FALL_THRESHOLD:
        return "falling"
    return "stable"


def record_and_attach_trends(
    risk_results: list[dict[str, Any]],
) -> dict[str, Any]:
    """
    Append this run to history, attach `risk_trend` to every district,
    and return a national trend summary.
    """
    history = load_history()
    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")

    rising = falling = stable = baseline = 0

    for district in risk_results:
        did = district["district_id"]
        score = district["risk"]["risk_score"]
        level = district["risk"]["level"]

        points = history.get(did, [])
        previous = points[-1] if points else None

        if previous is None:
            delta = 0.0
            trend = "baseline"
            baseline += 1
        else:
            delta = round(score - previous["score"], 1)
            trend = classify_trend(delta)
            if trend == "rising":
                rising += 1
            elif trend == "falling":
                falling += 1
            else:
                stable += 1

        points.append({"ts": now, "score": score, "level": level})
        history[did] = points[-MAX_HISTORY_POINTS:]

        district["risk_trend"] = {
            "trend": trend,
            "delta": delta,
            "previous_score": previous["score"] if previous else None,
            "previous_at": previous["ts"] if previous else None,
            "history_points": len(history[did]),
        }

    save_history(history)

    summary = {
        "rising": rising,
        "falling": falling,
        "stable": stable,
        "baseline": baseline,
        "history_file": os.path.basename(HISTORY_FILE),
    }

    # National momentum: average delta across districts with history
    deltas = [
        d["risk_trend"]["delta"]
        for d in risk_results
        if d["risk_trend"]["trend"] != "baseline"
    ]
    summary["avg_delta"] = round(sum(deltas) / len(deltas), 1) if deltas else 0.0

    return summary
