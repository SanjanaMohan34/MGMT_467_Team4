# Individual Contribution Summary  
**Name:** Sanjana Mohan  
**Course:** MGMT 467  
**Project:** Real-Time Bitcoin Price Prediction Pipeline  

## Overview

My primary contribution focused on the analytics and visualization layer of the pipeline, specifically preparing BigQuery datasets optimized for Looker Studio** and ensuring the dashboard could support real-time insights without performance or row-limit issues. I also led the DIVE analysis and contributed to validation, governance considerations, and executive-facing KPI design.

## Key Contributions

### 1. Looker Studio Dataset Engineering
- Designed and implemented BigQuery views to support executive dashboards while avoiding Looker Studio row limitations.
- Introduced minute-level aggregation on high-frequency streaming data to improve dashboard load times and stability.
- Built KPI-ready datasets for:
  - Latest live Bitcoin price
  - Last batch (closing) price
  - Live vs. batch price change
  - Model-predicted price
  - Average Absolute Error (AAE) for model performance

### 2. Performance Optimization & Validation
- Identified and resolved the “Too Many Rows” dashboard rendering error by moving aggregation logic upstream into BigQuery.
- Validated data freshness, correctness, and schema consistency through targeted SQL checks on streaming and aggregated views.
- Ensured all Looker-facing datasets were cost-efficient using partitioned tables and aggregation-aware queries.

### 3. DIVE Analysis & Individual Notebook
- Authored the DIVE journal (Describe, Interpret, Verify, Evaluate) in my individual notebook, focusing on:
  - Translating business questions into dashboard-ready metrics
  - Justifying aggregation and modeling decisions
  - Verifying model outputs and dashboard correctness
- Implemented a required interactive Plotly visualization mirroring Looker Studio logic to demonstrate analytical ownership and validation.

### 4. Executive Dashboard & KPI Design
- Contributed to the design of an executive-facing real-time trading dashboard that balances insight clarity with system constraints.
- Ensured KPI definitions aligned with business use cases such as market monitoring and risk awareness.
- Collaborated on layout and metric selection to support rapid executive interpretation.

### 5. Governance & Operational Awareness
- Contributed to governance discussions by documenting:
  - Low privacy risk due to exclusive use of public, non-PII financial data
  - Alignment with IAM Least Privilege principles
- Supported operational readiness through documentation of an ops brief.

## Artifacts & Deliverables

- DIVE journal, BigQuery view creation, validation queries, and Plotly visualization  
- Looker Studio Dashboard — KPI definitions and real-time analytics datasets  
- BigQuery SQL Views — Aggregated, dashboard-optimized data sources  

## Key Lessons Learned

- High-frequency streaming data requires upstream aggregation to remain usable in BI tools.
- Dashboard reliability is as critical as model accuracy for executive decision-making.
- Separating analytics-layer datasets from raw ingestion tables improves scalability, cost control, and interpretability.
- A lot of errors can occur during the pipeline process and it's important to have a ready to use plan of action to deal with the errors.
- It is important to consider the audience and what information they will find important for our dashboard to have the correct KPIs on there.
- Our model needs to be trained on large amounts of data to be optimal.

