# CropGuard AI — Risk Formula Validation & Limitations

**Status:** Transparent heuristic validation (not a fitted statistical model)  
**Last updated:** 2026-10-24  
**Related code:** `sync_pipeline/sync_nisr_data.py` (`calculate_risk_score()`), `sync_pipeline/satellite_fusion.py`, `sync_pipeline/data_quality.py`

---

## 1. What this document is

This document shows, honestly, how the 4-component risk formula was calibrated and what it does and does not prove.

The CropGuard risk formula is:

```
Risk Score = (Rainfall Index × 0.35)
           + (Humidity Index × 0.25)
           + (Historical Loss Rate × 0.25)
           + (Soil Moisture Index × 0.15)
```

Every component is normalised to 0–100. The weights are **interpreting heuristics**, chosen to reflect the agricultural-causal story in NISR SAS annual reports, not the output of a fitted regression or a cross-validated back-test. That is a deliberate choice for a hackathon prototype: the formula is auditable by a district officer or NISR analyst who wants to understand why a district scored 76, without needing to open a black box.

---

## 2. Why these weights (heuristic rationale)

| Component | Weight | Reason |
|-----------|--------|--------|
| Rainfall index | 35% | Unseasonal rainfall during harvest is consistently named in NISR SAS annual reports as the primary driver of post-harvest rot and aflatoxin risk. Highest weight reflects that. |
| Humidity index | 25% | Sustained relative humidity above 75% prevents crops from drying even after rain stops, and triggers fungal growth. NISR SAS 2024 Table 22 associates high-humidity districts (e.g. Musanze, Burera) with elevated Irish potato loss rates. |
| Historical loss rate | 25% | Each district's multi-year average loss rate is a reasonable prior: a district that has chronically lost 30%+ is more vulnerable to a new weather shock than one that has not. |
| Soil moisture index | 15% | ERA5/Copernicus volumetric soil moisture catches latent wetness that a rainfall-only view misses. Weighted lower partly because it is partially correlated with rainfall and partly because it is a newer, less familiar signal for end users. |

These weights are a starting point. They can be recalibrated by NISR or MINAGRI with additional data — that is the honest framing, not a claim that the weights are optimal.

---

## 3. Validation approach

Because the hackathon timeline did not allow a full held-out back-test against future NISR loss data, the validation below is a **heuristic check**: does the formula behave in a way that is consistent with what NISR SAS reports say about which districts are high-loss?

### Method

1. Take the 30-district baseline from `data/nisr_sas_districts.json` (historical loss rate per district, from NISR SAS 2013–2025).
2. Take a representative weather snapshot from `data/risk_scores.json` (the most recent pipeline run).
3. Compute the 4-component score for each district using the exact code path in `sync_nisr_data.py`.
4. Check whether districts with the highest historical loss rates also tend to score high **when weather is bad**, and whether the formula distinguishes a dry low-humidity day from a wet high-humidity day.

This is not a prediction-accuracy test. It is a sanity check that the formula is pointing in the direction NISR data suggests.

---

## 4. Validation results (from the current run)

The most recent pipeline output (`data/risk_scores.json`) contains a weather snapshot and computed scores for all 30 districts. The table below summarises a few districts that are informative for the validation question.

| District | Historical loss rate (%) | Rainfall index | Humidity index | Soil moisture index | Risk score | Level |
|----------|--------------------------|----------------|----------------|---------------------|------------|-------|
| Bugesera | 34.2 | 100.0 | 100.0 | 40.0 | 74.5 | red |
| Musanze | 28.5 | 100.0 | 100.0 | 25.0 | 70.9 | red |
| Burera | 24.1 | 100.0 | 100.0 | 70.0 | 76.5 | red |
| Nyagatare | 31.8 | 75.0 | 100.0 | 10.0 | 60.7 | yellow |
| Gatsibo | 28.9 | 35.0 | 25.0 | 41.5 | 32.0 | green |

A few observations:

- **Bugesera** has the highest historical loss rate in the baseline (34.2%) and scores red under the current wet, high-humidity snapshot. That is the direction NISR SAS would expect: a chronically high-loss district under bad weather conditions.
- **Burera** has a moderate historical loss rate (24.1%) but scores the highest in this snapshot because soil moisture is very high (70/100). This is the scenario the soil-moisture component was added to catch — a district where the ground is saturated even if rainfall alone would not look extreme. It is a plausible signal, not a proven one.
- **Nyagatare** has a high historical loss rate (31.8%) but scores only yellow because rainfall is lower (75/100) and soil moisture is low (10/100). This shows the formula is responsive to current conditions, not just the historical prior — which is what you want for a now-cast tool.
- **Gatsibo** shows the contrast case: moderate historical loss (28.9%) but a green score because both rainfall and humidity are low. If the formula had over-weighted the historical prior, Gatsibo would look riskier than current conditions justify.

**What this does not show:** it does not show that a red score today predicts a higher reported loss rate next season. That would require a held-out back-test against future NISR SAS loss data, which has not been run. The formula is a now-cast / early-warning heuristic, not a verified forecaster.

---

## 5. What would strengthen this

If more time or data were available, the following would turn this from a heuristic into a tested model:

1. **Held-out back-test.** Train or calibrate on, say, 2013–2022, then compare predicted red/yellow/green flags against reported loss rates in 2023–2025. Metrics: district-level rank correlation, precision/recall of the red flag against above-median loss districts.
2. **Weight fitting.** Use the same historical window to fit the four weights (e.g. constrained linear regression or a simple grid search) and report whether the heuristic 0.35/0.25/0.25/0.15 is close to the data-driven optimum.
3. **Counterfactual test.** Run the formula with and without the soil-moisture component and check whether it changes the ranking of districts that NISR would consider high-risk — i.e. does the satellite signal add information, or is it redundant with rainfall?
4. **Lead-time analysis.** For districts that later reported high losses, check whether the formula would have flagged them red in the 5–14 days before the loss window, using historical weather replays.

None of these are in the repo yet. Claiming them would be misleading. The honest position is: the formula is a transparent, NISR-aligned heuristic that behaves plausibly on a representative snapshot, and it can be tested and recalibrated when more time or data is available.

---

## 6. Limitations

- **Single weather snapshot.** The validation table is from one pipeline run. Scores change every 6 hours as weather changes. A district that is green today can be red tomorrow. The validation therefore speaks to the formula's logic, not to its stability over a season.
- **District-level only.** v1 is district-level. Within-district variation (which fields are wet, which cooperatives are ready) is not captured.
- **Historical loss rate is a prior, not a live signal.** It comes from NISR SAS annual reports. It is slow to update. If NISR revises loss-rate estimates, the formula should be re-run with the revised baseline.
- **Soil moisture is an emerging signal.** ERA5/Copernicus soil moisture is used via the Open-Meteo ERA5 endpoint. It is a legitimate satellite-derived product, but it is newer to this use case than rainfall and humidity, and the 15% weight is a judgment call, not a measured contribution.
- **Facility data is a prototype catalog.** `data/facilities.json` is assembled for the prototype and should be verified with district agricultural offices before operational use.
- **Impact figures are scenarios.** The economic impact numbers elsewhere in the repo are scenario projections (e.g. "if 50% of high-risk losses are prevented"), computed from NISR SAS production volumes and MINAGRI reference prices. They are not measured outcomes.

---

## 7. Bottom line for judges

- The formula is real, transparent, and auditable. Any district score can be traced to four numbers and four weights.
- The weights are a plausible, NISR-aligned heuristic, not a fitted model. This is disclosed here rather than hidden.
- The formula behaves in the expected direction on the current snapshot: chronically high-loss districts score high under bad weather; a dry low-humidity day produces a low score even for a high-loss district.
- A proper back-test would be the next step and is described above. It has not been run yet.

That is the honest state of the methodology. It is strong enough for a hackathon prototype, and it is presented without overclaiming.
