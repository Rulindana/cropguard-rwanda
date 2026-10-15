# CropGuard AI — v2 Innovation Plan

**Status:** In progress
**Scope principle:** each feature is real but lean — delivers the core user value without over-engineering.

## Features

### 1. Offline-first cache + stale-data badge
- New `lib/services/data_cache_service.dart`
- On first successful load, snapshot districts / facilities / summary to local JSON in the app's documents dir
- When offline or Firestore unavailable, serve the snapshot; show a per-screen "last refreshed Xh ago — tap to refresh" banner
- Extends the existing seed-from-JSON + fallback pattern; does not replace it

### 2. Per-crop drying-window advisory
- New model + widget on `district_detail_screen.dart`
- Translates district rainfall + humidity indices into per-crop "dry within X hours" guidance
- Covers maize, beans, Irish potatoes, cassava, and any other non-zero crops for the district
- Bilingual (Kinyarwanda / English / French) via the existing translations system

### 3. Booking / capacity reservation flow
- New `lib/models/booking_model.dart`
- New `lib/services/booking_service.dart`
- Reservation sheet on `dispatch_screen.dart`: pick a facility, pick a date window, confirm
- Decrements `available_capacity_tons` in Firestore for the facility; lists active reservations
- No payments, no calendar sync, no transaction reconciliation — a confirmed slot only

### 4. USSD reachability
- New USSD info screen reachable from the nav
- Shows the `*123#` menu text straight from `data/ussd_digest.json`
- One-tap note on how to try it; documented as demonstrable, not a provisioned shortcode
- Adds a nav item + translation strings

### 5. Historical trend + seasonality view
- Turns `assets/data/risk_history.json` into a real trend panel
- Shows recent 6-hourly risk points for a district
- Year-over-year comparison powered by `YearProvider`
- Rising / falling / stable signals on the panel

### 6. Data-grounded AI chatbot
- Wires the existing `widgets/chatbot.dart` to live CropGuard data
- Can answer: which districts are red, dispatch plan for X, risk score for Y, draft a policy brief line
- Kinyarwanda / English / French
- UI includes an honest scope note: planning assistant, not live emergency advice

## Sequencing

Build in this order so later work can reuse earlier work:

1. Cache service + offline banner (foundational)
2. Crop drying-window widget (reads from district model)
3. Booking flow (new model + service + dispatch UI)
4. Trend / seasonality panel (reuses `risk_history.json` + `YearProvider`)
5. USSD screen (reads existing digest)
6. Chatbot data layer (wires into the above)

## Files touched ( anticipated )

- `lib/services/data_cache_service.dart` (new)
- `lib/models/booking_model.dart` (new)
- `lib/services/booking_service.dart` (new)
- `lib/screens/district_detail_screen.dart` (crop advisory + offline badge)
- `lib/screens/dispatch_screen.dart` (booking sheet + offline badge)
- `lib/screens/dashboard_screen.dart` (offline badge)
- `lib/screens/facilities_list_screen.dart` (offline badge)
- `lib/screens/summary_screen.dart` (offline badge)
- `lib/screens/main_scaffold.dart` (USSD nav item + offline awareness)
- `lib/widgets/chatbot.dart` (data-aware replies)
- `lib/utils/translations.dart` (new strings for crop advisory, booking, USSD, trend)
- `assets/data/ussd_digest.json` (already exists)
- `assets/data/risk_history.json` (already exists)
