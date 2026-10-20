# CropGuard AI 🇷🇼

**Post-Harvest Risk Monitoring System for Rwanda**  
*NISR Big Data Hackathon 2026 — Track 1: Agricultural Productivity*

[![Live Demo](https://img.shields.io/badge/Live%20Demo-nisr--b06b6.web.app-brightgreen)](https://nisr-b06b6.web.app)
[![Flutter](https://img.shields.io/badge/Flutter-3.7%2B-blue)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Firestore%20%2B%20Hosting-orange)](https://firebase.google.com)

---

## 🎯 The Problem

In Rwanda, unseasonal rainfall during harvest periods causes devastating post-harvest losses:
- **20–35%** of crops lost to rot and aflatoxin contamination annually
- Smallholder farmers lack real-time weather + risk data
- Poor coordination between farmers and post-harvest storage facilities
- District planners have no centralized early-warning dashboard

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
| Mobile & Web App | Flutter 3.7+ (Android, iOS, Web) |
| Backend | Firebase Firestore + Hosting |
| Weather | Open-Meteo API (no key needed) |
| Data | NISR SAS 2013–2025 (12 years) |
| Maps | Flutter Map + ESRI Satellite Imagery |
| Location | Geolocator (GPS) |
| AI Scanner | Dart image analysis + DiseaseDatabase |
| Alerts | Africa's Talking SMS Gateway |
| CI/CD | GitHub Actions (6-hourly sync) |

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

| Source | Years | Usage |
|--------|-------|-------|
| NISR Seasonal Agricultural Survey (SAS) | 2013–2025 | District baselines, crop volumes, loss rates |
| Open-Meteo Weather API | Live | 14-day rainfall, humidity, temperature per district |
| ERA5/Copernicus Satellite | Live | Soil moisture volumetric data |
| Africa's Talking | Live | SMS/USSD alert delivery |

---

## 🔐 Admin Panel

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
git clone https://github.com/your-username/cropguard-rwanda.git
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
- **OpenAI** — default provider (highest accuracy, needs an `AI_API_KEY` dart-define)
- **Cloudflare** — free tier (~500 scans/day, no API key, no Google/OpenAI), real vision model via the proxy in `cloudflare_worker/`
- Switch at runtime: `flutter run --dart-define=AI_PROVIDER=cloudflare` (or `openai`)

## 📈 Impact Metrics

- **30 districts** monitored across all 5 provinces
- **21 facilities** cataloged (drying grounds, silos, cold storage, mobile dryers)
- **8 crops** with AI disease detection — 16 verified disease profiles (maize, beans, cassava, potato, banana, tomato, wheat & coffee)
- **12 years** of NISR SAS data integrated (2013–2025)
- **3 languages** — English, Kinyarwanda, French
- **6-hourly** automated risk score updates

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
