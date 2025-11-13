## Unit 2 — Team Flights Classification (BigQuery ML)
## Overview

This project was developed as part of Assignment 2: Predictive Modeling at Scale with BigQuery ML (BQML) in MGMT 467 – AI-Assisted Big Data Analytics.
Our goal was to build, evaluate, and operationalize machine learning models predicting flight delays and diversions in U.S. domestic air traffic, using the BigQuery public dataset bigquery-public-data.faa.us_flights.

The analysis focused on translating ML outcomes into operational decision policies for airline resource planning — ensuring staff, gates, and logistics are pre-staged effectively while minimizing false alarms.

## Business Questions

Q1. Regression (arr_delay):
Can we estimate arrival delay minutes from operational signals to improve resource and gate planning?

Q2. Classification (diverted):
Can we classify the probability that a flight will be diverted, to better anticipate disruptions and prepare mitigation plans?

## Modeling Approach
Model A — Pre-Departure Baseline (Global)
Goal: Early prediction using schedule-level data only.
Features: carrier, route (origin-dest), distance, day_of_week, month/season.
Model: LOGISTIC_REG
Key Metrics: ROC AUC, log_loss, confusion matrix @0.5
Insight: Establishes baseline predictive power without operational delay signals.

Model B — Day-of-Operations Uplift (Engineered)
Goal: Add real-time operational data to improve performance.
Features: Model A + dep_delay, dep_delay_bucket, hour_of_day.
Model: LOGISTIC_REG with TRANSFORM clause.
Key Metrics: Improved AUC, lower log_loss, higher recall.
Insight: Real-time signals significantly enhance model calibration and recall.

Model C — Localized Model (Hub/Route Segment)
Goal: Test whether specialization improves accuracy on key routes.
Scope: Subset by top origins (e.g., ATL, ORD, JFK).
Model: Same as Model B.
Key Metrics: Segment-level AUC, confusion matrix.
Insight: Specialized models capture route-specific patterns, improving calibration for high-volume airports.

Model D — Threshold & Cost Policy Optimization
Goal: Choose an operating threshold that minimizes expected disruption cost.
Input: Predictions from Model B/C and a cost matrix (C_FP = $1,000, C_FN = $6,000).
Method: Threshold sweep using ML.PREDICT and cost-weighted evaluation.
Outcome: Best-performing threshold ≈ 0.70, prioritizing recall and minimizing missed diversions.
Insight: Operational costs of false negatives are far greater than false positives; over-preparedness is preferred.

## Regression (Supplementary)

Model: LINEAR_REG to predict arr_delay.
Features: dep_delay, distance, carrier, origin, dest, day_of_week.
Metric: Mean Absolute Error (MAE ≈ 10–12 minutes).
Interpretation: A 10-minute MAE indicates average deviation between predicted and actual delays — acceptable for planning gate usage and staff rotation windows.

## Tools & Environment

Platform: Google Colab + BigQuery

Tech Stack:
BigQuery ML (ML.CREATE_MODEL, ML.EVALUATE, ML.EXPLAIN_PREDICT)
SQL with TRANSFORM clause for feature engineering
Python (for orchestration and visualization)

Dataset: bigquery-public-data.faa.us_flights
(Standardized schema with flight_date, dep_delay, distance, carrier, origin, dest, diverted)

## Repository Structure

Unit2_Flights_Team4/

├─ Assignment#2_Individual/

│  ├─ Unit2_KundanaNittala_BQML.ipynb

│  ├─ Summary_Sanjana_Mohan.md

│  ├─ Unit2_LilyLarson_Summary.md

│  └─ Unit2_LilyLarson_BQML.ipynb

│  ├─ Unit2_KundanaNittala_summary.md

│  ├─ Unit2_BQML_Flights_Classification_Sanjana_Mohan.ipynb

│  ├─ Unit2_BQML_Flights_Classification_AnuragKoripalli.ipynb

│  └─ Unit2_AnuragKoripalli_Summary.md

├─ team/

│  ├─ Ops_Brief.pdf                 # 2–3 page operational brief

│  └─ README.md                     # (This file)


## How to Reproduce

Authenticate & Setup

from google.colab import auth
auth.authenticate_user()
from google.cloud import bigquery
bq = bigquery.Client(project="YOUR_PROJECT_ID")


Define the canonical schema

Ensure your source table includes carrier, dep_delay, arr_delay, origin, dest, diverted.

Run SQL in order

Inspect model metrics

Use ML.EVALUATE for performance.

Use ML.EXPLAIN_PREDICT for interpretability.

Compare confusion matrices at 0.5 and custom thresholds.

Interpret

Record MAE, AUC, precision, recall, and cost trade-offs in your notebook or Ops_Brief.pdf.

## Model Governance
Assumptions

Data accurately reflects true diversion outcomes and operational conditions.

Historical delay patterns are representative of future performance.

Limitations

Class imbalance (diverted ≈ 2%) limits recall sensitivity.

Weather and air traffic control data not included.

Assumes static cost ratios for FP/FN.

Monitoring Plan
Metric	Target	Cadence	Owner
Recall	≥ 0.75	Weekly	Data Ops
Precision	≥ 0.30	Weekly	ML Engineer
Calibration Drift	< 5% deviation	Monthly	Analytics Lead


## Key Insights

Even simple logistic models yield actionable insights for disruption planning.

Real-time features (departure delay, time of day) significantly improve recall.

Custom thresholds calibrated to business costs outperform generic defaults.

Feature engineering is the most cost-effective method for uplift compared to complex models.

## Team Members

Anurag

Kundana

Lily

Sanjana
