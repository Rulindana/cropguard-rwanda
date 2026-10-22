#!/usr/bin/env python3
"""
CropGuard AI — Main Entry Point
=================================
Predictive post-harvest loss intelligence for Rwanda's 30 districts.
Built on 12 years of NISR Seasonal Agricultural Survey (SAS) data,
fused with live satellite and weather feeds.

Live web app : https://nisr-b06b6.web.app
GitHub repo  : https://github.com/Rulindana/cropguard-rwanda

Usage:
    python app.py                  # Run full risk prediction pipeline
    python app.py --report         # Generate policy brief report
    python app.py --alerts         # Dispatch SMS/USSD alerts
    python app.py --summary        # Print district risk summary to console
"""

import argparse
import json
import os
import sys
from datetime import datetime

# ─── Paths ────────────────────────────────────────────────────────────────────
BASE_DIR   = os.path.dirname(os.path.abspath(__file__))
DATA_DIR   = os.path.join(BASE_DIR, "data")
SYNC_DIR   = os.path.join(BASE_DIR, "sync_pipeline")

sys.path.insert(0, SYNC_DIR)


def run_pipeline():
    """Fetch live weather data and recalculate risk scores for all 30 districts."""
    print("[CropGuard AI] Starting risk prediction pipeline...")
    try:
        from sync_nisr_data import main as sync_main
        sync_main()
    except ImportError:
        print("[ERROR] sync_pipeline/sync_nisr_data.py not found.")
        sys.exit(1)


def generate_report():
    """Generate a markdown policy brief from current risk scores."""
    print("[CropGuard AI] Generating policy brief...")
    script = os.path.join(BASE_DIR, "scripts", "generate_policy_brief.py")
    if os.path.exists(script):
        os.system(f"python3 {script}")
    else:
        print("[ERROR] scripts/generate_policy_brief.py not found.")


def dispatch_alerts():
    """Send SMS/USSD alerts for high-risk districts."""
    print("[CropGuard AI] Dispatching alerts...")
    try:
        from sms_alerts import dispatch_alerts as send
        send()
    except ImportError:
        print("[ERROR] sync_pipeline/sms_alerts.py not found.")
        sys.exit(1)


def print_summary():
    """Print a quick risk summary for all districts to the console."""
    risk_file = os.path.join(DATA_DIR, "risk_scores.json")
    if not os.path.exists(risk_file):
        print("[ERROR] data/risk_scores.json not found. Run pipeline first.")
        sys.exit(1)

    with open(risk_file) as f:
        data = json.load(f)

    districts = data.get("districts", data) if isinstance(data, dict) else data
    if isinstance(districts, dict):
        districts = list(districts.values())

    print(f"\n{'District':<20} {'Province':<12} {'Risk Score':>10} {'Level':<10}")
    print("─" * 56)

    for d in sorted(districts, key=lambda x: x.get("risk_score", 0), reverse=True):
        name     = d.get("name", d.get("district", "Unknown"))
        province = d.get("province", "—")
        score    = d.get("risk_score", d.get("composite_risk", 0))
        level    = d.get("risk_level", "HIGH" if score > 65 else "MEDIUM" if score > 40 else "LOW")
        print(f"{name:<20} {province:<12} {score:>10.1f} {level:<10}")

    print(f"\nGenerated: {datetime.now().strftime('%Y-%m-%d %H:%M')} | Source: NISR SAS + Open-Meteo\n")


def main():
    parser = argparse.ArgumentParser(
        description="CropGuard AI — Rwanda post-harvest loss prediction system"
    )
    parser.add_argument("--report",  action="store_true", help="Generate policy brief report")
    parser.add_argument("--alerts",  action="store_true", help="Dispatch SMS/USSD alerts")
    parser.add_argument("--summary", action="store_true", help="Print district risk summary")
    args = parser.parse_args()

    if args.report:
        generate_report()
    elif args.alerts:
        dispatch_alerts()
    elif args.summary:
        print_summary()
    else:
        run_pipeline()


if __name__ == "__main__":
    main()
