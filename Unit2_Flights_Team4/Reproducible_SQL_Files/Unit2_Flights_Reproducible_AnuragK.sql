-- =====================================================================
-- Unit 2 — Flights (BQML) — Reproducible SQL Script
-- Author: Anurag Koripalli
-- =====================================================================
-- This script contains:
--   1) Baseline Logistic Regression for diversion prediction
--   2) Evaluation and confusion matrices (default & custom thresholds)
--   3) Engineered model using TRANSFORM features
--   4) Regression model for arrival delay (MAE interpretation)
--   5) Cost-based threshold optimization (Model D)
-- =====================================================================

-- =========================
-- 0) CONFIG & VARIABLES
-- =========================
DECLARE PROJECT_ID STRING DEFAULT 'mgmt467project';
DECLARE DATASET STRING DEFAULT 'unit2_flights';
DECLARE TABLE_PATH STRING DEFAULT 'mgmt467project.flights_cleaned_v2';
DECLARE THRESH FLOAT64 DEFAULT 0.10;
DECLARE C_FP INT64 DEFAULT 1000;
DECLARE C_FN INT64 DEFAULT 6000;

DECLARE MODEL_BASE STRING;
DECLARE MODEL_ENG STRING;
DECLARE MODEL_REG STRING;

-- Assign model names after declarations
SET MODEL_BASE = FORMAT('%s.%s.clf_diverted_base', PROJECT_ID, DATASET);
SET MODEL_ENG  = FORMAT('%s.%s.clf_diverted_engineered', PROJECT_ID, DATASET);
SET MODEL_REG  = FORMAT('%s.%s.reg_arrdelay', PROJECT_ID, DATASET);

-- Create schema if needed
EXECUTE IMMEDIATE FORMAT("""
  CREATE SCHEMA IF NOT EXISTS `%s.%s`
""", PROJECT_ID, DATASET);

-- =====================================================================
-- 1) BASELINE CLASSIFICATION MODEL — LOGISTIC_REG
-- =====================================================================
CREATE OR REPLACE MODEL `${MODEL_BASE}`
OPTIONS (model_type='logistic_reg', input_label_cols=['diverted']) AS
WITH canonical_flights AS (
  SELECT
    CAST(FL_DATE AS DATE) AS flight_date,
    CAST(DepDelay AS FLOAT64) AS dep_delay,
    CAST(Distance AS FLOAT64) AS distance,
    CAST(CARRIER AS STRING) AS carrier,
    CAST(Origin AS STRING) AS origin,
    CAST(Dest AS STRING) AS dest,
    CAST(Diverted AS BOOL) AS diverted
  FROM `${TABLE_PATH}`
  WHERE DepDelay IS NOT NULL
),
split_data AS (
  SELECT cf.*, CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS split_col
  FROM canonical_flights cf
)
SELECT
  diverted,
  dep_delay, distance, carrier, origin, dest,
  EXTRACT(DAYOFWEEK FROM flight_date) AS day_of_week
FROM split_data
WHERE split_col = 'TRAIN';

-- =====================================================================
-- 1A) BASELINE EVALUATION
-- =====================================================================
SELECT * FROM ML.EVALUATE(
  MODEL `${MODEL_BASE}`,
  (
    WITH canonical_flights AS (
      SELECT
        CAST(FL_DATE AS DATE) AS flight_date,
        CAST(DepDelay AS FLOAT64) AS dep_delay,
        CAST(Distance AS FLOAT64) AS distance,
        CAST(CARRIER AS STRING) AS carrier,
        CAST(Origin AS STRING) AS origin,
        CAST(Dest AS STRING) AS dest,
        CAST(Diverted AS BOOL) AS diverted
      FROM `${TABLE_PATH}`
      WHERE DepDelay IS NOT NULL
    ),
    split_data AS (
      SELECT cf.*, CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS split_col
      FROM canonical_flights cf
    )
    SELECT
      diverted,
      dep_delay, distance, carrier, origin, dest,
      EXTRACT(DAYOFWEEK FROM flight_date) AS day_of_week
    FROM split_data
    WHERE split_col = 'EVAL'
  )
);

-- =====================================================================
-- 1B) CONFUSION MATRIX — DEFAULT 0.5 THRESHOLD
-- =====================================================================
SELECT * FROM ML.CONFUSION_MATRIX(
  MODEL `${MODEL_BASE}`,
  (
    SELECT
      diverted,
      dep_delay, distance, carrier, origin, dest,
      EXTRACT(DAYOFWEEK FROM FL_DATE) AS day_of_week
    FROM `${TABLE_PATH}`
    WHERE DepDelay IS NOT NULL
  ),
  STRUCT(0.5 AS threshold)
);

-- =====================================================================
-- 1C) CONFUSION MATRIX — CUSTOM THRESHOLD (0.10)
-- =====================================================================
SELECT * FROM ML.CONFUSION_MATRIX(
  MODEL `${MODEL_BASE}`,
  (
    SELECT
      diverted,
      dep_delay, distance, carrier, origin, dest,
      EXTRACT(DAYOFWEEK FROM FL_DATE) AS day_of_week
    FROM `${TABLE_PATH}`
    WHERE DepDelay IS NOT NULL
  ),
  STRUCT(${THRESH} AS threshold)
);

-- =====================================================================
-- 2) FEATURE ENGINEERING — LOGISTIC_REG WITH TRANSFORM
-- =====================================================================
CREATE OR REPLACE MODEL `${MODEL_ENG}`
OPTIONS (model_type='logistic_reg', input_label_cols=['diverted']) AS
WITH canonical_flights AS (
  SELECT
    CAST(FL_DATE AS DATE) AS flight_date,
    CAST(DepDelay AS FLOAT64) AS dep_delay,
    CAST(Distance AS FLOAT64) AS distance,
    CAST(CARRIER AS STRING) AS carrier,
    CAST(Origin AS STRING) AS origin,
    CAST(Dest AS STRING) AS dest,
    CAST(Diverted AS BOOL) AS diverted
  FROM `${TABLE_PATH}`
  WHERE DepDelay IS NOT NULL
),
split_data AS (
  SELECT cf.*, CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS split_col
  FROM canonical_flights cf
)
SELECT
  diverted,
  CONCAT(origin, '-', dest) AS route,
  EXTRACT(DAYOFWEEK FROM flight_date) AS day_of_week,
  CASE
    WHEN dep_delay < 0 THEN 'early'
    WHEN dep_delay BETWEEN 0 AND 15 THEN 'on_time'
    WHEN dep_delay BETWEEN 16 AND 60 THEN 'minor'
    WHEN dep_delay BETWEEN 61 AND 120 THEN 'moderate'
    ELSE 'major'
  END AS dep_delay_bucket,
  distance,
  carrier
FROM split_data
WHERE split_col = 'TRAIN';

-- =====================================================================
-- 2A) ENGINEERED MODEL EVALUATION
-- =====================================================================
SELECT * FROM ML.EVALUATE(
  MODEL `${MODEL_ENG}`,
  (
    SELECT
      diverted,
      CONCAT(Origin, '-', Dest) AS route,
      EXTRACT(DAYOFWEEK FROM FL_DATE) AS day_of_week,
      CASE
        WHEN DepDelay < 0 THEN 'early'
        WHEN DepDelay BETWEEN 0 AND 15 THEN 'on_time'
        WHEN DepDelay BETWEEN 16 AND 60 THEN 'minor'
        WHEN DepDelay BETWEEN 61 AND 120 THEN 'moderate'
        ELSE 'major'
      END AS dep_delay_bucket,
      Distance AS distance,
      CARRIER AS carrier
    FROM `${TABLE_PATH}`
  )
);

-- =====================================================================
-- 3) REGRESSION MODEL — LINEAR_REG (ARR_DELAY)
-- =====================================================================
CREATE OR REPLACE MODEL `${MODEL_REG}`
OPTIONS (model_type='linear_reg', input_label_cols=['arr_delay']) AS
WITH canonical_flights AS (
  SELECT
    CAST(FL_DATE AS DATE) AS flight_date,
    CAST(DepDelay AS FLOAT64) AS dep_delay,
    CAST(Distance AS FLOAT64) AS distance,
    CAST(CARRIER AS STRING) AS carrier,
    CAST(Origin AS STRING) AS origin,
    CAST(Dest AS STRING) AS dest,
    CAST(ArrDelay AS FLOAT64) AS arr_delay
  FROM `${TABLE_PATH}`
  WHERE DepDelay IS NOT NULL AND ArrDelay IS NOT NULL
)
SELECT
  arr_delay,
  dep_delay, distance, carrier, origin, dest,
  EXTRACT(DAYOFWEEK FROM flight_date) AS day_of_week
FROM canonical_flights;

-- =====================================================================
-- 3A) REGRESSION EVALUATION (MAE, RMSE, R²)
-- =====================================================================
SELECT * FROM ML.EVALUATE(MODEL `${MODEL_REG}`);

-- =====================================================================
-- 3B) EXPLAIN_PREDICT — TWO HYPOTHETICAL FLIGHTS
-- =====================================================================
-- Example 1: On-time, short-haul (Tuesday)
SELECT * FROM ML.EXPLAIN_PREDICT(
  MODEL `${MODEL_REG}`,
  (SELECT 0 AS dep_delay, 500 AS distance, 'AA' AS carrier, 'ORD' AS origin, 'LGA' AS dest, 2 AS day_of_week)
);

-- Example 2: Delayed 45m, long-haul (Friday)
SELECT * FROM ML.EXPLAIN_PREDICT(
  MODEL `${MODEL_REG}`,
  (SELECT 45 AS dep_delay, 2000 AS distance, 'DL' AS carrier, 'ATL' AS origin, 'SEA' AS dest, 5 AS day_of_week)
);

-- =====================================================================
-- 4) MODEL D — COST-BASED THRESHOLD OPTIMIZATION
-- =====================================================================
WITH preds AS (
  SELECT
    expected_label,
    (SELECT prob FROM UNNEST(predicted_diverted_probs) WHERE label=TRUE) AS p
  FROM ML.PREDICT(MODEL `${MODEL_ENG}`,
    (SELECT
      CAST(Diverted AS BOOL) AS expected_label,
      CONCAT(Origin, '-', Dest) AS route,
      EXTRACT(DAYOFWEEK FROM FL_DATE) AS day_of_week,
      CASE
        WHEN DepDelay < 0 THEN 'early'
        WHEN DepDelay BETWEEN 0 AND 15 THEN 'on_time'
        WHEN DepDelay BETWEEN 16 AND 60 THEN 'minor'
        WHEN DepDelay BETWEEN 61 AND 120 THEN 'moderate'
        ELSE 'major'
      END AS dep_delay_bucket,
      Distance AS distance,
      CARRIER AS carrier
    FROM `${TABLE_PATH}`)
  )
),
thresholds AS (
  SELECT t AS threshold FROM UNNEST(GENERATE_ARRAY(0.01, 0.90, 0.01)) AS t
),
cost_table AS (
  SELECT
    threshold,
    SUM(CASE WHEN expected_label AND p>=threshold THEN 1 ELSE 0 END) AS TP,
    SUM(CASE WHEN expected_label AND p<threshold THEN 1 ELSE 0 END) AS FN,
    SUM(CASE WHEN NOT expected_label AND p>=threshold THEN 1 ELSE 0 END) AS FP,
    SUM(CASE WHEN NOT expected_label AND p<threshold THEN 1 ELSE 0 END) AS TN,
    ${C_FP} * SUM(CASE WHEN NOT expected_label AND p>=threshold THEN 1 ELSE 0 END) +
    ${C_FN} * SUM(CASE WHEN expected_label AND p<threshold THEN 1 ELSE 0 END) AS expected_cost
  FROM preds CROSS JOIN thresholds
  GROUP BY threshold
)
SELECT * FROM cost_table ORDER BY expected_cost ASC LIMIT 1;

-- =====================================================================
-- END OF SCRIPT
-- =====================================================================
