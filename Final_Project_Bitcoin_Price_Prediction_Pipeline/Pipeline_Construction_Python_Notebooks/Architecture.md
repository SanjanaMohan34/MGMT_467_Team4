## System Architecture Overview

The Bitcoin Price Prediction Pipeline is composed of three integrated data flows: batch ingestion, real-time streaming, and machine learning analytics.

### Batch Data Pipeline
Kaggle → GCS → BigQuery

### Real-Time Streaming Pipeline
API → Cloud Function → Pub/Sub → Dataflow → BigQuery

### Machine Learning & Analytics Layer
BigQuery → BQML → Dashboard
