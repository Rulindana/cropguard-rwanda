# Product Requirements Document (PRD)
## CropGuard AI — Post-Harvest Risk Monitoring System for Rwanda

**Version:** 1.0  
**Track:** Track 1: Agricultural Productivity  
**Date:** October 2026  

---

## 1. Problem Statement

In Rwanda, **20–35% of harvested crops** are lost after leaving the field — to
rot, mould, and aflatoxin contamination triggered by unseasonal rainfall,
humidity spikes, and delayed collection. Smallholder farmers, who produce the
majority of Rwanda's food staples (maize, beans, Irish potatoes, cassava),
rarely have access to timely weather-risk information or to the nearest
storage facility with free capacity at the moment it matters.

The consequences fall on three groups:

1. **Farmers** — lose income when a harvest rots because no one warned them
   rain was coming in the next 48 hours.
2. **Agricultural planners** — lack a district-level, real-time view of where
   post-harvest risk is concentrating this week.
3. **Policymakers** — cannot rapidly verify whether emergency drying/storage
   capacity is being deployed where risk is highest.

## 2. Why This System Exists

CropGuard AI closes the loop between **official statistics (NISR SAS)**,
**live meteorological data (Open-Meteo)**, and **satellite-derived soil
moisture (ERA5/Copernicus)** on one side, and **the farmer standing in the
field** on the other side — through a mobile app, SMS alerts, and a USSD
menu that work even on feature phones without internet.

Without this system: risk information exists only in spreadsheets and
weather apps that report *weather*, not *crop consequences*. With it: a
district's risk score is computed every 6 hours, communicated in
Kinyarwanda by SMS, and paired with a dispatch plan naming the exact
facility to call.

## 3. Alignment with National Priorities

### NST2 (National Strategy for Transformation 2017–2024, successor priorities)
- **Pillar 2 — Economic transformation / agriculture:** increase agricultural
  productivity and market access; reduce post-harvest losses.
- **Objective:** accelerate growth and modernisation of agriculture,
  including irrigation, storage, and aggregation infrastructure.
- CropGuard directly targets **post-harvest loss reduction** — one of the
  measurable NST2 agriculture indicators — by giving every district an
  early-warning score and a concrete action (dry within 48h / dispatch to
  storage now).

### Vision 2050
- **Pillar 5 — Modernisation and prosperity:** a productive, knowledge-based
  agriculture with resilient, data-driven food systems.
- CropGuard contributes a **data-driven early-warning layer** for the food
  system — a reusable public-good platform for agricultural risk.

### Track 1 hint coverage
| Track hint | Covered by CropGuard |
|---|---|
| Post-harvest collection and storage | ✅ Core problem — risk scoring + facility dispatch matching |
| Soil conservation and fertility management | ✅ Satellite soil-moisture fusion component |
| Small-scale irrigation | ✅ Rainfall/soil moisture indices inform drying vs. irrigation timing |
| Agricultural productivity processing & value addition | ✅ Drying/storage routing reduces aflatoxin → higher-grade produce |
| Export market opportunities | ✅ Lower post-harvest loss = more exportable surplus, aflatoxin-compliant maize |

## 4. Users & Personas

| Persona | Need | CropGuard feature |
|---|---|---|
| Smallholder farmer | "Is it safe to harvest today?" | SMS/USSD alert in Kinyarwanda, color-coded district risk |
| Cooperative leader | "Where do I dry/store crops in the next 48h?" | Dispatch screen: nearest facility, free capacity, one-tap call |
| District agricultural planner | "Which of my districts are red this week?" | Interactive map, national dashboard, trend indicators |
| Extension officer | "Who do I call for emergency capacity?" | Facility catalog with contacts, reservation email template |
| Policymaker / development partner | "Where should emergency resources go?" | Exportable policy brief + national risk distribution |

## 5. Solution Architecture

```
NISR SAS baseline ─┐
Open-Meteo weather ─┼─> Python sync pipeline (6-hourly cron)
ERA5 soil moisture ─┘        │
                             ├─> Fused risk score (0–100) per district
                             ├─> Facility dispatch plan (top-3, ranked)
                             ├─> Data quality report
                             ├─> SMS/USSD bilingual alerts (on level change)
                             └─> Firestore ──> Flutter app (Android / Web)
                                                     ├─ Interactive map
                                                     ├─ District detail + trend
                                                     ├─ Dispatch screen
                                                     └─ SMS opt-in
```

## 6. Requirements

### Functional
- **R1.** Compute a 4-component risk score for all 30 districts every 6 hours:
  `(Rainfall × 0.35) + (Humidity × 0.25) + (Loss Rate × 0.25) + (Soil Moisture × 0.15)`
- **R2.** Classify green (0–39) / yellow (40–69) / red (70–100) with a plain-language advisory.
- **R3.** Rank the top-3 nearest facilities with free capacity per district (haversine + capacity score).
- **R4.** Send bilingual SMS alerts on risk-level *escalation only* (anti-spam state).
- **R5.** Publish a USSD digest so feature-phone users can dial and read district risk.
- **R6.** Validate input datasets every run; publish a data-quality report.
- **R7.** Track risk history and surface trend (rising / falling / stable).
- **R8.** Generate an exportable national policy brief for planners.

### Non-functional
- **N1.** Pipeline must tolerate API failures gracefully (estimated fallbacks, never crash).
- **N2.** App must render key information even when Firestore data is stale (timestamps shown).
- **N3.** SMS content ≤ 2 segments, Kinyarwanda + English.
- **N4.** No personally identifiable data collected beyond opted-in phone numbers.

## 7. Success Metrics

| Metric | Target |
|---|---|
| Districts covered | 30 / 30 |
| Pipeline uptime (6-hourly runs) | ≥ 95% |
| Data completeness per run | ≥ 98% |
| Alert precision (escalation-only) | 0 duplicate alerts per unchanged level |
| Farmer reach without internet | SMS + USSD channels |
| Time from red alert to dispatch decision | < 10 minutes (app) |

## 8. Who Builds and Maintains This System

| Component | Owner | Maintenance |
|---|---|---|
| Sync pipeline (`sync_pipeline/`) | NISR / Ministry of Agriculture (agri-data team) | GitHub Actions cron every 6 hours; secrets managed by data team |
| Firestore + security rules | NISR data platform team | Rules reviewed quarterly (`firestore_rules/firestore.rules`) |
| Flutter app (Android/Web) | NISR digital services / contracted developer | Release per season; store listing managed by owner |
| SMS/USSD gateway (Africa's Talking) | Ministry of Agriculture communications unit | Credits + subscriber opt-in list; STOP requests honoured |
| Facility registry data | District agricultural offices | Verified each season (capacity, contacts, hours) |
| NISR SAS baselines | NISR | Updated with each Seasonal Agricultural Survey release |

**Operational hand-off assumption:** CropGuard is designed as a **public-good
tool** — the repository (MIT licence) can be adopted by NISR or MINAGRI with
the existing GitHub Actions workflow, requiring only Firebase and SMS
gateway credentials as secrets.

## 9. Out of Scope (v1)

- Farmer-to-facility booking transactions (payments)
- Crop insurance integration
- Per-field (sub-district) modelling — v1 is district-level
- iOS store publication (web + Android first)

## 10. Risks & Mitigations

| Risk | Mitigation |
|---|---|
| Weather API outage | Rainfall/humidity fallback estimates; soil moisture falls back to rainfall-derived index |
| SMS gateway outage | Dry-run outbox preserves message log; alerts retry next run on level change |
| Facility data goes stale | Seasonal verification loop with district offices (see §8) |
| Alert fatigue | Escalation-only anti-spam state (`alert_state.json`) |
| Data quality drift | Automated data-quality report every run |

