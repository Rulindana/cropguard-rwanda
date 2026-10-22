# CropGuard AI — Full Project Documentation

**NISR Big Data Hackathon 2026**  
**Track 1: Agricultural Productivity**  
**Team:** RULINDANA SIMBI Honoré Tesny · IRAKIZA Moïse · ISHIMWERYAYO Jean Damour  
**Live App:** https://nisr-b06b6.web.app  
**GitHub:** https://github.com/rulindana/cropguard-rwanda  

---

## TABLE OF CONTENTS

1. Executive Summary
2. Problem Statement
3. Solution Overview
4. How It Works — Technical Architecture
5. Data Sources & Methodology
6. Key Features (Detailed)
7. AI Crop Disease Scanner
8. Risk Scoring Formula
9. Tech Stack
10. National Alignment (NST2 / Vision 2050)
11. Impact & Results
12. Team
13. How to Use the App
14. Questions & Answers (Q&A)

---

## 1. EXECUTIVE SUMMARY

CropGuard AI is a multilingual mobile and web application that uses real agricultural data, satellite weather forecasts, and artificial intelligence to help Rwanda's farmers and district planners prevent post-harvest crop losses before they happen.

The system monitors all 30 districts of Rwanda in real time, calculates risk scores every 6 hours, and tells farmers and agricultural officers exactly what to do — where to take their crops for storage, which storage facilities have space, and how to identify plant diseases using their phone camera.

**In one sentence:** CropGuard AI turns Rwanda's NISR data into life-saving, real-time agricultural decisions that protect farmers' income and food security.

---

## 2. PROBLEM STATEMENT

### The Challenge

Rwanda loses **20–35% of crop production** every year to post-harvest damage. The main causes are:

- **Unseasonal rainfall** during harvest soaks crops before they can dry
- **High humidity** causes mold, rot, and aflatoxin contamination
- **Delayed storage dispatch** — farmers don't know which facilities have space
- **Plant diseases** go undetected until entire fields are destroyed
- **District planners have no unified dashboard** — decisions are made too slowly

### Who Is Affected

- **Smallholder farmers** (over 80% of Rwanda's agricultural workforce)
- **Cooperative managers** who coordinate post-harvest logistics
- **District agricultural officers** who need to deploy resources fast
- **MINAGRI and NISR policymakers** who plan interventions at national scale

### Why This Matters for NST2

Rwanda's National Strategy for Transformation (NST2) sets explicit targets for reducing post-harvest losses as part of the agricultural productivity pillar. Every kilogram saved from rot is a kilogram that can reach markets — or feed a family.

---

## 3. SOLUTION OVERVIEW

CropGuard AI is a three-layer system:

```
Layer 1 — DATA         Layer 2 — INTELLIGENCE        Layer 3 — ACTION
───────────────────    ─────────────────────────────  ──────────────────────
NISR SAS 2013–2025  →  Risk Score Formula          →  District Risk Map
Open-Meteo Weather  →  Satellite Soil Fusion       →  Post-Harvest Alerts
ERA5 Satellite Data →  AI Disease Detection        →  Storage Dispatch Plan
Facility Registry   →  GPS Location Matching       →  Bilingual SMS Alerts
```

### What Makes It Different

| Feature | Other Apps | CropGuard AI |
|---------|-----------|--------------|
| Data source | Generic | NISR SAS (Rwanda-specific, 2013–2025) |
| Languages | English only | English + Kinyarwanda + French |
| Disease detection | None | AI scanner (16 verified disease profiles, 8 crops) |
| Storage routing | None | Ranked dispatch with travel time |
| Offline alerts | None | SMS/USSD — works without internet |
| Location | Hardcoded | Real GPS — your actual district |

---

## 4. HOW IT WORKS — TECHNICAL ARCHITECTURE

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     DATA SOURCES                            │
│  NISR SAS 2013-2025 │ Open-Meteo API │ ERA5 Satellite       │
└──────────────┬───────────────┬────────────────┬─────────────┘
               │               │                │
               ▼               ▼                ▼
┌─────────────────────────────────────────────────────────────┐
│                  PYTHON SYNC PIPELINE                       │
│  sync_nisr_data.py → satellite_fusion.py → dispatch_matcher │
│         ↓                    ↓                    ↓         │
│    Risk Scores          Soil Moisture         Ranked         │
│    (30 districts)       (ERA5/Copernicus)     Facilities     │
│                    sms_alerts.py                            │
│                    (Bilingual alerts)                        │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    FIREBASE FIRESTORE                       │
│         Real-time database — auto-synced every 6 hours      │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER APP                              │
│   Android │ iOS │ Web — EN/RW/FR — Dark/Light Mode          │
│   Dashboard │ Map │ Disease Scanner │ Facilities │ Alerts    │
└─────────────────────────────────────────────────────────────┘
```

### Automated Pipeline (GitHub Actions)

The system runs automatically every 6 hours:
1. Fetches latest weather data from Open-Meteo for all 30 district centroids
2. Fetches satellite soil moisture from ERA5/Copernicus land-surface model
3. Applies the 4-component risk formula to calculate each district's score
4. Ranks nearest storage facilities by capacity + distance
5. Pushes updated scores to Firebase Firestore
6. Sends bilingual SMS/USSD alerts for districts that changed risk level

---

## 5. DATA SOURCES & METHODOLOGY

### NISR Seasonal Agricultural Survey (SAS) — 12 Years of Data

We integrated **12 years** of NISR SAS data (2013–2025):

| Year | Data Used |
|------|-----------|
| 2013 | Historical baseline loss rates per district |
| 2014–2018 | Trend analysis, crop production volumes |
| 2019–2022 | Post-harvest infrastructure mapping |
| 2023–2024 | Current district crop baselines |
| 2025 | Most recent annual tables and summary |

**Specific metrics extracted from NISR SAS:**
- District-level maize, beans, cassava, and Irish potato production (tons)
- Historical post-harvest loss rates per district (%)
- Cooperative and storage facility coverage
- Seasonal rainfall patterns by district

### Open-Meteo Weather API

- **Free, no API key required** — ideal for open-source projects
- 14-day forecast: rainfall (mm), humidity (%), wind speed, temperature
- Fetched per district centroid coordinates (latitude/longitude)
- Updated every 6 hours by the automated pipeline

### ERA5/Copernicus Satellite (Soil Moisture)

- Volumetric soil moisture from the ERA5 land-surface model
- Wet soil during harvest = higher post-harvest rot risk
- This 4th component catches risk that rainfall-only models miss
- Accessed via Open-Meteo's ERA5 endpoint (no additional API key)

### Why This Data Combination Is Strong

A district might have moderate rainfall but very high soil moisture from previous weeks — meaning crops stored immediately after harvest will absorb moisture from the ground. Our satellite fusion catches this scenario that weather-only systems miss.

---

## 6. KEY FEATURES (DETAILED)

### Feature 1: Real-Time Risk Dashboard

The main screen shows a live Rwanda map where every district is colored:
- 🟢 **Green** = Low risk (0–39%) — safe conditions
- 🟡 **Yellow** = Moderate risk (40–69%) — drying needed within 48 hours
- 🔴 **Red** = High risk (70–100%) — emergency storage dispatch required

Clicking any district shows:
- Expected harvest volume (tons) — from NISR SAS data
- 14-day weather forecast
- Detailed risk breakdown (rainfall, humidity, soil moisture, historical loss)
- Specific advisory action
- Risk trend (rising / falling / stable vs. previous run)

### Feature 2: AI Plant Disease Scanner

A farmer takes a photo of a sick plant leaf. The system:
1. **Validates** the image is actually a plant (rejects books, documents, etc.)
2. **Analyzes** the image using the disease pattern database
3. **Identifies** the disease from 16 verified disease profiles across 8 crops
4. **Shows** full treatment steps, prevention tips, and confidence score
5. **Suggests** alternative diagnoses with lower confidence

Supported crops: Maize, Beans, Cassava, Potato, Banana, Tomato, Wheat, Coffee

### Feature 3: Storage Facility Dispatch

When a district is at high risk, the app shows:
- Ranked list of nearest storage facilities
- Available capacity (tons)
- Estimated travel time (minutes)
- Match score (distance + capacity composite)
- One-tap call or email to the facility manager

### Feature 4: SMS/USSD Alerts (No Internet Required)

- Farmers subscribe with their phone number (any network)
- When a district escalates to yellow or red, an SMS is sent automatically
- Available in **Kinyarwanda** and **English**
- USSD digest ready for `*123#` menu deployment
- Works on the most basic feature phone

### Feature 5: GPS-Based Location

- The app asks for location permission once
- Automatically detects which district the user is in
- Shows weather for THEIR actual location, not a hardcoded city
- Finds nearest storage facilities using real GPS coordinates

### Feature 6: Full Multilingual Support (EN / RW / FR)

Every single text in the app is translated:
- English, Kinyarwanda, French
- Language switch button visible at all times (EN / RW / FR)
- Tips, alerts, disease names, scan steps — all 3 languages
- No hardcoded English text remaining

---

## 7. AI CROP DISEASE SCANNER — DEEP DIVE

### How the Scanner Works

**Step 1 — Image Capture**
The user taps "Take Photo" or "Upload Photo." The app requests camera/gallery permission only on first use — it remembers the answer permanently.

**Step 2 — Plant Validation**
Before running disease detection, the system analyzes the image at the pixel level:
- Decodes the image into RGB pixel values
- Counts pixels where green is the dominant channel (plant-like)
- Also counts brown/yellow-green pixels (dried leaves, stems, earth)
- If less than 18% of pixels match plant characteristics → **rejected with explanation**
- This prevents the system from diagnosing diseases in photos of books, people, or random objects

**Step 3 — Disease Matching**
The validated image (as base64) is sent — together with our disease database — to a real cloud vision model (OpenAI), which returns a structured JSON diagnosis: the matched disease id, a genuine confidence score, up to two alternative matches, and a short observation in the user's language. The result is mapped back to our local database so symptoms, treatment and prevention always come from reviewed Rwanda-specific agronomy content. This step requires an API key (see README) and an internet connection; if either is missing, the app shows an honest error dialog instead of a fabricated result.

**Step 4 — Results Display**
The result screen shows:
- Disease name (English + scientific name)
- Crop type affected
- Severity level (Low / Moderate / High / Critical)
- AI Confidence score (%)
- List of observed symptoms
- Causes
- Step-by-step treatment instructions
- Prevention tips
- 2 alternative diagnoses with lower confidence

### Disease Database Coverage

| Crop | Diseases |
|------|---------|
| Maize | Gray Leaf Spot, Northern Corn Leaf Blight, Fall Armyworm |
| Beans | Angular Leaf Spot, Bean Common Mosaic Virus, Bean Rust |
| Cassava | Cassava Mosaic Disease, Cassava Brown Streak Disease |
| Irish Potato | Late Blight, Early Blight |
| Banana | Banana Xanthomonas Wilt |
| Tomato | Tomato Early Blight, Bacterial Wilt |
| Wheat/Sorghum | Wheat Stem Rust (Ug99) |
| Coffee | Coffee Leaf Rust |

All diseases are **Rwanda-specific** — chosen because they are the actual threats facing farmers in Rwanda's highland and lowland regions.

---

## 8. RISK SCORING FORMULA

### The Formula

```
Risk Score (%) = (Rainfall Index × 0.35)
              + (Humidity Index × 0.25)
              + (Historical Loss Rate × 0.25)
              + (Soil Moisture Index × 0.15)
```

### Why These Weights?

| Component | Weight | Reason |
|-----------|--------|--------|
| Rainfall Index | 35% | Highest weight — direct cause of post-harvest rot |
| Humidity Index | 25% | Sustained humidity prevents drying even after rain stops |
| Historical Loss Rate | 25% | Districts with chronic losses are at higher baseline risk |
| Soil Moisture | 15% | Satellite-derived — catches latent wetness not visible in weather data |

### Index Calculation

Each raw measurement is normalized to a 0–100 index:
- **Rainfall Index**: 14-day total mm scaled against district historical maximum
- **Humidity Index**: max 14-day relative humidity % scaled to 0–100
- **Loss Rate Index**: NISR historical loss rate × 100
- **Soil Moisture Index**: ERA5 volumetric soil moisture scaled to 0–100

---

## 9. TECH STACK

### Mobile & Web Application

| Technology | Version | Purpose |
|------------|---------|---------|
| Flutter | 3.7+ | Cross-platform UI (Android, iOS, Web) |
| Dart | 3.x | Programming language |
| Provider | 6.1.2 | State management (language, theme) |
| Flutter Map | 7.0.2 | Interactive Rwanda map with district polygons |
| FL Chart | 0.68.0 | Harvest volume bar charts, risk trend sparklines |
| Geolocator | 13.0.1 | Real GPS location detection |
| Image Picker | 1.1.2 | Camera and gallery access for disease scanner |
| Shared Preferences | 2.3.2 | Persistent language, theme, permission memory |

### Backend & Infrastructure

| Technology | Purpose |
|------------|---------|
| Firebase Firestore | Real-time NoSQL database for district risk scores |
| Firebase Hosting | Web app deployment (https://nisr-b06b6.web.app) |
| Firebase Auth | Admin login for data management |
| GitHub Actions | Automated 6-hourly data sync pipeline |

### Data & AI Pipeline

| Technology | Purpose |
|------------|---------|
| Python 3.11 | Data processing pipeline |
| Open-Meteo API | Weather forecasts (free, no key) |
| ERA5/Copernicus | Satellite soil moisture data |
| Africa's Talking | SMS/USSD delivery gateway |

### Map & Imagery

| Technology | Purpose |
|------------|---------|
| ESRI World Imagery | Satellite base map tiles (free, no API key) |
| Rwanda GeoJSON | District boundary polygons (simplified for mobile) |
| OpenStreetMap | Alternative tile layer |

---

## 10. NATIONAL ALIGNMENT

### NST2 (National Strategy for Transformation 2017–2024/2050)

CropGuard AI directly addresses NST2 Pillar 2: **Economic Transformation through Agriculture**:

**Target: Reduce post-harvest losses**
- CropGuard provides early warning 6 hours before conditions become critical
- Storage dispatch matching reduces the time crops spend unsecured after harvest

**Target: Increase agricultural productivity**
- Disease scanner helps farmers identify and treat crop diseases early
- Prevents yield loss from untreated plant diseases

**Target: Evidence-based planning**
- National dashboard gives MINAGRI and district officers real-time data
- Policy brief generation for district-level planning

**Target: Digital innovation in agriculture**
- Multilingual app accessible to all Rwandans
- SMS alerts reach farmers without smartphones

### Vision 2050 Alignment

- **Digital Rwanda**: Mobile-first, GPS-enabled agricultural technology
- **Prosperous Rwanda**: Protecting farmers' income by preventing post-harvest losses
- **Knowledge Economy**: NISR data transformed into actionable intelligence

### Hackathon Evaluation Criteria — Self Assessment

| Criterion | Score (our estimate) | Evidence |
|-----------|---------------------|---------|
| Problem Understanding & Relevance | 18–20/20 | NST2 post-harvest loss target directly addressed; NISR SAS data used |
| Data Use & Methodology | 18–20/20 | 12 years NISR SAS, ERA5 satellite, Open-Meteo, 4-component risk formula |
| Tech Innovation | 17–20/20 | AI disease scanner with plant validation, satellite fusion, SMS/USSD, GPS |
| Usability & Design | 17–20/20 | Flutter app, 3 languages, dark/light mode, maps, animations |
| Tangible Impact | 18–20/20 | 30 districts, 21 facilities, 8 crops, 6-hourly updates, works offline |

---

## 11. IMPACT & RESULTS

### Coverage

- **30 districts** monitored across all 5 provinces (Northern, Southern, Eastern, Western, Kigali City)
- **21 storage and drying facilities** cataloged with GPS coordinates
- **8 crops** with AI disease detection
- **16 plant diseases** in the detection database
- **12 years** of NISR SAS data integrated (2013–2025)

### Accessibility

- Available in **3 languages**: English, Kinyarwanda, French
- **SMS/USSD alerts** work on any phone without internet
- **Web app** accessible from any browser
- **Android APK** for smartphone users

### Real-World Use Cases

**Scenario 1 — District Agricultural Officer in Burera:**
Opens the app in the morning. Sees Burera is at 77% risk (red). Taps the red button, sees 3 nearby facilities with available storage. Calls the closest one, dispatches cooperative members immediately. Crop saved.

**Scenario 2 — Farmer in Nyamagabe:**
Notices yellow spots on bean leaves. Opens CropGuard AI, taps Scan. Takes a photo. The AI says "Angular Leaf Spot, 84% confidence." Follows the step-by-step treatment. Treats the field within 24 hours instead of waiting for an extension officer.

**Scenario 3 — MINAGRI Planner:**
Opens the web dashboard. Sees 8 districts are at red level simultaneously due to a national weather event. Shares the risk map with provincial governors. Deploys mobile drying units to the highest-risk areas. Issues national advisory.

---

## 12. TEAM

### RULINDANA SIMBI Honoré Tesny — Lead Developer & System Architect
- Built the full Flutter mobile and web application
- Designed the system architecture and Firebase integration
- Implemented the Python data pipeline and GitHub Actions automation
- Developed the AI disease scanner and plant validation system

### IRAKIZA Moïse — UI/UX Designer & Frontend Engineer
- Designed the user interface and visual design system
- Created the color scheme, typography, and component library
- Conducted user research and prototyping
- Implemented responsive layouts for mobile and desktop

### ISHIMWERYAYO Jean Damour — Data Analyst & Agricultural Specialist
- Analyzed 12 years of NISR SAS data to extract district baselines
- Designed the risk scoring formula and weights
- Identified Rwanda-specific plant diseases for the scanner database
- Validated agricultural data accuracy and relevance

---

## 13. HOW TO USE THE APP

### Web Version
1. Open **https://nisr-b06b6.web.app** in any browser
2. The map loads automatically with all 30 districts
3. Click any district to see risk details and dispatch options

### Android App
1. **Download the APK** from GitHub Releases (https://github.com/Rulindana/cropguard-rwanda/releases) and install it, or build it yourself:`
   ````bash
   flutter build apk --release   # output: flutter_app/cropguard_app/build/app/outputs/flutter-apk/app-release.apk
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```
2. Allow location permission when asked (only asked once)
3. The app will show your current district's weather automatically

### Key Actions

**Check district risk:**
→ Dashboard tab → tap any district on the map → see details and advisory

**Find storage:**
→ Tap a red district → tap "Find nearest storage NOW" → call facility manager

**Scan a plant:**
→ Tap "Gusuzuma" (Scan) tab → Take Photo or Upload → tap Analyze

**Change language:**
→ Tap EN / RW / FR button at the top of any screen

**Get SMS alerts:**
→ Tap any district → scroll down → tap "Subscribe to SMS alerts"

---

## 14. QUESTIONS & ANSWERS (Q&A)

*This section prepares you for common questions during the hackathon presentation.*

---

**Q: What data did you use from NISR?**

A: We used the Seasonal Agricultural Survey (SAS) data from 2013 to 2025 — that's 12 years of data. From this data, we extracted district-level crop production volumes for maize, beans, cassava, and Irish potato. We also extracted historical post-harvest loss rates per district, which form one of the four components of our risk scoring formula. The NISR data is the foundation — everything else (weather, satellite, location) builds on top of it.

---

**Q: How does the AI disease scanner work?**

A: The scanner uses a real cloud AI vision model (OpenAI). Your photo is sent to the model together with our database of 16 verified disease profiles across 8 crops, and the model returns the matched disease with a calibrated confidence percentage, alternative diagnoses, and a short observation in your language — all mapped back to locally reviewed profiles with symptoms, causes, treatment steps and prevention tips written for Rwanda's agricultural context. A pixel-level pre-filter runs on-device first, so photos of books or faces are rejected without spending an API call.

---

**Q: Is this AI really accurate?**

A: The scanner calls a real cloud vision model (OpenAI) — the photo, the disease vocabulary and a strict JSON schema go to the model, and it returns the matched disease id, a calibrated confidence and alternatives; we reject any answer that doesn't map to our reviewed database. This requires an internet connection and an API key, and the app shows explicit errors when either is missing rather than inventing a result. The pre-filter (pixel-level green ratio analysis) runs on-device and works accurately for distinguishing plant vs. non-plant images. The risk-score pipeline is intentionally a transparent weighted formula over live weather/satellite/statistical data — auditable by design rather than a black box.

---

**Q: What happens if there is no internet connection?**

A: The app has a two-layer data strategy. First, it loads district data from a local JSON file bundled with the app — this works completely offline. Then, in the background, it tries to fetch fresh data from Firebase. If Firebase is unavailable, the app continues working with local data and shows an offline indicator. For SMS alerts, those are delivered by Africa's Talking SMS gateway which works on any mobile network without internet.

---

**Q: How is the risk score calculated?**

A: We use a weighted formula with four components: Rainfall Index (35%), Humidity Index (25%), Historical Loss Rate from NISR (25%), and Satellite Soil Moisture from ERA5 Copernicus (15%). Each component is normalized to a 0–100 scale and multiplied by its weight. The weights were determined based on agricultural research — rainfall is the primary driver of post-harvest rot, so it has the highest weight. The satellite soil moisture component is unique to our system — it catches latent wetness in the ground that weather forecasts alone don't show.

---

**Q: Why did you choose Flutter?**

A: Flutter allows us to write one codebase that runs on Android, iOS, and web — which is essential for reaching as many users as possible. It also has excellent support for maps, charts, and animations. The app runs on the web (https://nisr-b06b6.web.app), on Android phones, and can be compiled for iOS as well — all from the same code.

---

**Q: How does the multilingual support work?**

A: We have a central translations file (`lib/utils/translations.dart`) that contains every single text string in the app in all three languages — English, Kinyarwanda, and French. When the user taps EN/RW/FR, the language provider notifies all widgets to rebuild with the new language. There are no hardcoded English strings anywhere in the app. This was a significant effort — over 200 translation keys covering every screen, button, alert, and tip.

---

**Q: How does the GPS location work?**

A: The app requests location permission from the phone once when the user opens the scan or dashboard screen. After permission is granted, it reads the GPS coordinates and calculates the distance to the centroid of each of the 30 districts. The district with the smallest distance is selected as "your district" and its weather is shown. The permission answer is remembered permanently so the app never asks again.

---

**Q: How do the SMS alerts work?**

A: Users subscribe to alerts for their district by entering their phone number in the app. When the pipeline runs every 6 hours and detects that a district's risk level has changed (for example from green to yellow, or yellow to red), it sends an SMS to all subscribers in that district using the Africa's Talking gateway. The message is sent in both Kinyarwanda and English. The USSD interface (`*123#`) is also designed for farmers without smartphones.

---

**Q: What is your GitHub repository structure?**

A: The repository has four main parts: the Flutter app in `flutter_app/cropguard_app/`, the Python data pipeline in `sync_pipeline/`, the NISR source data in `datas/` (organized by year from 2013 to 2025), and processed output data in `data/`. The GitHub Actions workflow in `.github/workflows/` automates the 6-hourly data sync.

---

**Q: How does the storage dispatch matching work?**

A: The dispatch service calculates the straight-line distance from the district centroid to each storage facility in our database. It then ranks facilities by a composite score that considers both distance (shorter is better) and available capacity (more space is better). The top 3 ranked facilities are shown with their contact details, estimated travel time, and capacity breakdown. The facility manager can be called or emailed directly from the app.

---

**Q: What would you add with more time?**

A: Three main improvements:
1. An on-device (offline) disease classification model — bundling a lightweight TFLite classifier so scans keep working without connectivity, complementing the current cloud vision model
2. Farmer registration system so individual farmers can track their specific plots over time
3. Market price integration — connecting farmers to buyers when they're ready to sell after successful storage

---

**Q: How does this help Rwanda specifically?**

A: Everything in the system is calibrated for Rwanda. The 30 districts are Rwanda's actual administrative districts. The 12 years of NISR data reflect Rwanda's actual crop production patterns. The 16 verified disease profiles in the scanner are the diseases actually present in Rwanda's highland and lowland farming regions — from Fall Armyworm that arrived in Rwanda in 2017 to Coffee Leaf Rust threatening Rwanda's premium Arabica exports. The SMS alerts are in Kinyarwanda. The facility database covers Rwanda's actual drying grounds, silos, and cold storage centers.

---

**Q: What is your team's division of work?**

A: Honoré Tesny built the full application code — Flutter app, Firebase backend, Python pipeline, and GitHub automation. Moïse designed the visual interface, color system, and user experience. Jean Damour analyzed the NISR SAS data, designed the risk formula weights, and identified the Rwanda-specific disease database. All three worked together on validating the agricultural logic and testing the application.

---

**Q: Did you use AI tools to help build this?**

A: Yes — we used AI coding assistants to help write and debug code, which is allowed by the hackathon rules. All submitted work is our own original solution, and we take full responsibility for its accuracy, design decisions, and functionality. The use of AI tools is fully disclosed as required.

---

*End of Document*

---

**CropGuard AI — Protecting Rwanda's Harvest**  
*NISR Big Data Hackathon 2026*  
*Live: https://nisr-b06b6.web.app*
