# Unit 2 Summary — Predictive Modeling at Scale with BQML  
**Author:** Anurag Koripalli  
**Course:** Business Analytics & Information Management  
**Project:** U.S. Flight Delays & Diversion Prediction  

---

## Project Overview
This project explored how predictive modeling in BigQuery ML can support airline operations through two key questions:  
1. **Regression:** Can we estimate arrival delay minutes (`arr_delay`) to improve scheduling and resource planning?  
2. **Classification:** Can we classify the probability a flight is diverted to better manage disruption responses?

We used the *bigquery-public-data.flights* dataset and built a full analytical pipeline from data preparation and model training to evaluation, interpretability, and cost optimization.

---

## Regression: Predicting Arrival Delay
A **linear regression** model was trained using six features: `dep_delay`, `distance`, `carrier`, `origin`, `dest`, and `day_of_week`.  
- **MAE:** ~184 minutes  
- **R²:** 0.52  

This means the model’s predictions are, on average, within about three hours of the actual arrival delay—sufficient for early-stage planning (e.g., gate scheduling or crew turnover). The main drivers were departure delay and route distance. Two explainability examples showed that short-haul on-time flights were sometimes over-penalized, while longer routes showed large negative residuals, highlighting the limits of a purely linear model.

---

## Classification: Predicting Flight Diversions
A **logistic regression** classifier predicted the `diverted` label (Boolean).  
- **Baseline model:** AUC = 0.72, Accuracy = 0.983  
- **Engineered model:** AUC = 0.74, Accuracy = 0.983  

The engineered version included a **TRANSFORM** clause creating a `route` (`origin || '-' || dest`), extracting `day_of_week`, and bucketizing `dep_delay`. These engineered features improved AUC and reduced log loss, demonstrating better calibration and interpretability.

---

## Threshold Optimization & Cost Policy
Using a cost matrix of **C_FP = $1,000** and **C_FN = $6,000**, a threshold sweep showed that **τ = 0.70** minimized expected cost, reducing disruption costs from $13,000 to $4,000 compared to the default 0.5.  
Operationally, this setting balances avoiding false alarms with capturing most true diversions—ideal when the cost of under-preparation outweighs that of over-preparation. Post-deployment, this threshold should be reviewed seasonally and adjusted for weather or carrier mix changes.

---

## Cost & Scale Strategy
Initial development used a **`LIMIT` clause** for fast iteration, followed by full-table training for production-scale runs. This approach balanced speed and cost efficiency, ensuring reproducibility without excessive BigQuery charges.

---

## Key Learnings & Governance
- **Feature engineering** and threshold tuning had greater business impact than adding complex models.  
- **Interpretability** (via `ML.EXPLAIN_PREDICT`) is essential for airline operations to justify automated decisions.  
- **Limitations:** Class imbalance (rare diversions) and lack of weather/context data constrain precision.  
- **Next steps:** Add weather, congestion, and seasonal variables; test segmentation by hub or route for improved calibration.  

**Final Recommendation:** Deploy the engineered model with **τ = 0.70** as a diversion alert threshold and monitor precision/recall, false-alarm cost, and route-specific drift monthly.

---
