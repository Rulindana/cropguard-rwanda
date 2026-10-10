# CropGuard AI 🇷🇼

**Post-Harvest Risk Monitoring System for Rwanda**

CropGuard AI is a data-driven mobile application that protects smallholder farmers and agricultural planners against severe post-harvest losses caused by unseasonal rainfall, humidity spikes, and delayed collection logistics.

## 🎯 The Problem

In Rwanda, unseasonal rainfall during harvest periods causes significant post-harvest losses:
- **20-35%** of crops lost to rot and aflatoxin contamination
- Smallholder farmers lack real-time weather + risk data
- Limited coordination between farmers and storage facilities

## 🇷🇼 National Alignment: NST2 & Vision 2050

| National priority | How CropGuard contributes |
|---|---|
| **NST2 — Pillar 2: Economic transformation / agriculture** | Directly targets the **post-harvest loss reduction** indicator: every district gets a 6-hourly risk score with a concrete action (dry within 48h / emergency storage dispatch) |
| **NST2 — Agricultural productivity & market access** | Facility dispatch matching routes crops to drying grounds, silos, and cold storage before rot/aflatoxin sets in — protecting marketable surplus |
| **NST2 — Evidence-based planning** | District/province dashboards + exportable policy brief give planners and MINAGRI an operational picture, updated every 6 hours |
| **Vision 2050 — Pillar 5: Modernisation & prosperity** | A reusable, data-driven early-warning layer for a resilient national food system (open source, public-good tool) |
| **Track 1 hint: post-harvest collection & storage** | ✅ Core problem |
| **Track 1 hint: soil conservation & fertility** | ✅ Satellite soil-moisture fusion component |
| **Track 1 hint: processing, value addition & export** | ✅ Reduced aflatoxin/rot = higher-grade, export-compliant produce |

Full justification, personas, requirements, and maintenance ownership: see [`PRD.md`](PRD.md).

## ✨ How It Works

```
[1. NISR SAS Data] ──> [2. Smart Processing] ──> [3. What Users See]
  • District baselines    • Risk Score Formula     • Interactive Rwanda Map
  • Historical loss rates • Weather Integration     • Post-Harvest Alerts
  • Facility counts       • Facility Routing        • Storage Dispatch Advice
```

### Risk Scoring Formula (satellite-fused)

```
Post-Harvest Risk Score = (Rainfall Index × 0.35) + (Humidity Index × 0.25)
                        + (Loss Rate × 0.25) + (Soil Moisture Index × 0.15)
```

| Risk Level | Score Range | Action |
|------------|-------------|--------|
| 🟢 Green   | 0-39%       | Safe harvesting conditions |
| 🟡 Yellow  | 40-69%      | Drying equipment needed within 48h |
| 🔴 Red     | 70-100%     | Emergency storage dispatch required |

## 📱 Features

### For District Agricultural Planners
- **Interactive Map**: Color-coded Rwanda map showing real-time risk levels for all 30 districts
- **District Details**: Click any district to see harvest volumes, weather forecasts, and risk breakdown
- **National Overview**: Summary dashboard with nationwide risk distribution and policy recommendations
- **NST2 Alignment**: Recommendations tied to Rwanda's National Strategy for Transformation

### For Extension Officers & Cooperative Leaders
- **Facility Locator**: Find nearest drying grounds, silos, cold storage, and mobile dryers
- **Contact Details**: Direct phone and email for facility managers
- **Capacity Tracking**: See available vs. total capacity at each facility
- **Actionable Alerts**: Clear advisory messages based on risk level

## 🏆 Top Innovations

### 🥇 SMS/USSD Alerts — inclusivity beyond the smartphone
- Bilingual (**Kinyarwanda + English**) risk alerts sent by SMS whenever a district
  escalates to 🟡 or 🔴 — works on **any phone, no internet required**
- Anti-spam: alerts fire on risk-level *changes*, not every 6-hourly run
- Africa's Talking gateway with automatic dry-run outbox fallback
  (`data/alerts_outbox.json`) so the flow is always demonstrable
- USSD digest (`data/ussd_digest.json`) ready to publish behind a `*123#` menu
- In-app opt-in: *Subscribe to SMS risk alerts* on every district detail page
- Modules: `sync_pipeline/sms_alerts.py`, `lib/services/alert_subscription_service.dart`

### 🥈 Facility Dispatch Matching — turning insight into last-mile action
- Every district gets a ranked **dispatch plan**: top-3 nearest facilities with
  free capacity, estimated travel time, capacity headroom, and a
  distance/capacity composite match score
- Priority tagging: `emergency` (red) / `recommended` (yellow) / `available` (green)
- App side: *Find nearest storage NOW* button opens the dispatch screen with
  one-tap call and reservation email to the facility manager
- Modules: `sync_pipeline/dispatch_matcher.py`, `lib/services/dispatch_service.dart`,
  `lib/screens/dispatch_screen.dart`

### 🥉 Satellite Data Fusion — deeper methodology
- 4th risk component: **volumetric soil moisture** from the ERA5/Copernicus
  land-surface model (satellite-derived) fetched from Open-Meteo
- Wet soil at harvest = wet crops in storage — catches rot risk that
  rainfall-only models under-estimate; rainfall-derived fallback keeps the
  pipeline resilient when the API is unavailable
- Module: `sync_pipeline/satellite_fusion.py`

## 🛠 Tech Stack

| Component | Technology |
|-----------|------------|
| Mobile App | Flutter (Android, iOS, Web) |
| Backend | Firebase (Firestore, Auth) |
| Weather API | Open-Meteo (no API key required) |
| Data Source | NISR Seasonal Agricultural Survey (SAS) |
| Maps | Flutter Map + OpenStreetMap tiles |
| CI/CD | GitHub Actions (daily data sync) |

## 📁 Project Structure

```
cropguard-rwanda/
├── flutter_app/             # Flutter mobile application
│   └── cropguard_app/
│       ├── lib/
│       │   ├── models/      # Data models (District, Facility, Summary)
│       │   ├── screens/     # UI screens (Home, Detail, Summary, Facilities)
│       │   ├── services/    # Firebase/Firestore services
│       │   ├── widgets/     # Reusable UI components
│       │   └── utils/       # Utilities, formatters, seed data
│       └── pubspec.yaml
│
├── sync_pipeline/          # Python data sync pipeline
│   ├── sync_nisr_data.py   # Main pipeline script
│   ├── satellite_fusion.py # 🥉 Satellite/soil-moisture fusion layer
│   ├── dispatch_matcher.py # 🥈 Facility dispatch ranking
│   ├── sms_alerts.py       # 🥇 SMS/USSD bilingual alerts
│   └── requirements.txt    # Python dependencies
│
├── data/                   # Mock and processed data
│   ├── nisr_sas_districts.json   # NISR baseline data (30 districts)
│   ├── facilities.json           # Post-harvest facility catalog
│   ├── subscribers.json          # SMS alert subscribers (sample)
│   └── risk_scores.json         # Generated risk scores (output)
│
├── firestore_rules/        # Firestore security rules
└── .github/workflows/      # GitHub Actions cron jobs
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7+)
- Firebase project with Firestore enabled
- Python 3.11+ (for sync pipeline)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/cropguard-rwanda.git
   cd cropguard-rwanda
   ```

2. **Set up Firebase**
   ```bash
   cd flutter_app/cropguard_app
   flutter pub get
   # Download google-services.json from Firebase Console
   # Place in android/app/ and ios/Runner/
   flutterfire configure
   ```

3. **Seed initial data to Firestore**
   - Place NISR data in `assets/data/`
   - Run the seed utility or use the Python pipeline

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Set up automated data sync** (optional)
   - Configure GitHub Actions secrets for Firebase credentials
   - The workflow runs every 6 hours to fetch fresh weather data

## 📊 Data Sources

### NISR Seasonal Agricultural Survey (SAS)
- Source: [statistics.gov.rw/data-sources/surveys/Seasonal-Agricultural-Survey](https://statistics.gov.rw/data-sources/surveys/Seasonal-Agricultural-Survey)
- Data: District-level crop production, historical loss rates, cooperative coverage

### Open-Meteo Weather API
- Source: [open-meteo.com](https://open-meteo.com)
- Data: 14-day forecasts for rainfall, humidity, temperature
- No API key required

### Facilities Data
- Mock dataset included for demonstration
- In production: connect to agricultural registry or cooperative database

## 🔄 Automated Data Sync Pipeline

The Python pipeline (`sync_pipeline/sync_nisr_data.py`) automates:

1. **Fetch NISR Data**: Load district baseline statistics
2. **Fetch Weather + Satellite Soil Moisture**: Open-Meteo 14-day forecasts
   and ERA5 land-surface soil moisture per district
3. **Calculate Fused Risk**: Apply the weighted 4-component formula
4. **Match Facilities**: Rank nearest facilities with free capacity (dispatch plan)
5. **Push to Firestore + Send Alerts**: Update the database and dispatch
   bilingual SMS/USSD alerts on risk-level changes
6. **Schedule**: GitHub Actions cron runs every 6 hours

```
NISR Portal → Python Pipeline → Firestore → Flutter App
     ↓              ↓              ↓           ↓
  Weekly update  Live weather  Auto-sync   Real-time alerts
```

## 📈 Impact Metrics

- **30 districts** covered across all 5 provinces
- **21 facilities** cataloged (drying grounds, silos, cold storage, mobile dryers)
- **4 crop types** tracked (maize, beans, Irish potatoes, cassava)
- **Real-time** risk scores updated every 6 hours

## 📄 License

MIT License - Open source for agricultural development in Rwanda.

---

**Built for Rwanda Agricultural Development**
# cropguard-rwanda
