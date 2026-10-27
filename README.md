# CropGuard AI 🇷🇼

**Post-Harvest Risk Monitoring System for Rwanda**  
*NISR Big Data Hackathon 2026 — Track 1: Agricultural Productivity*

[![Live Demo](https://img.shields.io/badge/Live%20Demo-nisr--b06b6.web.app-brightgreen)](https://nisr-b06b6.web.app)
[![Flutter](https://img.shields.io/badge/Flutter-3.7%2B-blue)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%2B%20Hosting-orange)](https://firebase.google.com)
[![CI/CD Pipeline](https://github.com/Rulindana/cropguard-rwanda/actions/workflows/sync_pipeline.yml/badge.svg)](https://github.com/Rulindana/cropguard-rwanda/actions/workflows/sync_pipeline.yml)
[![GitHub](https://img.shields.io/badge/GitHub-Public-black)](https://github.com/Rulindana/cropguard-rwanda)

## 📋 Quick Submission Links

| Item | Link | Status |
|---|---|---|
| **Public GitHub Repository** | [github.com/Rulindana/cropguard-rwanda](https://github.com/Rulindana/cropguard-rwanda) | ✅ Public |
| **Deployed Web App** | [nisr-b06b6.web.app](https://nisr-b06b6.web.app) | ✅ Live |
| **Android APK** | [CropGuard_Rwanda_v3.4-blackfix.apk](./CropGuard_Rwanda_v3.4-blackfix.apk) | ✅ Included |
| **Documentation** | [README.md](./README.md) \| [DOCUMENTATION.md](./DOCUMENTATION.md) \| [PRD.md](./PRD.md) | ✅ Complete |

---

## 🎯 Problem Statement

**NISR already collects the data. Rwanda needs it to act.**

Every year, the National Institute of Statistics of Rwanda (NISR) conducts the **Seasonal Agricultural Survey (SAS)** through extensive field visits, enumerator work, data entry, and analysis. This valuable data ends up in annual PDF reports — read once and filed away. 

**CropGuard AI** turns NISR's own agricultural data into **real-time, actionable early warnings** for post-harvest losses across all 30 districts of Rwanda. Our solution predicts post-harvest risks **6 hours ahead**, alerting farmers, cooperatives, and district planners **before** losses occur — not after. 

*Using NISR's data to save Rwandan crops, income, and food security.*

---

## 🎯 The Problem

In Rwanda, unseasonal rainfall during harvest periods causes devastating post-harvest losses:
- **20–35%** of crops lost to rot and aflatoxin contamination annually *(NISR SAS 2024 Annual Report, p. 47)*
- Maize production alone: **~580,000 MT harvested nationally** — up to **203,000 MT lost** before reaching market *(NISR SAS 2024, Table 21)*
- Estimated annual economic loss: **≈ RWF 150–220 billion** (≈ USD 130–190 million) in spoiled or aflatoxin-contaminated grain
- Smallholder farmers (80% of agricultural workforce) lack real-time weather + risk data
- Poor coordination between farmers and post-harvest storage facilities
- District planners have no centralized early-warning dashboard
- Rwanda's NST2 explicitly targets **halving post-harvest losses** by 2029 as a food security pillar

---

## 🇷🇼 National Alignment: NST2 & Vision 2050

CropGuard AI directly supports Rwanda's national priorities for agricultural transformation:

| National Priority | NST2 Reference | How CropGuard Contributes |
|---|---|---|
| **Post-harvest loss reduction** | **NST2 Pillar 2** (Economic Transformation), Cluster 6 (Agriculture), Outcome Indicator 6.3: *"Reduce post-harvest losses from 30% to 15% by 2029"* | **Core Impact:** 6-hourly risk alerts + facility dispatch for all 30 districts to prevent losses before they happen. |
| **Agricultural productivity** | NST2 Pillar 2, Cluster 6, Output Indicator 6.1: *"Increase agricultural productivity"* | Connects farmers to nearest drying grounds & silos at the right time, saving harvests that would otherwise rot. |
| **Evidence-based planning** | NST2 Pillar 3 (Social Transformation), Cluster 14 (Data & M&E), Outcome 14.2: *"Strengthen evidence-based decision-making"* | Real-time district dashboard + exportable policy brief empowers MINAGRI & district planners with data-driven insights. |
| **Digital transformation** | **Vision 2050** — ICT-led innovation pillar | AI-powered multilingual solution (Kinyarwanda, English, French) accessible via smartphone, SMS, and USSD. |
| **Track 1 — Post-harvest collection & storage** | NST2 Indicator 6.3.1 | ✅ **Primary focus** — Early warning + storage facility routing. |
| **Track 1 — Soil conservation & fertility** | NST2 Indicator 6.2.2 | ✅ Satellite soil-moisture fusion for improved risk detection. |
| **Track 1 — Processing, value addition & export** | NST2 Indicator 6.4.1 | ✅ Reduces aflatoxin risk → higher-grade, more export-compliant produce. |

> **NST2 = National Strategy for Transformation 2 (2024–2029).** Indicator codes reference the official NST2 results framework (Pillar → Cluster → Outcome/Output Indicator). See: [https://www.minagri.gov.rw](https://www.minagri.gov.rw)

---

## 📊 NISR Data Used

**CropGuard AI is built directly on official NISR data.** We used the following NISR datasets to drive our solution:

| NISR Data Source | Usage in CropGuard |
|---|---|
| **NISR Seasonal Agricultural Survey (SAS) 2013–2025** | Core district-level baselines for crop production, harvested area, and post-harvest losses across all 30 districts of Rwanda. |
| **SAS District-Level Post-Harvest Loss Rates** | Historical post-harvest loss percentages used as the **Loss Rate Index** (25% weight) in our risk scoring model. |
| **SAS Crop Production Statistics** | Quantified potential impact (e.g., maize production of ~580,000 MT with up to ~203,000 MT at risk of post-harvest loss). |
| **NISR Administrative Boundaries (Districts)** | Used for accurate district mapping, geo-visualization, and per-district risk computation. |

*References: NISR SAS Annual Reports (notably 2024, p.47, Table 21) — cited throughout the app and documentation.*

**Data Fusion:** NISR SAS baselines are fused with **Open-Meteo API** (live rainfall & humidity) and **ERA5/Copernicus** satellite-derived soil moisture, recalculated every **6 hours** via our automated pipeline.

## ✨ How It Works

```
[1. NISR SAS Baselines] ──▶  [2. AI Risk Engine]     ──▶  [3. Actionable Alerts]
  • 2013–2025 SAS data        • Fused Risk Formula          • Interactive Rwanda Map (App/Web)
  • District loss rates       • Weather + Soil Moisture    • SMS Alerts (Kinyarwanda/English)
  • Production stats          • 6-hourly Auto-Updates       • USSD Menu (Feature Phones)
  • Facility registry         • Facility Dispatch Logic     • District Dashboard + Policy Brief
```

### Risk Scoring Formula (satellite-fused)

```
Post-Harvest Risk Score = (Rainfall Index × 0.35) + (Humidity Index × 0.25)
                        + (Loss Rate Index × 0.25) + (Soil Moisture Index × 0.15)
```

> **Model Validation & Weight Derivation**
>
> The 4-component weights are a transparent heuristic, calibrated against NISR SAS annual reports and the district loss patterns visible in `data/nisr_sas_districts.json`. They are not the output of a fitted statistical model; they are an interpretable, auditable starting point that NISR or MINAGRI can recalibrate with additional data.
>
> - **Rainfall (0.35)** — Highest weight: NISR SAS annual reports consistently identify unseasonal rainfall during harvest windows as the primary driver of post-harvest loss across all 30 districts.
> - **Humidity (0.25)** — Secondary driver: Relative humidity above 75% triggers fungal rot and aflatoxin risk. NISR SAS 2024 Table 22 shows districts with sustained high humidity (Musanze, Burera) report elevated loss rates for Irish potato.
> - **Loss Rate (0.25)** — Historical baseline: each district's multi-year average loss rate acts as a prior — districts with consistently high losses are more vulnerable to new weather shocks.
> - **Soil Moisture (0.15)** — Supplementary signal: volumetric soil moisture from ERA5/Copernicus satellite catches waterlogged fields that rainfall-only models miss. Weighted lower because it is partially correlated with rainfall.
>
> **Transparent validation:** A heuristic validation table is included in `reports/model_validation.md`. It shows how the formula ranks known high-loss districts (e.g. Musanze, Burera, Bugesera) and documents the limitations. It does **not** claim a fitted correlation coefficient or a back-test against held-out NISR loss data, because that has not been run. The formula can be recalibrated each pipeline run as new weather and loss data arrive.

| Risk Level | Score | Action |
|------------|-------|--------|
| 🟢 Green   | 0–39% | Safe harvesting conditions |
| 🟡 Yellow  | 40–69% | Drying equipment needed within 48h |
| 🔴 Red     | 70–100% | Emergency storage dispatch required |

---

## 📱 Features (v3.0)

### 🗺️ Interactive Risk Map
- Color-coded Rwanda map — all 30 districts in real-time
- Tap a district to see harvest volumes, weather, risk breakdown
- Map collapses when district is selected so detail is fully visible
- Animated map collapse/expand with smooth 350ms transition

### 🌡️ Real Location Weather
- GPS-based location detection — shows YOUR district's weather, not Musanze
- Requests location permission once, remembers it permanently
- Falls back gracefully if GPS is denied

### 🔬 AI Crop Disease Scanner
- Take or upload a photo of a plant leaf
- AI validates the image is actually a plant (rejects bibles, documents, etc.)
- Pixel-level green/brown color analysis for plant detection
- Identifies **16 verified disease profiles** across 8 crops (maize, beans, cassava, potato, banana, tomato, wheat & coffee), with local agronomist-reviewed treatment guides
- Full treatment steps, prevention tips, confidence score
- Camera and gallery permission asked only once (remembered permanently)

### 🏪 Storage Facility Finder
- Ranked dispatch plan: nearest facilities with free capacity
- Always loads from local data when Firestore is unavailable
- One-tap call or email to facility manager
- Map view + list view

### 📢 SMS/USSD Alerts
- Bilingual (Kinyarwanda + English) risk alerts
- Works on any phone — no internet required
- In-app subscription per district

### 🌐 Multilingual (EN / RW / FR)
- Every string translated — no hardcoded English left
- Risk indicators, tips, scan steps, field report — all 3 languages
- Switch language live with EN/RW/FR toggle

### 👥 Credits / Team
- All 3 team members with photos
- ISHIMWERYAYO Jean Damour photo now showing

---

## 🏆 Top Innovations

### 🥇 AI Plant Disease Scanner with Validation
- Image pixel analysis to reject non-plant photos before AI runs
- 16 verified disease profiles across Rwanda's main crops with full treatment guides, prevention tips and local context (symptoms, causes, treatment) for each crop
- Confidence scoring, alternative diagnoses, prevention tips

### 🥈 Facility Dispatch Matching
- Ranked dispatch plan per district: nearest storage with free capacity
- Distance + capacity composite match score
- One-tap call/reserve — emergency/recommended/available priority tags

### 🥉 Satellite Data Fusion
- 4th risk component: volumetric soil moisture from ERA5/Copernicus
- Catches rot risk that rainfall-only models under-estimate

---

## 🛠 Tech Stack

| Component | Technology |
|-----------|------------|
| Mobile & Web App | Flutter 3.7+ (Android, iOS, Web — single codebase) |
| Backend | Firebase Firestore + Hosting |
| Weather | Open-Meteo API (no key needed, free, real-time) |
| Data | NISR SAS 2013–2025 (12 years, official Excel + PDF files) |
| Maps | Flutter Map + ESRI Satellite Imagery |
| Location | Geolocator (GPS — real device coordinates) |
| AI Scanner | Vision model via Cloudflare Worker free proxy OR OpenAI |
| Alerts | Africa's Talking SMS Gateway (bilingual EN/RW) |
| CI/CD | GitHub Actions (6-hourly automated sync pipeline) |
| Satellite | ERA5/Copernicus soil moisture (4th risk component) |

### 🤖 Cloudflare Worker AI Proxy — How It Works

The AI disease scanner uses a **Cloudflare Worker** (`cloudflare_worker/`) as a free, no-key-needed AI proxy:

```
[Flutter App]  ──POST /diagnose──▶  [Cloudflare Worker]  ──▶  [@cf/llava-1.5-7b-hf]
     ▲                                     │                       (Vision Model)
     │                                     ▼
     └─────── JSON diagnosis ◀──── Structured response
               {disease, confidence, treatment}
```

- **Free tier:** ~500 AI scans/day with no API key required
- **Fallback:** Automatically falls back to local disease database if AI is unavailable
- **No data stored:** Images are never persisted — sent directly to Cloudflare inference
- Worker source: `cloudflare_worker/worker.js`

### 🔄 Automated Pipeline Architecture

```
GitHub Actions (every 6 hours)
        │
        ▼
sync_nisr_data.py
   ├── load_nisr_data()          ← NISR SAS district baselines
   ├── fetch_weather()           ← Open-Meteo 14-day forecast
   ├── calculate_soil_moisture() ← ERA5/Copernicus satellite
   ├── calculate_risk_score()    ← 4-component weighted formula
   ├── build_dispatch_plan()     ← Nearest facility matching
   ├── run_quality_checks()      ← Data validation
   └── dispatch_alerts()         ← SMS if risk level changes
        │
        ▼
   data/risk_scores.json  ──▶  Firebase Firestore  ──▶  Flutter App
```

---

## 📁 Project Structure

```
cropguard-rwanda/
├── flutter_app/
│   └── cropguard_app/
│       ├── lib/
│       │   ├── models/         # District, Facility, Disease models
│       │   ├── screens/        # All app screens
│       │   ├── services/       # Firebase, dispatch, alert services
│       │   ├── utils/          # Translations (EN/RW/FR), theme, GPS
│       │   └── widgets/        # Reusable components
│       └── assets/
│           ├── data/           # NISR district + facility JSON
│           ├── geo/            # Rwanda GeoJSON boundaries
│           └── icon/           # Team photos, logos
│
├── sync_pipeline/
│   ├── sync_nisr_data.py       # Main 6-hourly pipeline
│   ├── satellite_fusion.py     # Soil moisture from ERA5
│   ├── dispatch_matcher.py     # Facility ranking algorithm
│   └── sms_alerts.py           # Bilingual SMS/USSD dispatch
│
├── datas/                      # NISR SAS source data (2013–2025)
│   ├── 2013/ … 2025/           # Annual survey PDFs + tables
│   └── extracted_production.json
│
├── data/                       # Processed output data
│   ├── risk_scores.json        # 30-district risk scores
│   ├── facilities.json         # 21 post-harvest facilities
│   └── alerts_outbox.json      # SMS alert queue
│
└── .github/workflows/          # Automated sync pipeline
```

---

## 📊 Data Sources

| Source | Years | Usage | File |
|--------|-------|-------|------|
| NISR Seasonal Agricultural Survey (SAS) — Annual Tables | 2013–2025 | District baselines, crop volumes, historical loss rates | `data/nisr_sas_districts.json` |
| NISR SAS Extracted Crop Production | 2023–2025 | Actual MT production per district per season (A/B/C), directly parsed from official NISR Excel tables | `data/extracted_production.json` |
| Open-Meteo Weather API | Live | 14-day rainfall, humidity, temperature per district | Live API |
| ERA5/Copernicus Satellite | Live | Volumetric soil moisture — fused as 4th risk component | Live API |
| Africa's Talking | Live | SMS/USSD alert delivery | Live API |

> `data/extracted_production.json` contains **real production figures** (Metric Tonnes) for 30+ Rwanda districts across Seasons A, B, and C for 2023–2025, extracted directly from the official NISR SAS Annual Tables Excel files included in this repository.

---

## 📊 Evidence & Limitations

This section is included so judges and reviewers can see exactly what is proven, what is integrated but not yet live, and what is a transparent heuristic. It replaces any impression that every feature is already running in production.

### What is real and reproducible today

- **NISR data:** `data/nisr_sas_districts.json` and `data/extracted_production.json` are derived from NISR SAS annual reports and Excel tables (2013–2025). The raw source files are in `datas/` (2013–2025 subdirectories) and via the NISR Microdata Portal linked below. District baselines (crop volumes, historical loss rates, cooperative coverage) are extracted from those sources, not invented.
- **Weather:** Live 14-day forecast from the Open-Meteo API (no key required). Fetched for all 30 district centroids every pipeline run.
- **Satellite soil moisture:** ERA5/Copernicus land-surface soil moisture via the Open-Meteo ERA5 endpoint. Used as the 4th risk component.
- **Risk formula:** A transparent weighted sum over four 0–100 indices. Code: `sync_pipeline/sync_nisr_data.py` (`calculate_risk_score()`), `satellite_fusion.py`, `data_quality.py`. Any district score can be recomputed by hand from the four input files.
- **Dispatch matcher:** Deterministic haversine + capacity ranking in `sync_pipeline/dispatch_matcher.py`. Output schema is built for an operator.
- **Data quality:** Every run writes `data/data_quality_report.json` with a 0–100 score, per-check issues, and completeness.

### What is integration-ready but not yet live

- **Firestore sync:** `sync_pipeline/sync_nisr_data.py` contains a complete `sync_to_firestore()` function. It is called when the `FIREBASE_CREDENTIALS` environment variable is set. When it is not set, the pipeline emits `data/risk_scores.json` only and the app continues to read its bundled asset copy. To make the 6-hourly automation publish to the live app, add the Firebase service account as a base64-encoded GitHub secret named `FIREBASE_CREDENTIALS` and trigger a run.
- **SMS/USSD:** `sync_pipeline/sms_alerts.py` implements bilingual message composition, anti-spam state, and the Africa's Talking dispatch path. When `AT_USERNAME`/`AT_API_KEY` are not configured, messages are written to `data/alerts_outbox.json` with status `demo_queued` and a note explaining the integration is deployment-ready. To send real messages, configure the Africa's Talking credentials as GitHub secrets and subscribe at least one test phone number in `data/subscribers.json` or the Firestore `/subscribers` collection.
- **USSD:** `data/ussd_digest.json` is regenerated every run and is ready to be hosted behind a shortcode. It has no live telecom shortcode until one is provisioned.
- **AI disease scanner:** The scanner calls a real vision model. When no API key / connectivity is available, the app shows an explicit error instead of fabricating a diagnosis. A local pre-filter rejects non-plant images before any API call.

### What is a transparent heuristic, not a proven statistical result

- **Risk weights:** The 0.35 / 0.25 / 0.25 / 0.15 weights are an interpretable heuristic aligned to NISR SAS narrative findings. They are not the output of a fitted regression or a cross-validated back-test. See `reports/model_validation.md` for the honest validation and limitations.
- **Impact figures:** The economic impact numbers in this README and in the policy brief are scenario projections (e.g. "if 50% of high-risk losses are prevented"), not measured outcomes. They are computed from NISR SAS production volumes and MINAGRI reference prices and are clearly labelled as potential impact.

### NISR source references

| Dataset | Years | Used for | Reference |
|--------|-------|----------|----------|
| Seasonal Agricultural Survey (SAS) annual reports | 2013–2025 | District baselines, historical loss rates, harvest windows | NISR Microdata Portal: https://microdata.statistics.gov.rw/index.php/catalog |
| SAS Annual Tables (Excel) | 2023–2025 | Crop production volumes per district per season (A/B/C) | Available via the catalog above; parsed into `data/extracted_production.json` |
| Open-Meteo forecast API | Live | Rainfall, humidity, temperature per district | https://open-meteo.com/ |
| ERA5/Copernicus land-surface soil moisture | Live | 4th risk component | via Open-Meteo ERA5 endpoint |

### Known limitations

- The pipeline currently falls back to estimated rainfall/humidity values when the Open-Meteo API is unreachable for a district. Those estimates are labelled as estimates in the run log and do not claim to be measured.
- Facility data in `data/facilities.json` is a working catalog assembled for the prototype from publicly listed drying grounds, silos, cold-storage centres, and mobile-dryer fleets associated with district agricultural offices and cooperatives. It includes 21 facilities with GPS coordinates, capacity, contacts, and operational hours. Capacity, contacts, and hours should be verified with each district agricultural office each season before operational use. If a judge or reviewer needs the source for a specific facility, the team can name the district office or cooperative directory it was compiled from; the repository does not include individual signed data-sharing agreements for v1.
- v1 is district-level. Sub-district / per-field modelling and per-farmer plot tracking are out of scope.
- iOS store publication is out of scope for v1 (web + Android first).

### How to reproduce the current scores

1. Ensure `data/nisr_sas_districts.json`, `data/facilities.json`, and `data/extracted_production.json` are present.
2. Run `python sync_pipeline/sync_nisr_data.py`.
3. The pipeline fetches live weather + satellite data, computes the 4-component score for all 30 districts, attaches a dispatch plan, writes `data/risk_scores.json`, `data/data_quality_report.json`, `data/alerts_outbox.json`, `data/ussd_digest.json`, and a dated policy brief under `reports/`.
4. Any district score can be traced back to four numbers (rainfall index, humidity index, loss-rate index, soil-moisture index) and the weights in `RISK_WEIGHTS`.

### 📂 Raw Data Access (NISR Microdata Portal)

The raw NISR SAS source files (PDFs, Excel tables, questionnaires) for 2013–2025 are excluded from this repository due to size (91 MB). They can be accessed directly from the **NISR Microdata Portal**:

🔗 **NISR Microdata Portal:** [https://microdata.statistics.gov.rw/index.php/catalog](https://microdata.statistics.gov.rw/index.php/catalog)

> **How to access:** Register a free account → Search "Seasonal Agricultural Survey" → Click "Get Microdata" → Access is granted immediately for public-use datasets.

Key datasets used in this project:

| Survey | Year(s) | NISR Catalog |
|--------|---------|-------------|
| Seasonal Agricultural Survey (SAS) | 2013–2025 | [https://microdata.statistics.gov.rw/index.php/catalog](https://microdata.statistics.gov.rw/index.php/catalog) |
| SAS Annual Tables (Excel) | 2023–2025 | Available via the catalog above |
| SAS Annual Reports (PDF) | 2013–2025 | Available via the catalog above |

Processed data included in this repository:

| File | Description |
|------|-------------|
| `data/dataset.csv` | 30-district summary table (crops, loss rates, facilities) |
| `data/nisr_sas_districts.json` | Full district baselines extracted from SAS reports |
| `data/extracted_production.json` | MT production per district per season (A/B/C) 2023–2025 |
| `data/facilities.json` | 21 post-harvest facilities with GPS coordinates |
| `data/risk_scores.json` | Current 30-district risk scores (updated every 6 hours) |

---

## 🔐 Admin Panel

Login credentials are in the **App Screenshots & User Flow** section above (or see the table below for quick reference):

| Field | Value |
|-------|-------|
| **Email** | `admin@cropguard.ai` |
| **Password** | `CropGuard2026!` |

> Also works with `tesny2005@gmail.com` / `CropGuard2026!`

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.7+
- Firebase project (Firestore + Hosting)
- Python 3.11+ (for sync pipeline)

### Run the App
```bash
git clone https://github.com/Rulindana/cropguard-rwanda.git
cd cropguard-rwanda/flutter_app/cropguard_app
flutter pub get
flutter run
```

### Web Demo
🌐 **https://nisr-b06b6.web.app**

### Android APK
📱 **Download the APK:** https://github.com/Rulindana/cropguard-rwanda/releases

```bash
# or build yourself:
flutter build apk --release     # output: flutter_app/cropguard_app/build/app/outputs/flutter-apk/app-release.apk
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

### 🤖 AI Providers
- **Cloudflare Worker** — free tier (~500 scans/day, no API key required), real vision model via the proxy in `cloudflare_worker/` — **enabled by default on the live web app**
- **OpenAI** — higher accuracy option (needs an `AI_API_KEY` dart-define)
- Switch at runtime: `flutter run --dart-define=AI_PROVIDER=cloudflare` (or `openai`)

---

## 🖥️ App Screenshots & User Flow

> **Try it live:** https://nisr-b06b6.web.app

### 🔑 Login Credentials for Judges

> ⬛ **Demo Login (works immediately on the web app):**
>
> | Field | Value |
> |-------|-------|
> | Email | `admin@cropguard.ai` |
> | Password | `CropGuard2026!` |
>
> Alternative: `tesny2005@gmail.com` / `CropGuard2026!`

### App Flow

```
Landing Screen
    │
    ├── [Login] ──▶ Dashboard (Home)
    │                   │
    │                   ├── 🗺️  Interactive Risk Map
    │                   │       └── Tap district ──▶ District Detail
    │                   │                               ├── Risk breakdown (weather/soil/history)
    │                   │                               └── Storage dispatch plan (ranked facilities)
    │                   │
    │                   ├── 🔬  AI Disease Scanner
    │                   │       ├── Take/upload leaf photo
    │                   │       ├── AI validates it's a plant
    │                   │       └── Disease result + treatment steps
    │                   │
    │                   ├── 🏪  Facilities List
    │                   │       └── One-tap call/email facility manager
    │                   │
    │                   ├── 📢  SMS/USSD Alert Subscription
    │                   │       └── Subscribe per district (no internet needed for alerts)
    │                   │
    │                   └── 🌐  Language Toggle (EN / RW / FR)
    │
    └── [Admin Panel] ──▶ District risk management + alert dispatch
```

### Key Screens

- **Risk Map** — Rwanda map with 30 color-coded districts (green/yellow/red). Tap any district for details.
- **District Detail** — Shows rainfall, humidity, soil moisture, risk score breakdown, nearest storage facilities with capacity.
- **AI Scanner** — Upload a leaf photo → AI identifies disease, confidence %, treatment guide in your language.
- **Facilities** — Lists 21 post-harvest facilities with GPS, capacity, one-tap contact.
- **Admin Panel** — Login with credentials above. Manage alerts, view risk trends, download USSD digest.

## 📈 Impact Metrics

### Coverage
- **30 districts** monitored across all 5 provinces
- **21 facilities** cataloged (drying grounds, silos, cold storage, mobile dryers)
- **8 crops** with AI disease detection — 16 verified disease profiles (maize, beans, cassava, potato, banana, tomato, wheat & coffee)
- **12 years** of NISR SAS data integrated (2013–2025)
- **3 languages** — English, Kinyarwanda, French
- **6-hourly** automated risk score updates

### Quantified Economic Impact Potential

Rwanda produces approximately **580,000 MT of maize + beans** per season (NISR SAS 2024). At current losses of 20–35%:

| Scenario | Crop Saved | Value Preserved |
|----------|-----------|-----------------|
| If CropGuard prevents 50% of high-risk losses | ~58,000 MT / year | ≈ RWF 34 billion (≈ USD 29M) |
| If adopted across all 30 red-risk districts in peak season | ~29,000 MT / month | ≈ RWF 17 billion (≈ USD 14M) |
| Per farmer household (avg 0.5 ha, 600 kg harvest) | ~180 kg saved | ≈ RWF 108,000 (≈ USD 90) per household |

> Based on NISR SAS 2024 production data and MINAGRI commodity prices (maize ≈ RWF 600/kg, beans ≈ RWF 900/kg).

### Policy Brief
A detailed policy brief for MINAGRI and district agricultural planners is included in the repository:  
📄 `flutter_app/cropguard_app/assets/data/policy_brief.md`

---

## 🏛️ NISR as a Platform User — Data Capture & Forecasting

Beyond serving farmers and district officers, CropGuard AI is designed as a **continuous data infrastructure that NISR itself can use**:

| NISR Use Case | What CropGuard Provides |
|--------------|------------------------|
| **Between-survey monitoring** | 6-hourly district risk signals (weather + satellite + disease) fill the gap between annual SAS cycles |
| **Predictive loss forecasting** | Risk scores × production volumes = estimated MT at risk, 5–14 days ahead |
| **Survey calibration** | Cross-validate self-reported loss rates against sensor-derived risk signals |
| **Early outbreak detection** | Aggregated AI disease scan results reveal disease pressure building in specific districts before field surveyors arrive |
| **Storage gap mapping** | Real-time facility capacity data shows where infrastructure investment is needed most |

The **admin panel** (https://nisr-b06b6.web.app, login above) gives NISR analysts full access to district risk trends, historical data, and production figures sourced from their own SAS reports.

See **Section 15** of `DOCUMENTATION.md` for the full NISR integration architecture.

---

## 👥 Team

| Name | Role |
|------|------|
| RULINDANA SIMBI Honoré Tesny | Lead Developer & System Architect |
| IRAKIZA Moïse | UI/UX Designer & Frontend Engineer |
| ISHIMWERYAYO Jean Damour | Data Analyst & Agricultural Specialist |

---

## 📄 License

MIT License — Open source for agricultural development in Rwanda.

---

*© 2026 CropGuard AI — NISR Big Data Hackathon*
