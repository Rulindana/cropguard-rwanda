#!/usr/bin/env python3
"""
CropGuard AI - Automated Data Sync Pipeline
================================================
Fetches live weather data from Open-Meteo API and combines it with 
NISR SAS baseline data to calculate post-harvest risk scores for all 
30 Rwanda districts.

Pipeline steps:
1. Load NISR SAS district baseline data from JSON
2. Fetch 14-day weather forecast from Open-Meteo for each district centroid
3. Calculate rainfall index, humidity index, and combined risk score
4. Output risk scores to console / can push to Firestore

Usage:
    python sync_pipeline/sync_nisr_data.py

Dependencies:
    pip install requests pandas
"""

import json
import math
import os
import sys
from datetime import datetime, timedelta, timezone
from typing import Any

import requests

# ─────────────────────────────────────────────────────────────
# Configuration
# ─────────────────────────────────────────────────────────────

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
NISR_FILE = os.path.join(DATA_DIR, "nisr_sas_districts.json")
OUTPUT_FILE = os.path.join(DATA_DIR, "risk_scores.json")

# Open-Meteo API (no API key needed)
OPENMETEO_URL = "https://api.open-meteo.com/v1/forecast"

# Risk score weights (from the spec)
RAINFALL_WEIGHT = 0.40
HUMIDITY_WEIGHT = 0.30
LOSS_RATE_WEIGHT = 0.30

# Classification thresholds
GREEN_THRESHOLD = 39   # 0-39: low risk
YELLOW_THRESHOLD = 69  # 40-69: moderate risk
RED_THRESHOLD = 100    # 70-100: high risk


# ─────────────────────────────────────────────────────────────
# Data Loading
# ─────────────────────────────────────────────────────────────

def load_nisr_data() -> dict[str, Any]:
    """Load NISR SAS district baseline data from JSON file."""
    if not os.path.exists(NISR_FILE):
        raise FileNotFoundError(f"NISR data file not found: {NISR_FILE}")

    with open(NISR_FILE, "r") as f:
        return json.load(f)


def get_district_centroids(nisr_data: dict[str, Any]) -> list[dict[str, float]]:
    """Extract district centroids for weather API queries."""
    districts = nisr_data.get("districts", [])
    centroids = []
    for d in districts:
        centroids.append({
            "id": d["id"],
            "name": d["name"],
            "lat": d["centroid_lat"],
            "lng": d["centroid_lng"],
            "province": d["province"],
            "nirs": d.get("nirs_baseline", {}),
        })
    return centroids


# ─────────────────────────────────────────────────────────────
# Weather Fetching (Open-Meteo)
# ─────────────────────────────────────────────────────────────

def fetch_weather_for_district(lat: float, lng: float) -> dict[str, Any] | None:
    """
    Fetch 14-day forecast for a single coordinate point from Open-Meteo.
    
    Returns daily aggregates for:
    - precipitation_sum (mm)
    - relative_humidity_2m_max (%)
    - temperature_2m_max (°C)
    """
    params = {
        "latitude": lat,
        "longitude": lng,
        "daily": [
            "precipitation_sum",
            "relative_humidity_2m_max",
            "temperature_2m_max",
        ],
        "timezone": "Africa/Kigali",
        "forecast_days": 14,
    }

    try:
        response = requests.get(OPENMETEO_URL, params=params, timeout=30)
        response.raise_for_status()
        data = response.json()
        return data.get("daily", {})
    except requests.RequestException as e:
        print(f"  WARNING: Failed to fetch weather for ({lat}, {lng}): {e}", file=sys.stderr)
        return None


def calculate_rainfall_index(precipitation_values: list[float]) -> float:
    """
    Calculate rainfall risk index (0-100) from 14-day precipitation totals.
    
    Thresholds (mm over 14 days):
    - 0-20mm: index 0-20 (low)
    - 20-60mm: index 20-60 (moderate)
    - 60-100mm+: index 60-100 (high)
    """
    if not precipitation_values:
        return 0.0

    total_rain = sum(precipitation_values)
    max_rain = max(precipitation_values) if precipitation_values else 0

    # Convert total rain to index (0-100)
    # 80mm+ over 14 days = very high risk
    if total_rain >= 80:
        return 100.0
    elif total_rain >= 50:
        return 75.0
    elif total_rain >= 30:
        return 55.0
    elif total_rain >= 15:
        return 35.0
    elif total_rain >= 5:
        return 20.0
    else:
        return 10.0


def calculate_humidity_index(humidity_values: list[float]) -> float:
    """
    Calculate humidity risk index (0-100) from max daily relative humidity.
    
    Critical threshold: >75% RH triggers fungal rot risk.
    - <60%: low risk
    - 60-75%: moderate
    - 75-85%: high
    - >85%: very high
    """
    if not humidity_values:
        return 0.0

    max_humidity = max(humidity_values)
    avg_humidity = sum(humidity_values) / len(humidity_values)

    # Use max humidity as primary driver
    if max_humidity >= 90:
        return 100.0
    elif max_humidity >= 80:
        return 80.0
    elif max_humidity >= 75:
        return 65.0
    elif max_humidity >= 65:
        return 45.0
    elif max_humidity >= 55:
        return 25.0
    else:
        return 10.0


def calculate_risk_score(
    rainfall_index: float,
    humidity_index: float,
    loss_rate: float,
) -> dict[str, float]:
    """
    Calculate post-harvest risk score using the weighted formula:
    
    Risk = (Rainfall × 0.40) + (Humidity × 0.30) + (Loss Rate × 0.30)
    
    All inputs are 0-100 scale.
    """
    risk = (rainfall_index * RAINFALL_WEIGHT) + \
           (humidity_index * HUMIDITY_WEIGHT) + \
           (loss_rate * LOSS_RATE_WEIGHT)

    risk = max(0.0, min(100.0, risk))  # clamp to 0-100

    # Classification
    if risk <= GREEN_THRESHOLD:
        level = "green"
    elif risk <= YELLOW_THRESHOLD:
        level = "yellow"
    else:
        level = "red"

    return {
        "risk_score": round(risk, 1),
        "level": level,
        "rainfall_index": round(rainfall_index, 1),
        "humidity_index": round(humidity_index, 1),
        "loss_rate_index": round(loss_rate, 1),
    }


def classify_risk(risk_score: float) -> str:
    """Return human-readable risk classification."""
    if risk_score <= GREEN_THRESHOLD:
        return "Low Risk - Safe harvesting conditions"
    elif risk_score <= YELLOW_THRESHOLD:
        return "Moderate Risk - Humidity high; drying equipment recommended within 48h"
    else:
        return "HIGH RISK - Heavy rainfall + peak harvest; emergency storage dispatch needed"


# ─────────────────────────────────────────────────────────────
# Main Pipeline
# ─────────────────────────────────────────────────────────────

def run_pipeline():
    """Execute the full data sync pipeline."""
    print("=" * 60)
    print("  CropGuard AI - Automated Data Sync Pipeline")
    print("=" * 60)
    print()

    # Step 1: Load NISR data
    print("[1/3] Loading NISR SAS district data...")
    nisr_data = load_nisr_data()
    centroids = get_district_centroids(nisr_data)
    print(f"      Loaded {len(centroids)} districts from {NISR_FILE}")
    print()

    # Step 2: Fetch weather for each district
    print("[2/3] Fetching 14-day weather forecasts from Open-Meteo...")
    print("      (This may take a moment - fetching for all 30 districts)")
    print()

    risk_results = []
    districts_with_weather = 0
    total_rainfall = 0.0
    total_humidity = 0.0

    for i, district in enumerate(centroids, 1):
        print(f"  [{i:02d}/30] {district['name']} ({district['province']})... ", end="")

        weather_data = fetch_weather_for_district(
            district["lat"],
            district["lng"]
        )

        if weather_data is None:
            # Use mock/estimated values if API fails
            precipitation = [2.0] * 14  # light rain estimate
            humidity = [55.0] * 14
            print("using estimates (API unavailable)")
        else:
            precipitation = weather_data.get("precipitation_sum", [])
            humidity = weather_data.get("relative_humidity_2m_max", [])
            if precipitation and humidity:
                print(
                    f"rain: {sum(precipitation):.1f}mm, "
                    f"max humidity: {max(humidity):.1f}%"
                )
                districts_with_weather += 1
            else:
                precipitation = [2.0] * 14
                humidity = [55.0] * 14
                print("using estimates (no data in response)")

        # Step 3: Calculate indices and risk score
        rainfall_index = calculate_rainfall_index(precipitation)
        humidity_index = calculate_humidity_index(humidity)

        loss_rate = district["nirs"].get("historical_loss_rate_pct", 25.0)

        risk = calculate_risk_score(rainfall_index, humidity_index, loss_rate)

        total_rainfall += rainfall_index
        total_humidity += humidity_index

        result = {
            "district_id": district["id"],
            "district_name": district["name"],
            "province": district["province"],
            "centroid_lat": district["lat"],
            "centroid_lng": district["lng"],
            "nirs_baseline": district["nirs"],
            "weather": {
                "total_precipitation_14d_mm": round(sum(precipitation), 1),
                "max_humidity_pct": round(max(humidity), 1) if humidity else 0.0,
                "avg_humidity_pct": round(sum(humidity) / len(humidity), 1) if humidity else 0.0,
                "max_temp_c": 30.0,  # Open-Meteo provides this; simplified here
            },
            "risk": risk,
            "advisory": classify_risk(risk["risk_score"]),
            "updated_at": datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z'),
        }
        risk_results.append(result)

    print()
    print(f"      Successfully fetched weather for {districts_with_weather}/{len(centroids)} districts")
    print()

    # Summary
    print("[3/3] Risk Score Summary:")
    print("-" * 60)

    green_count = sum(1 for r in risk_results if r["risk"]["level"] == "green")
    yellow_count = sum(1 for r in risk_results if r["risk"]["level"] == "yellow")
    red_count = sum(1 for r in risk_results if r["risk"]["level"] == "red")

    # Sort by risk score descending for highlight
    sorted_results = sorted(risk_results, key=lambda x: x["risk"]["risk_score"], reverse=True)

    print(f"  GREEN  (0-39):  {green_count:2d} districts - Safe")
    print(f"  YELLOW (40-69): {yellow_count:2d} districts - Caution")
    print(f"  RED    (70-100): {red_count:2d} districts - HIGH ALERT")
    print()
    print("  Top 5 Highest Risk Districts:")
    for r in sorted_results[:5]:
        print(f"    [{r['risk']['level'].upper()}] {r['district_name']:<15} "
              f"Score: {r['risk']['risk_score']:5.1f}  "
              f"Rain: {r['risk']['rainfall_index']:5.1f}  "
              f"Humidity: {r['risk']['humidity_index']:5.1f}  "
              f"Loss Rate: {r['risk']['loss_rate_index']:5.1f}")
    print()

    # Save results to JSON
    output_data = {
        "metadata": {
            "pipeline": "CropGuard AI Sync Pipeline",
            "generated_at": datetime.now(timezone.utc).isoformat().replace('+00:00', 'Z'),
            "weather_source": "Open-Meteo API (no key required)",
            "nisr_source": "NISR SAS District Baseline (mock data)",
            "risk_formula": f"Risk = (Rainfall × {RAINFALL_WEIGHT}) + (Humidity × {HUMIDITY_WEIGHT}) + (Loss Rate × {LOSS_RATE_WEIGHT})",
        },
        "summary": {
            "total_districts": len(risk_results),
            "green_count": green_count,
            "yellow_count": yellow_count,
            "red_count": red_count,
            "avg_risk_score": round(sum(r["risk"]["risk_score"] for r in risk_results) / len(risk_results), 1),
        },
        "districts": risk_results,
    }

    with open(OUTPUT_FILE, "w") as f:
        json.dump(output_data, f, indent=2)

    print(f"  Results saved to: {OUTPUT_FILE}")
    print()
    print("=" * 60)
    print("  Pipeline complete. Ready for Firebase/Firestore sync.")
    print("=" * 60)

    return output_data


def sync_to_firestore(risk_data: dict[str, Any]) -> bool:
    """
    Push risk scores to Firebase Firestore.
    
    Requires: firebase-admin SDK initialized with service account.
    This function is a stub — implement with your Firebase credentials.
    
    The Flutter app reads from these Firestore collections:
    - /districts/{districtId} - district data + risk score
    - /facilities - facility catalog
    """
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore
    except ImportError:
        print("  firebase-admin not installed. Install with: pip install firebase-admin")
        print("  Or run this pipeline via Firebase Cloud Functions.")
        return False

    # Check if already initialized
    if not firebase_admin._apps:
        cred_path = os.path.join(os.path.dirname(__file__), "..", "firebase_service_account.json")
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
        else:
            print(f"  Firebase service account file not found: {cred_path}")
            return False

    db = firestore.client()

    # Write district risk scores
    for district in risk_data["districts"]:
        doc_ref = db.collection("districts").document(district["district_id"])
        doc_ref.set({
            "name": district["district_name"],
            "province": district["province"],
            "centroid_lat": district["centroid_lat"],
            "centroid_lng": district["centroid_lng"],
            "nirs_baseline": district["nirs_baseline"],
            "risk_score": district["risk"]["risk_score"],
            "risk_level": district["risk"]["level"],
            "rainfall_index": district["risk"]["rainfall_index"],
            "humidity_index": district["risk"]["humidity_index"],
            "loss_rate_index": district["risk"]["loss_rate_index"],
            "total_precipitation_14d_mm": district["weather"]["total_precipitation_14d_mm"],
            "max_humidity_pct": district["weather"]["max_humidity_pct"],
            "advisory": district["advisory"],
            "updated_at": district["updated_at"],
        }, merge=True)

    # Write summary
    summary_ref = db.collection("metadata").document("risk_summary")
    summary_ref.set({
        "summary": risk_data["summary"],
        "updated_at": risk_data["metadata"]["generated_at"],
    }, merge=True)

    print("  Successfully synced to Firestore!")
    return True


if __name__ == "__main__":
    data = run_pipeline()

    # Optional: sync to Firestore if credentials available
    # sync_to_firestore(data)
