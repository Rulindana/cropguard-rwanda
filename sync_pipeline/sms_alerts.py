#!/usr/bin/env python3
"""
CropGuard AI - SMS / USSD Alerts
=================================
Innovation #1: SMS/USSD Alerts (inclusivity - no smartphone or internet
required)

Sends bilingual (English / Kinyarwanda) risk alerts to subscribed farmers
and cooperative managers whenever a district's risk level changes to
YELLOW or RED. Alerts go out through Africa's Talking SMS gateway when
credentials are configured; otherwise they are written to a local outbox
file (dry-run mode) so the flow is always demonstrable.

Anti-spam behaviour:
- Alerts fire on risk-level *changes* (and the first observation),
  never on every 6-hourly pipeline run
- State is persisted in data/alert_state.json

A USSD digest (data/ussd_digest.json) is also generated so operators can
publish the same content behind a *123# style menu - zero internet needed.

Usage:
    from sms_alerts import dispatch_alerts
    dispatch_alerts(risk_data)

Environment (optional, for live sending):
    AT_USERNAME     - Africa's Talking username (usually 'sandbox'/'app')
    AT_API_KEY      - Africa's Talking API key
    AT_SENDER_ID    - optional sender ID
"""

import json
import os
import sys
from datetime import datetime, timezone
from typing import Any

import requests

DATA_DIR = os.path.join(os.path.dirname(__file__), "..", "data")
SUBSCRIBERS_FILE = os.path.join(DATA_DIR, "subscribers.json")
ALERT_STATE_FILE = os.path.join(DATA_DIR, "alert_state.json")
OUTBOX_FILE = os.path.join(DATA_DIR, "alerts_outbox.json")
USSD_DIGEST_FILE = os.path.join(DATA_DIR, "ussd_digest.json")

# Africa's Talking SMS endpoint
AT_URL = "https://api.africastalking.com/version1/messaging"

# Levels that trigger an alert (green = silent unless recovering from worse)
ALERT_LEVELS = {"yellow", "red"}

# ─────────────────────────────────────────────────────────────
# Message templates (EN + Kinyarwanda)
# ─────────────────────────────────────────────────────────────

MESSAGES = {
    "en": {
        "red": (
            "CropGuard ALERT: {district} post-harvest risk is "
            "{score}% (HIGH). Cause: {cause}. "
            "Move crops to covered storage NOW. "
            "Nearest facility: {facility} {phone}"
        ),
        "yellow": (
            "CropGuard: {district} post-harvest risk is {score}% "
            "(CAUTION). Cause: {cause}. "
            "Arrange drying within 48h. Nearest facility: "
            "{facility} {phone}"
        ),
        "recovery": (
            "CropGuard: {district} post-harvest risk is back to "
            "{score}% (LOW). Rain: {rain}mm, Humidity: {humidity}%. "
            "Normal harvesting conditions."
        ),
    },
    "rw": {
        "red": (
            "CropGuard UMURONGO UKOMEYE: {district} umuvandu w'ibihingwa "
            "ugera ku {score}% (HEJURYO). Impamvu: {cause}. "
            "Ohereza ibihingwa mu bubiko ubu. {facility} {phone}"
        ),
        "yellow": (
            "CropGuard: {district} umuvandu w'ibihingwa ugera ku {score}% "
            "(IMENYETSO). Impamvu: {cause}. "
            "Teekera icyuma cy'ongera umuvandu mu masaa 48. "
            "{facility} {phone}"
        ),
        "recovery": (
            "CropGuard: {district} umuvandu washize ku {score}% "
            "(AGATINTO). Imvura: {rain}mm, Ubuhehere: {humidity}%. "
            "Ibihingwa bigira buhoro."
        ),
    },
}

# ─────────────────────────────────────────────────────────────
# Subscribers & alert state
# ─────────────────────────────────────────────────────────────


def load_subscribers() -> list[dict[str, Any]]:
    """
    Load SMS subscribers.

    Source 1: Firestore /subscribers collection (production, if creds exist)
    Source 2: data/subscribers.json (demo / offline mode)
    """
    firestore_subs = _load_subscribers_from_firestore()
    if firestore_subs:
        return firestore_subs

    if not os.path.exists(SUBSCRIBERS_FILE):
        return []
    with open(SUBSCRIBERS_FILE, "r") as f:
        return json.load(f)


def _load_subscribers_from_firestore() -> list[dict[str, Any]]:
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore
    except ImportError:
        return []

    if not firebase_admin._apps:
        cred_path = os.path.join(
            os.path.dirname(__file__), "..", "firebase_service_account.json"
        )
        if not os.path.exists(cred_path):
            return []
        try:
            firebase_admin.initialize_app(credentials.Certificate(cred_path))
        except Exception:
            return []

    try:
        db = firestore.client()
        docs = db.collection("subscribers").stream()
        return [dict(doc.to_dict(), id=doc.id) for doc in docs]
    except Exception as e:
        print(f"  WARNING: Firestore subscriber read failed: {e}", file=sys.stderr)
        return []


def load_alert_state() -> dict[str, Any]:
    """Previous risk level per district (anti-spam state)."""
    if not os.path.exists(ALERT_STATE_FILE):
        return {}
    with open(ALERT_STATE_FILE, "r") as f:
        return json.load(f)


def save_alert_state(state: dict[str, Any]) -> None:
    with open(ALERT_STATE_FILE, "w") as f:
        json.dump(state, f, indent=2)


# ─────────────────────────────────────────────────────────────
# Message composition
# ─────────────────────────────────────────────────────────────


def _top_facility(district: dict[str, Any]) -> dict[str, Any] | None:
    dispatch = district.get("dispatch") or []
    return dispatch[0] if dispatch else None


def _build_cause(district: dict[str, Any], language: str) -> str:
    """
    Build a short cause sentence from sensor data for SMS/USSD messages.
    Picks the dominant sensor(s) that drove the risk level.

    Weather values are read from district["weather"] (where the pipeline
    writes them) rather than district["risk"] so the cause sentence always
    reflects the actual sensor readings.
    """
    weather = district.get("weather") or {}
    rain   = weather.get("total_precipitation_14d_mm", 0.0)
    humid  = weather.get("max_humidity_pct", 0.0)
    soil   = weather.get("soil_moisture_index") or 0.0

    parts_en = []
    parts_rw = []
    if rain > 80:
        parts_en.append(f"{rain:.0f}mm rain (14d)")
        parts_rw.append(f"imvura {rain:.0f}mm (iminsi 14)")
    if humid > 75:
        parts_en.append(f"{humid:.0f}% humidity")
        parts_rw.append(f"ubuhehere {humid:.0f}%")
    if soil > 65:
        parts_en.append(f"{soil:.0f}% soil moisture")
        parts_rw.append(f"ubutaka bujyijwe {soil:.0f}%")

    if not parts_en:
        # fallback: show raw numbers even if below thresholds
        parts_en.append(f"{rain:.0f}mm rain, {humid:.0f}% humidity")
        parts_rw.append(f"imvura {rain:.0f}mm, ubuhehere {humid:.0f}%")

    return (", ".join(parts_rw) if language == "rw" else ", ".join(parts_en))


def compose_message(district: dict[str, Any], level: str, language: str) -> str:
    """Build a single alert SMS for a district and target language."""
    facility = _top_facility(district)
    facility_name = facility["facility_name"] if facility else "District agri office"
    facility_phone = facility["contact_phone"] if facility else ""

    rain  = district["risk"].get("total_precipitation_14d_mm", 0.0)
    humid = district["risk"].get("max_humidity_pct", 0.0)
    cause = _build_cause(district, language)

    if level not in ALERT_LEVELS:
        template = MESSAGES.get(language, MESSAGES["en"])["recovery"]
        return template.format(
            district=district["district_name"],
            score=f"{district['risk']['risk_score']:.0f}",
            rain=f"{rain:.0f}",
            humidity=f"{humid:.0f}",
        )

    template = MESSAGES.get(language, MESSAGES["en"])[level]
    return template.format(
        district=district["district_name"],
        score=f"{district['risk']['risk_score']:.0f}",
        cause=cause,
        facility=facility_name,
        phone=facility_phone,
    )


# ─────────────────────────────────────────────────────────────
# Sending
# ─────────────────────────────────────────────────────────────


def send_sms(phone: str, message: str) -> dict[str, Any]:
    """
    Send one SMS via Africa's Talking if configured, else dry-run to the
    local outbox file.
    """
    username = os.environ.get("AT_USERNAME")
    api_key = os.environ.get("AT_API_KEY")

    if username and api_key:
        try:
            response = requests.post(
                AT_URL,
                data={"username": username, "to": phone, "message": message},
                headers={"apiKey": api_key, "Accept": "application/json"},
                timeout=30,
            )
            response.raise_for_status()
            return {"status": "sent", "channel": "africastalking", "to": phone}
        except requests.RequestException as e:
            print(
                f"  WARNING: SMS gateway failed for {phone}: {e}; "
                f"falling back to outbox",
                file=sys.stderr,
            )

    # Dry-run / offline mode
    entry = {
        "to": phone,
        "message": message,
        "queued_at": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"),
        "status": "demo_queued",
        "note": "Africa's Talking integration is deployment-ready; message written to outbox because AT_USERNAME/AT_API_KEY are not configured",
    }
    outbox = []
    if os.path.exists(OUTBOX_FILE):
        try:
            with open(OUTBOX_FILE, "r") as f:
                outbox = json.load(f)
        except (json.JSONDecodeError, OSError):
            outbox = []
    outbox.append(entry)
    with open(OUTBOX_FILE, "w") as f:
        json.dump(outbox, f, indent=2, ensure_ascii=False)
    return {"status": "dry_run", "channel": "outbox", "to": phone}


# ─────────────────────────────────────────────────────────────
# USSD digest
# ─────────────────────────────────────────────────────────────


def build_ussd_digest(risk_data: dict[str, Any]) -> dict[str, Any]:
    """
    Generate a USSD menu payload so operators can host the same content
    behind a dial-in menu (e.g. *123*1#) - zero internet on the farmer's
    side required.
    """
    menu_items = []
    for d in sorted(
        risk_data["districts"],
        key=lambda x: x["risk"]["risk_score"],
        reverse=True,
    ):
        menu_items.append(
            {
                "district_id": d["district_id"],
                "label": (
                    f"{d['district_name']} - {d['risk']['risk_score']:.0f}% "
                    f"({d['risk']['level'].upper()})"
                ),
                "level": d["risk"]["level"],
                "score": d["risk"]["risk_score"],
                "advisory": d["advisory"],
            }
        )

    digest = {
        "generated_at": datetime.now(timezone.utc)
        .isoformat()
        .replace("+00:00", "Z"),
        "shortcode": os.environ.get("USSD_SHORTCODE", "*123*1#"),
        "welcome_message": (
            "CropGuard Rwanda. Reply with district number for "
            "post-harvest risk:"
        ),
        "districts": menu_items,
    }
    with open(USSD_DIGEST_FILE, "w") as f:
        json.dump(digest, f, indent=2, ensure_ascii=False)
    return digest


# ─────────────────────────────────────────────────────────────
# Main entry point
# ─────────────────────────────────────────────────────────────


def dispatch_alerts(risk_data: dict[str, Any]) -> dict[str, Any]:
    """
    Compare current risk levels against previous state and notify
    subscribers of yellow/red escalations (and green recoveries).
    """
    print("[5/5] SMS/USSD alert dispatch...")

    state = load_alert_state()
    subscribers = load_subscribers()
    new_state: dict[str, Any] = {}
    counts = {"sent": 0, "dry_run": 0, "skipped": 0, "failed": 0}

    escalations: list[tuple[dict[str, Any], str]] = []
    for district in risk_data["districts"]:
        district_id = district["district_id"]
        level = district["risk"]["level"]
        previous = state.get(district_id)
        new_state[district_id] = {
            "level": level,
            "score": district["risk"]["risk_score"],
            "checked_at": district["updated_at"],
        }

        # Alert on first observation of yellow/red, or any level change
        changed = previous is None or previous.get("level") != level
        if not changed:
            counts["skipped"] += 1
            continue
        if level in ALERT_LEVELS or (
            previous and previous.get("level") in ALERT_LEVELS
        ):
            escalations.append((district, level))

    if not subscribers:
        print(
            f"      No subscribers found (add entries to {SUBSCRIBERS_FILE} "
            f"or /subscribers in Firestore)"
        )
    else:
        for district, level in escalations:
            for sub in subscribers:
                # Only notify subscribers watching this district (or 'all')
                watch = sub.get("district_id", "all")
                if watch not in ("all", district["district_id"]):
                    continue
                message = compose_message(district, level, sub.get("language", "en"))
                result = send_sms(sub.get("phone", ""), message)
                counts[result["status"]] = counts.get(result["status"], 0) + 1

    # USSD digest is always refreshed (read-only channel, no spam concern)
    build_ussd_digest(risk_data)

    save_alert_state(new_state)
    print(
        f"      Escalations: {len(escalations)}, "
        f"subscribers: {len(subscribers)}, "
        f"sent: {counts['sent']}, dry-run: {counts['dry_run']}, "
        f"unchanged (skipped): {counts['skipped']}"
    )
    print(f"      USSD digest written to: {USSD_DIGEST_FILE}")
    print()
    return counts


