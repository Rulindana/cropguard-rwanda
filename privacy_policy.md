# Privacy Policy — CropGuard AI

**Effective date:** October 2026  
**Operator:** CropGuard AI (NISR 2026 Big Data Hackathon submission)  
**Contact:** [Insert operator contact email]

---

## 1. What this app is

CropGuard AI provides post-harvest risk information for Rwanda's 30
districts using NISR agricultural statistics, Open-Meteo weather forecasts,
and satellite-derived soil-moisture data. It is an early-warning tool, not
a consumer service.

## 2. Data we collect

### 2.1 Data we do NOT collect
- No account registration, names, or national IDs
- No location/GPS tracking
- No contacts, photos, or device files
- No advertising identifiers or analytics trackers

### 2.2 Opt-in SMS subscription data (only if you subscribe)
| Field | Purpose | Storage |
|---|---|---|
| Phone number | To send risk alerts you asked for | Firestore `/subscribers` or `data/subscribers.json` |
| Home district | To send alerts relevant to you | Same |
| Language (Kinyarwanda/English) | Alert language you chose | Same |
| Role (farmer/cooperative/planner) | Message tailoring | Same |

Subscription happens only when you actively submit the in-app form or are
registered by your cooperative with your consent.

### 2.3 Operational data (not about you)
District weather, soil moisture, risk scores, and facility records are
**non-personal** datasets derived from public statistics and open APIs.

## 3. How we use your data

- **Only** to send you the post-harvest risk alerts you subscribed to.
- Alerts are sent when a district's risk level escalates (yellow/red) —
  typically a few messages per harvest season, not daily spam.
- We do **not** sell, share, or use phone numbers for marketing.

## 4. SMS messaging terms

- Message frequency varies by risk conditions (rare; escalation-based).
- Reply **STOP** to opt out at any time (forward STOP to the sending
  number, or use the app's unsubscribe).
- Standard messaging rates from your mobile operator may apply.
- Alerts are advisory information, not an emergency-response guarantee.

## 5. Data retention & deletion

- Subscriber records are retained while you remain subscribed.
- On unsubscribe (STOP or in-app), the record is deleted at the next
  pipeline run or on request.
- Alert outbox logs are rotated and not linked to identity beyond the
  number that requested the alerts.
- Risk/analysis data contains no personal information.

## 6. Sharing

Data is shared only with:
- **Africa's Talking** (SMS delivery) — to transmit messages you requested;
- **Firebase/Google Cloud** (Firestore hosting) — as our database processor;
- Authorized operators (see PRD §8) for system maintenance.

We do not share with other third parties.

## 7. Children

The service targets adult farmers, cooperative leaders, and planners. We do
not knowingly collect data from children under 18.

## 8. Security

- Firestore security rules restrict access to subscriber records
  (`firestore_rules/firestore.rules`).
- Firebase service-account credentials are stored as GitHub Actions
  secrets, never in the repository.
- SMS gateway API keys are stored as environment secrets.

## 9. Your rights

You may at any time:
1. **Opt out** of SMS alerts (STOP or in-app unsubscribe);
2. **Request deletion** of your phone number from our records;
3. **Request a copy** of the data held about you.

Requests: [Insert contact email].

## 10. Changes to this policy

Material changes will be announced in-app or via SMS to active subscribers.

## 11. Open data & licensing

- Application code: MIT License (see `LICENSE`).
- Underlying statistics: NISR Seasonal Agricultural Survey (cited source).
- Weather data: Open-Meteo (open licence, no API key).
- Soil moisture: ERA5/Copernicus open data policy.
