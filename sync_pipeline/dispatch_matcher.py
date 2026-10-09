#!/usr/bin/env python3
"""
CropGuard AI - Facility Dispatch Matching
=========================================
Innovation #2: Facility Dispatch Matching ("last mile" impact)

Turns a risk score into action: for every district, rank the nearest
post-harvest facilities (drying grounds, silos, cold storage, mobile
dryers) by travel distance and remaining capacity, so red-alert districts
get an explicit "dispatch these crops here, now" recommendation.

Matching logic:
1. Filter facilities with available capacity > 0
2. Compute haversine distance from district centroid to each facility
3. Estimate rural travel time (~35 km/h + 10 min handling)
4. Rank by a composite score: closer + more capacity = better match
5. Tag priority: emergency (red) / recommended (yellow) / available (green)

Usage:
    from dispatch_matcher import rank_facilities_for_district
"""

import math
from typing import Any

# Average rural road speed (km/h) and handling overhead (minutes)
AVG_ROAD_SPEED_KMH = 35.0
HANDLING_MINUTES = 10


def haversine_km(lat1: float, lng1: float, lat2: float, lng2: float) -> float:
    """Great-circle distance between two points in kilometres."""
    r = 6371.0
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    d_phi = math.radians(lat2 - lat1)
    d_lambda = math.radians(lng2 - lng1)

    a = (
        math.sin(d_phi / 2) ** 2
        + math.cos(phi1) * math.cos(phi2) * math.sin(d_lambda / 2) ** 2
    )
    return 2 * r * math.asin(math.sqrt(a))


def estimate_travel_minutes(distance_km: float) -> int:
    """Estimated door-to-door travel time including loading/handling."""
    driving_minutes = (distance_km / AVG_ROAD_SPEED_KMH) * 60
    return int(round(driving_minutes + HANDLING_MINUTES))


def _priority_for_level(level: str) -> str:
    if level == "red":
        return "emergency"
    if level == "yellow":
        return "recommended"
    return "available"


def rank_facilities_for_district(
    district: dict[str, Any],
    facilities: list[dict[str, Any]],
    top_n: int = 3,
) -> list[dict[str, Any]]:
    """
    Rank facilities for one district result (from the sync pipeline).

    `district` must expose centroid_lat/centroid_lng and risk.level.
    Returns up to `top_n` dispatch recommendations, sorted best-first.
    """
    lat = district.get("centroid_lat")
    lng = district.get("centroid_lng")
    level = district.get("risk", {}).get("level", "green")

    if lat is None or lng is None:
        return []

    matches = []
    for facility in facilities:
        available = float(facility.get("available_capacity_tons", 0) or 0)
        if available <= 0:
            continue  # full facilities cannot accept a dispatch

        distance = haversine_km(
            lat, lng, facility.get("lat", 0), facility.get("lng", 0)
        )
        capacity = float(facility.get("capacity_tons", 0) or 0)
        capacity_ratio = available / capacity if capacity > 0 else 0.0

        # Composite match score (higher is better): near + lots of space
        match_score = max(
            0.0,
            (1.0 - min(distance, 120.0) / 120.0) * 60.0
            + capacity_ratio * 40.0,
        )

        matches.append(
            {
                "facility_id": facility.get("id"),
                "facility_name": facility.get("name"),
                "facility_type": facility.get("type"),
                "district": facility.get("district"),
                "lat": facility.get("lat"),
                "lng": facility.get("lng"),
                "distance_km": round(distance, 1),
                "est_travel_minutes": estimate_travel_minutes(distance),
                "available_capacity_tons": available,
                "capacity_utilization_pct": round(
                    (1 - capacity_ratio) * 100, 1
                ),
                "match_score": round(match_score, 1),
                "contact_name": facility.get("contact_name"),
                "contact_phone": facility.get("contact_phone"),
                "contact_email": facility.get("contact_email"),
                "operational_hours": facility.get("operational_hours"),
                "priority": _priority_for_level(level),
            }
        )

    matches.sort(key=lambda m: m["match_score"], reverse=True)
    return matches[:top_n]


def build_dispatch_plan(
    risk_results: list[dict[str, Any]],
    facilities: list[dict[str, Any]],
    top_n: int = 3,
) -> list[dict[str, Any]]:
    """
    Attach a `dispatch` recommendation list to every district result.
    Returns the mutated results for chaining.
    """
    for district in risk_results:
        district["dispatch"] = rank_facilities_for_district(
            district, facilities, top_n=top_n
        )
        district["dispatch_generated_at"] = district.get("updated_at")
    return risk_results
