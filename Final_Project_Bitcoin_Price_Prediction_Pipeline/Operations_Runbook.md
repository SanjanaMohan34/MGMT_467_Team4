# MGMT 467 Final Project – Bitcoin Price Prediction Pipeline  
## Operations Brief  
**Team 4**  
Anurag Koripalli, Lily Larson, Sanjana Mohan, Kundada Nittala  

---

This runbook contains the recommended procedures for maintenance, monitoring, and incident response for the Bitcoin Price Prediction Pipeline using the CoinCap API.

---

## I. System Components & Status

| Component | GCP Service | Role | Status Check Location |
|--------|------------|------|----------------------|
| Batch Storage | GCS – Cloud Storage | Raw CSV and clean JSON storage | GCS Console |
| Data Warehouse | BigQuery | All tables (historical data, streaming, ML views, etc.) | BigQuery Console<br>`SELECT * FROM bitcoin_streaming ORDER BY ingestion_time DESC LIMIT 10` |
| Streaming Producer | Cloud Functions | Calls CoinCap API every minute and publishes to Pub/Sub | Cloud Functions Logs, Cloud Monitoring |
| Message Queue | Pub/Sub | Decouples producer/consumer | Pub/Sub Topic Metrics |
| Streaming Pipeline | Dataflow (Template) | Pub/Sub → BigQuery streaming ingest | Dataflow Job Graph & Logs |
| Monitoring | Looker Studio | Executive dashboard with streaming KPIs | [Looker Studio Dashboard](https://lookerstudio.google.com/reporting/ec2897c6-266b-4af0-ba90-397839fd53ae) |

---

## II. Failure Playbook & Incident Response

This section outlines the steps to take when a component of the system fails.

---

### Incident: Cloud Function Producer Failure (API Downtime or Timeout)

**Severity:** High  

**Symptoms:**
- Cloud Function logs show connection errors (timeouts, HTTP errors, etc.)
- No new messages appear in Pub/Sub

**Diagnosis:**
- Review Cloud Functions logs for CoinCap API errors or network issues
- Check Cloud Monitoring for execution time vs. configured timeout

**Actions to Take:**
- **Auto-Retry & Backoff:** Confirm the Cloud Function retry mechanism is enabled for transient errors  
- **Cache Implementation:** If the API is down, publish the last successful price from a cached source (e.g., GCS or Firestore) with a warning flag  
- **Manual Check:** Verify CoinCap API status page  
- **Timeout Adjustment:** Increase the Cloud Function timeout if executions are consistently timing out

---

### Incident: Dataflow Pipeline Stalled (Schema / Data Quality)

**Severity:** High  

**Symptoms:**
- Messages accumulate in Pub/Sub
- No new data appears in the BigQuery streaming table
- Dataflow job graph shows high *Element Lag*

**Diagnosis:**
- Review Dataflow logs for JSON parsing or BigQuery insertion errors
- Inspect the Dead Letter Queue (DLQ) for malformed messages

**Actions to Take:**
- **Schema Validation:** Update BigQuery schema or Dataflow processing logic if the API structure changed  
- **Restart Pipeline:** Drain and restart the Dataflow job if no obvious error is present  
- **Manual Ingest:** Pause the Cloud Function and correct DLQ messages before reprocessing if the API change is severe

---

### Incident: Batch ETL Failure (Data Quality Check)

**Severity:** Medium (Impacts model training)

**Symptoms:**
- ETL script (GCS → BigQuery) fails
- Large number of rows are rejected

**Diagnosis:**
- Review ETL logs for duplicate timestamps, zero-volume records, or missing timestamps

**Actions to Take:**
- **Isolate:** Move corrupted CSV/JSON files to a separate GCS location  
- **Clean:** Manually enforce no duplicates, no zero-volume records, and strictly increasing timestamps  
- **Rerun:** Re-execute the batch ETL process

---

## III. Cost Control Checklist

### BigQuery
**Control Measures:**
- All batch and streaming tables are time-partitioned (e.g., `batch_ts`, `ingestion_time`)
- Streaming tables use partition pruning

**Rationale:**  
Reduces query costs and improves performance under high-frequency writes.

---

### Cloud Functions
**Control Measures:**
- Max instances set to 1
- Execution frequency fixed at 1 minute

**Rationale:**  
Prevents concurrent API calls and limits operational costs.

---

### Dataflow
**Control Measures:**
- Streaming engine template with autoscaling boundaries
- Low `max_num_workers` configured

**Rationale:**  
Efficiently handles minute-level streaming load while minimizing resource usage.

---

### GCS – Google Cloud Storage
**Control Measures:**
- Lifecycle policies for raw batch CSV files (delete or move to cold storage after successful load)

**Rationale:**  
Minimizes long-term storage costs for static raw data.

---

## IV. Runbook Conclusion

This document defines the standard operating procedures, failure playbooks, and cost control measures for the Bitcoin Price Prediction Pipeline. Any incidents not covered by this runbook should be escalated immediately to the project lead.
