#!/usr/bin/env python3
"""
CropGuard AI - Satellite / Land-Surface Data Fusion
===================================================
Innovation #3: Satellite Data Fusion

Fetches volumetric soil-moisture profiles from Open-Meteo's land-surface
model (ERA5 reanalysis - derived from Copernicus/Sentinel satellite
observations) and converts them into a 0-100 soil-moisture risk index that
is fused into the post-harvest risk score as a fourth component.

Why soil moisture?
------------------
Wet soils at harvest time mean wet crops at storage time - the primary
precursor to rot and aflatoxin contamination. Forecast rainfall alone can
miss slow-drying waterlogged fields, so the satellite/land-surface layer
catches risk that weather-only models under-estimate.

Usage:
    from satellite_fusion import fetch_soil_moisture, calculate_soil_moisture_index

Dependencies:
    pip install requests
"""

import sys

import requests

# Open-Meteo API (no API key needed) - land-surface / soil variables
OPENMETEO_URL = "https://api.open-meteo.com/v1/forecast"

# Hourly soil-moisture layers (volumetric water content, m³/m³)
# Layer 1: seed/graft zone (0-1cm)   Layer 2: root/storage zone (3-9cm)
SOIL_HOURLY_VARS = [
    "soil_moisture_0_to_1cm",
    "soil_moisture_3_to_9cm",
]


def fetch_soil_moisture(lat: float, lng: float) -> dict | None:
    """
    Fetch 14-day hourly soil-moisture forecasts for a coordinate point.

    Returns the raw Open-Meteo "hourly" block, or None on failure.
    """
    params = {
        "latitude": lat,
        "longitude": lng,
        "hourly": SOIL_HOURLY_VARS,
        "timezone": "Africa/Kigali",
        "forecast_days": 14,
    }

    try:
        response = requests.get(OPENMETEO_URL, params=params, timeout=30)
        response.raise_for_status()
        data = response.json()
        return data.get("hourly")
    except requests.RequestException as e:
        print(
            f"  WARNING: Failed to fetch soil moisture for ({lat}, {lng}): {e}",
            file=sys.stderr,
        )
        return None


def calculate_soil_moisture_index(soil_hourly: dict | None) -> tuple[float, float]:
    """
    Convert hourly soil-moisture layers into (index 0-100, mean m3/m3).

    Volumetric soil-moisture thresholds (m3/m3), calibrated for Rwandan
    volcanic/ferralsol soils:
        >= 0.40  saturated fields            -> 100 (very high risk)
        >= 0.35  near field capacity         -> 85
        >= 0.30  wet                        -> 70
        >= 0.25  moderately wet              -> 55
        >= 0.20  moist                       -> 40
        >= 0.15  drying                      -> 25
        <  0.15  dry                         -> 10
    """
    if not soil_hourly:
        return 0.0, 0.0

    layers = [
        soil_hourly.get(var, []) for var in SOIL_HOURLY_VARS
    ]
    # Average the two layers per timestamp (skipping nulls), then average
    # over time - Open-Meteo returns null for hours without data
    aligned = zip(*layers)
    timestamps = [ts for ts in aligned if all(v is not None for v in ts)]
    if not timestamps:
        return 0.0, 0.0

    daily_means = [sum(ts) / len(ts) for ts in timestamps]
    mean_soil = sum(daily_means) / len(daily_means)

    if mean_soil >= 0.40:
        index = 100.0
    elif mean_soil >= 0.35:
        index = 85.0
    elif mean_soil >= 0.30:
        index = 70.0
    elif mean_soil >= 0.25:
        index = 55.0
    elif mean_soil >= 0.20:
        index = 40.0
    elif mean_soil >= 0.15:
        index = 25.0
    else:
        index = 10.0

    return index, round(mean_soil, 4)


def estimate_soil_moisture_index(rainfall_index: float) -> tuple[float, float]:
    """
    Fallback when the soil-moisture API is unavailable:
    derive an estimate from the rainfall index so the fusion layer
    never breaks the pipeline.
    """
    index = max(10.0, min(100.0, rainfall_index * 0.9 + 10.0))
    return index, 0.0


def fuse_risk_score(
    rainfall_index: float,
    humidity_index: float,
    loss_rate: float,
    soil_moisture_index: float,
    weights: dict[str, float],
) -> dict[str, float]:
    """
    Fused post-harvest risk score (0-100):

        Risk = Rainfall × w_rain + Humidity × w_hum
             + Loss Rate × w_loss + Soil Moisture × w_soil

    weights must contain: rainfall, humidity, loss_rate, soil_moisture
    """
    risk = (
        rainfall_index * weights["rainfall"]
        + humidity_index * weights["humidity"]
        + loss_rate * weights["loss_rate"]
        + soil_moisture_index * weights["soil_moisture"]
    )
    risk = max(0.0, min(100.0, risk))

    if risk <= 39:
        level = "green"
    elif risk <= 69:
        level = "yellow"
    else:
        level = "red"

    return {
        "risk_score": round(risk, 1),
        "level": level,
        "rainfall_index": round(rainfall_index, 1),
        "humidity_index": round(humidity_index, 1),
        "loss_rate_index": round(loss_rate, 1),
        "soil_moisture_index": round(soil_moisture_index, 1),
    }
