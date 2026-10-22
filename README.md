# CropGuard AI 🇷🇼

**Post-Harvest Risk Monitoring System for Rwanda**  
*NISR Big Data Hackathon 2026 — Track 1: Agricultural Productivity*

[![Live Demo](https://img.shields.io/badge/Live%20Demo-nisr--b06b6.web.app-brightgreen)](https://nisr-b06b6.web.app)
[![Flutter](https://img.shields.io/badge/Flutter-3.7%2B-blue)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%2B%20Hosting-orange)](https://firebase.google.com)
[![CI/CD Pipeline](https://github.com/Rulindana/cropguard-rwanda/actions/workflows/sync_pipeline.yml/badge.svg)](https://github.com/Rulindana/cropguard-rwanda/actions/workflows/sync_pipeline.yml)

---

> **💡 Core Idea:**
> NISR spends enormous resources every year collecting agricultural data through the Seasonal Agricultural Survey — field visits, enumerators, data entry, analysis.
> That data ends up in a PDF report. Read once. Then filed away.
>
> **CropGuard AI changes that.**
> Instead of NISR working hard to produce data that sits unused, CropGuard puts NISR's own data to work — automatically, every 6 hours, across all 30 districts — predicting post-harvest losses **before they happen**, not documenting them after.
>
> *NISR already did the hard work. CropGuard makes it work for Rwanda.*

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

| National Priority | How CropGuard Contributes |
|---|---|
| **NST2 — Post-harvest loss reduction** | 30 districts get 6-hourly risk scores + actionable storage dispatch |
| **NST2 — Agricultural productivity** | Facility routing connects farmers to drying grounds & silos before rot sets in |
| **NST2 — Evidence-based planning** | District dashboards + policy brief for MINAGRI planners |
| **Vision 2050 — Digital transformation** | AI-powered multilingual mobile app (EN/RW/FR) |
| **Track 1 — Post-harvest collection & storage** | ✅ Core problem solved |
| **Track 1 — Soil conservation & fertility** | ✅ Satellite soil-moisture fusion component |
| **Track 1 — Processing, value addition & export** | ✅ Reduced aflatoxin = export-compliant produce |

---

## ✨ How It Works

```
[1. NISR SAS Data]     ──▶  [2. AI Processing]        ──▶  [3. What Users See]
  • 2013–2025 SAS data       • Risk Score Formula           • Interactive Rwanda Map
  • District baselines       • Weather Integration          • Post-Harvest Alerts
  • Historical loss rates    • AI Disease Scanner           • Storage Dispatch Plan
  • Facility catalog         • GPS Location Detection       • Crop Disease Results
```

### Risk Scoring Formula (satellite-fused)

```
Post-Harvest Risk Score = (Rainfall Index × 0.35) + (Humidity Index × 0.25)
                        + (Loss Rate Index × 0.25) + (Soil Moisture Index × 0.15)
```

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
