# MGMT 467 Final Project  
## Bitcoin Batch + Streaming Analytics Pipeline (Google Cloud)

---

## Project Overview
This project implements an **end-to-end cloud analytics pipeline** that combines **historical batch data** and **real-time streaming data** to support near real-time analytics and machine learning. Using Google Cloud services, the pipeline ingests, processes, models, and visualizes Bitcoin price data in a reproducible and explainable way.

The solution demonstrates how batch and streaming data can be integrated into a single analytics workflow suitable for business and decision-making contexts.

---

## Business Objective
The goal of this project is to:
- Ingest **historical Bitcoin price data** to establish long-term patterns
- Ingest **live Bitcoin price data** from a public API
- Combine batch and streaming features in a **BigQuery ML (BQML)** model
- Generate explainable predictions in near real time
- Visualize results in an executive-facing dashboard

---

## Architecture Overview

### Batch Pipeline

### Streaming Pipeline

### Analytics & Visualization

Both batch and streaming pipelines converge in BigQuery, where analytics, modeling, and visualization are performed.

---

## Technology Stack
- **Google Cloud Storage (GCS)** – Raw batch data storage and Dataflow staging
- **BigQuery** – Batch tables, streaming tables, analytics views, ML models
- **Cloud Functions (2nd Gen)** – Streaming data producer
- **Pub/Sub** – Streaming message transport
- **Dataflow (Template)** – Pub/Sub to BigQuery streaming ingestion
- **BigQuery ML (BQML)** – Regression model using batch + streaming features
- **Plotly** – Interactive dashboard
- **Colab / Jupyter Notebooks** – Pipeline orchestration and documentation

---

## Data Sources

### Batch Data (Kaggle)
- Historical Bitcoin minute-level price dataset (CSV)
- Loaded into BigQuery and transformed into analytics-ready tables

### Streaming Data (Public API)
- Coinbase public API (no authentication required)
- Provides current Bitcoin price at scheduled intervals

---

## BigQuery Resources

### Dataset
- `bitcoin_data_set`

### Batch Tables / Views
- `bitcoin_full_dataset` – Raw loaded batch data
- `bitcoin_cleaned` – Curated batch data
- `bitcoin_analytics_view` – Analytics-ready batch view

### Streaming Tables
- `bitcoin_streaming` – Live streaming table (partitioned by `ingestion_time`)
- `bitcoin_deadletter` – Records failing Dataflow ingestion

### ML Models
- `bitcoin_combined_predictor` – BQML regression model using batch + streaming features

---

## Repository Structure (Logical)
.
├── README.md
├── notebooks/
│ ├── Batch_Ingest.ipynb
│ ├── Streaming_Pipeline.ipynb
│ └── BQML_Dashboard.ipynb
├── images/
│ ├── architecture_diagram.png
│ ├── pipeline_proof.png
│ └── model_results.png
└── Final_<YourName>_contrib.md


---

## Setup Requirements

### Prerequisites
- Google Cloud project with billing enabled
- Enabled APIs:
  - BigQuery
  - Cloud Storage
  - Cloud Functions
  - Pub/Sub
  - Dataflow
  - Cloud Scheduler
  - Cloud Build
- IAM permissions sufficient for:
  - BigQuery
  - Storage
  - Cloud Functions
  - Pub/Sub
  - Dataflow
  - Scheduler

---

## End-to-End Workflow

### Step 1 — Batch Ingestion
1. Upload Kaggle CSV files to GCS
2. Load raw data into BigQuery (`bitcoin_full_dataset`)
3. Clean and transform into curated tables (`bitcoin_cleaned`)
4. Create analytics view (`bitcoin_analytics_view`)
5. Validate row counts and schema

---

### Step 2 — Streaming Ingestion
1. Deploy Cloud Function (Gen2) to:
   - Call Coinbase API
   - Normalize JSON payload
   - Publish messages to Pub/Sub
2. Schedule function execution using Cloud Scheduler
3. Create BigQuery streaming and deadletter tables
4. Launch Dataflow streaming template:
   - Pub/Sub → BigQuery
5. Validate ingestion using BigQuery queries with recent timestamps

---

### Step 3 — Analytics, Modeling, and Dashboard
1. Perform explicit data quality checks on batch and streaming data
2. Train BQML regression model combining:
   - Batch features (Open, Close, High, Low, Volume)
   - Streaming features (price_usd, etc.)
   - Recency-based feature
3. Evaluate model using `ML.EVALUATE`
4. Explain predictions using `ML.EXPLAIN_PREDICT`
5. Generate predictions on live streaming data
6. Visualize results using an interactive Plotly dashboard

---

## Demo Proof (What Is Shown Live)

### Streaming Validation
```sql
SELECT
  ingestion_time,
  asset,
  price_usd,
  TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), ingestion_time, SECOND) AS seconds_ago
FROM `<PROJECT_ID>.bitcoin_data_set.bitcoin_streaming`
ORDER BY ingestion_time DESC
LIMIT 10;




SELECT COUNT(*) AS row_count
FROM `<PROJECT_ID>.bitcoin_data_set.bitcoin_cleaned`;

Pipeline Proof

Model Evaluation Metrics

Looker Studio Dashboard

