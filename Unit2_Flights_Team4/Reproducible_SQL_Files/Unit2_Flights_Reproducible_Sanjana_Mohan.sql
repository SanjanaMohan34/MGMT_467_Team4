-- =====================================================================
-- Unit 2 — Flights (BQML) — Complete Reproducible Script
-- Updated to use 'mgmt467-project1.flights.raw_flights'
-- =====================================================================

-- 0 -- CONFIG & VARIABLES
======================================================
DECLARE PROJECT_ID STRING DEFAULT 'mgmt467-project1';
DECLARE DATASET_MODEL STRING DEFAULT 'unit2_flights';
DECLARE TABLE_RAW_PATH STRING DEFAULT 'mgmt467-project1.flights.raw_flights';

-- Classification hyperparameters/costs (can be tuned)
DECLARE THRESH FLOAT64 DEFAULT 0.5;
DECLARE C_FP INT64 DEFAULT 1000;
DECLARE C_FN INT64 DEFAULT 6000;

-- Localized Model Segment
DECLARE HUBS ARRAY<STRING> DEFAULT ['ATL', 'ORD', 'JFK'];

-- Model names (built dynamically)
DECLARE MODEL_BASE STRING;
DECLARE MODEL_ENG STRING;
DECLARE MODEL_REG STRING;
DECLARE MODEL_LOCALIZED STRING;

-- Assign model names after declarations
SET MODEL_BASE = FORMAT("%s.%s.clf_diverted_base", PROJECT_ID, DATASET_MODEL);
SET MODEL_ENG = FORMAT("%s.%s.clf_diverted_engineered", PROJECT_ID, DATASET_MODEL);
SET MODEL_REG = FORMAT("%s.%s.reg_arr_delay", PROJECT_ID, DATASET_MODEL);
SET MODEL_LOCALIZED = FORMAT("%s.%s.clf_diverted_local", PROJECT_ID, DATASET_MODEL);

-- Create schema if needed
EXECUTE IMMEDIATE FORMAT("""
CREATE SCHEMA IF NOT EXISTS %s.%s;
""", PROJECT_ID, DATASET_MODEL);

------------------------------------------------------------------------------------------------------

-- 1) BASELINE CLASSIFICATION MODEL — LOGISTIC_REG (TRAINING BLOCK)
======================================================

CREATE OR REPLACE MODEL ${MODEL_BASE}
OPTIONS (
  MODEL_TYPE='LOGISTIC_REG',
  INPUT_LABEL_COLS=['diverted'],
  L1_REG = 0.1, 
  L2_REG = 0.1,
  MAX_ITERATIONS = 50,
  CLASS_WEIGHTS = [
    STRUCT('FALSE' AS key, 1.0 AS value),
    STRUCT('TRUE' AS key, 20.0 AS value) 
  ]
) AS
WITH canonical_flights AS (

  SELECT
    CAST(FlightDate AS DATE) AS flight_date,
    CAST(DepDelay AS FLOAT64) AS dep_delay,
    CAST(distance AS FLOAT64) AS distance,
    CAST(Reporting_Airline AS STRING) AS carrier,
    CAST(Origin AS STRING) AS origin,
    CAST(Dest AS STRING) AS dest,
    CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
  FROM `${TABLE_RAW_PATH}`
  WHERE DepDelay IS NOT NULL AND Diverted IS NOT NULL

)

, split AS (
  SELECT cf.*,
          CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS data_split_col
  FROM canonical_flights cf
)

SELECT
  s.diverted,
  s.dep_delay,
  s.distance,
  s.carrier,
  s.origin,
  s.dest,
  EXTRACT(DAYOFWEEK FROM s.flight_date) AS day_of_week,
  EXTRACT(MONTH FROM s.flight_date) AS month
FROM split AS s
WHERE s.data_split_col='TRAIN';


-- 1A) BASELINE MODEL EVALUATION (ROC_AUC, Precision, Recall)
======================================================

SELECT * FROM ML.EVALUATE(
  MODEL ${MODEL_BASE},
  (
    WITH canonical_flights AS (
      SELECT
        CAST(FlightDate AS DATE) AS flight_date,
        CAST(DepDelay AS FLOAT64) AS dep_delay,
        CAST(distance AS FLOAT64) AS distance,
        CAST(Reporting_Airline AS STRING) AS carrier,
        CAST(Origin AS STRING) AS origin,
        CAST(Dest AS STRING) AS dest,
        CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
      FROM `${TABLE_RAW_PATH}`
      WHERE DepDelay IS NOT NULL AND Diverted IS NOT NULL
    )
    
    , split AS (
      SELECT cf.*,
              CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS data_split_col
      FROM canonical_flights cf
    )

    SELECT
      s.diverted,
      s.dep_delay,
      s.distance,
      s.carrier,
      s.origin,
      s.dest,
      EXTRACT(DAYOFWEEK FROM s.flight_date) AS day_of_week,
      EXTRACT(MONTH FROM s.flight_date) AS month
    FROM split AS s
    WHERE s.data_split_col='EVAL'
  )
);


-- 1B) BASELINE CONFUSION MATRIX — DEFAULT 0.5 THRESHOLD
======================================================

SELECT * FROM ML.CONFUSION_MATRIX(
  MODEL ${MODEL_BASE},
  (
    WITH canonical_flights AS (
      SELECT
        CAST(FlightDate AS DATE) AS flight_date,
        CAST(DepDelay AS FLOAT64) AS dep_delay,
        CAST(distance AS FLOAT64) AS distance,
        CAST(Reporting_Airline AS STRING) AS carrier,
        CAST(Origin AS STRING) AS origin,
        CAST(Dest AS STRING) AS dest,
        CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
      FROM `${TABLE_RAW_PATH}`
      WHERE DepDelay IS NOT NULL AND Diverted IS NOT NULL
    )
    
    , split AS (
      SELECT cf.*,
              CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS data_split_col
      FROM canonical_flights cf
    )

    SELECT
      s.diverted,
      s.dep_delay,
      s.distance,
      s.carrier,
      s.origin,
      s.dest,
      EXTRACT(DAYOFWEEK FROM s.flight_date) AS day_of_week,
      EXTRACT(MONTH FROM s.flight_date) AS month
    FROM split AS s
    WHERE s.data_split_col='EVAL'
  ),
  STRUCT(0.5 AS threshold)
);


-- 1C) BASELINE CONFUSION MATRIX — CUSTOM THRESHOLD (${THRESH})
======================================================

SELECT * FROM ML.CONFUSION_MATRIX(
  MODEL ${MODEL_BASE},
  (
    WITH canonical_flights AS (
      SELECT
        CAST(FlightDate AS DATE) AS flight_date,
        CAST(DepDelay AS FLOAT64) AS dep_delay,
        CAST(distance AS FLOAT64) AS distance,
        CAST(Reporting_Airline AS STRING) AS carrier,
        CAST(Origin AS STRING) AS origin,
        CAST(Dest AS STRING) AS dest,
        CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
      FROM `${TABLE_RAW_PATH}`
      WHERE DepDelay IS NOT NULL AND Diverted IS NOT NULL
    )
    
    , split AS (
      SELECT cf.*,
              CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS data_split_col
      FROM canonical_flights cf
    )

    SELECT
      s.diverted,
      s.dep_delay,
      s.distance,
      s.carrier,
      s.origin,
      s.dest,
      EXTRACT(DAYOFWEEK FROM s.flight_date) AS day_of_week,
      EXTRACT(MONTH FROM s.flight_date) AS month
    FROM split AS s
    WHERE s.data_split_col='EVAL'
  ),
  STRUCT(@THRESH AS threshold)
);


------------------------------------------------------------------------------------------------------

-- 2) ENGINEERED CLASSIFICATION MODEL — LOGISTIC_REG with TRANSFORM (TRAINING BLOCK)
======================================================

CREATE OR REPLACE MODEL ${MODEL_ENG}
OPTIONS (
  MODEL_TYPE='LOGISTIC_REG',
  INPUT_LABEL_COLS=['diverted'],
  TRANSFORM=(
    -- Binarize delay into buckets
    CASE
      WHEN dep_delay < 0 THEN 'early'
      WHEN dep_delay BETWEEN 0 AND 15 THEN 'on_time'
      WHEN dep_delay BETWEEN 16 AND 60 THEN 'minor'
      WHEN dep_delay BETWEEN 61 AND 120 THEN 'moderate'
      ELSE 'major'
    END AS dep_delay_bucket,
    -- Combine origin and destination into a single route feature
    CONCAT(origin, '-', dest) AS route,
    -- Pass-through/derived features
    distance,
    carrier,
    EXTRACT(DAYOFWEEK FROM flight_date) AS day_of_week,
    EXTRACT(MONTH FROM flight_date) AS month,
    diverted -- Label
  )
) AS
WITH canonical_flights AS (

  SELECT
    CAST(FlightDate AS DATE) AS flight_date,
    CAST(DepDelay AS FLOAT64) AS dep_delay,
    CAST(distance AS FLOAT64) AS distance,
    CAST(Reporting_Airline AS STRING) AS carrier,
    CAST(Origin AS STRING) AS origin,
    CAST(Dest AS STRING) AS dest,
    CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
  FROM `${TABLE_RAW_PATH}`
  WHERE DepDelay IS NOT NULL AND Diverted IS NOT NULL

)

, split AS (
  SELECT cf.*,
          CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS data_split_col
  FROM canonical_flights cf
)

-- The TRANSFORM clause uses all columns defined here
SELECT * FROM split AS s
WHERE s.data_split_col='TRAIN';


-- 2A) ENGINEERED MODEL EVALUATION (ROC_AUC, Precision, Recall)
======================================================

SELECT * FROM ML.EVALUATE(
  MODEL ${MODEL_ENG},
  (
    WITH canonical_flights AS (
      SELECT
        CAST(FlightDate AS DATE) AS flight_date,
        CAST(DepDelay AS FLOAT64) AS dep_delay,
        CAST(distance AS FLOAT64) AS distance,
        CAST(Reporting_Airline AS STRING) AS carrier,
        CAST(Origin AS STRING) AS origin,
        CAST(Dest AS STRING) AS dest,
        CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
      FROM `${TABLE_RAW_PATH}`
      WHERE DepDelay IS NOT NULL AND Diverted IS NOT NULL
    )
    
    , split AS (
      SELECT cf.*,
              CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS data_split_col
      FROM canonical_flights cf
    )

    -- The TRANSFORM clause handles feature creation during evaluation
    SELECT *
    FROM split AS s
    WHERE s.data_split_col='EVAL'
  )
);

------------------------------------------------------------------------------------------------------

-- 3) REGRESSION MODEL — LINEAR_REG (Predicts arr_delay)
======================================================

CREATE OR REPLACE MODEL ${MODEL_REG}
OPTIONS (
  MODEL_TYPE='LINEAR_REG',
  INPUT_LABEL_COLS=['arr_delay']
) AS
WITH canonical_flights AS (

  SELECT
    CAST(FlightDate AS DATE) AS flight_date,
    CAST(DepDelay AS FLOAT64) AS dep_delay,
    CAST(ArrDelay AS FLOAT64) AS arr_delay,
    CAST(distance AS FLOAT64) AS distance,
    CAST(Reporting_Airline AS STRING) AS carrier,
    CAST(Origin AS STRING) AS origin,
    CAST(Dest AS STRING) AS dest,
    CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
  FROM `${TABLE_RAW_PATH}`
  WHERE DepDelay IS NOT NULL AND ArrDelay IS NOT NULL 

)

, split AS (
  SELECT cf.*,
          CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS data_split_col
  FROM canonical_flights cf
)

SELECT
  s.arr_delay,
  s.dep_delay,
  s.distance,
  s.carrier,
  s.origin,
  s.dest,
  EXTRACT(DAYOFWEEK FROM s.flight_date) AS day_of_week
FROM split AS s
WHERE s.data_split_col='TRAIN';


-- 4) REGRESSION MODEL EVALUATION (MAE, R2)
======================================================

SELECT * FROM ML.EVALUATE(
  MODEL ${MODEL_REG},
  (
    WITH canonical_flights AS (

      SELECT
        CAST(FlightDate AS DATE) AS flight_date,
        CAST(DepDelay AS FLOAT64) AS dep_delay,
        CAST(ArrDelay AS FLOAT64) AS arr_delay,
        CAST(distance AS FLOAT64) AS distance,
        CAST(Reporting_Airline AS STRING) AS carrier,
        CAST(Origin AS STRING) AS origin,
        CAST(Dest AS STRING) AS dest,
        CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
      FROM `${TABLE_RAW_PATH}`
      WHERE DepDelay IS NOT NULL AND ArrDelay IS NOT NULL 

    )
    
    , split AS (
      SELECT cf.*,
              CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS data_split_col
      FROM canonical_flights cf
    )

    SELECT
      s.arr_delay,
      s.dep_delay,
      s.distance,
      s.carrier,
      s.origin,
      s.dest,
      EXTRACT(DAYOFWEEK FROM s.flight_date) AS day_of_week
    FROM split AS s
    WHERE s.data_split_col='EVAL'
  )
);


-- 5) REGRESSION MODEL EXPLAIN PREDICT (Feature Attribution)
======================================================

SELECT * FROM ML.EXPLAIN_PREDICT(
  MODEL ${MODEL_REG},
  (
    WITH canonical_flights AS (

      SELECT
        CAST(FlightDate AS DATE) AS flight_date,
        CAST(DepDelay AS FLOAT64) AS dep_delay,
        CAST(ArrDelay AS FLOAT64) AS arr_delay,
        CAST(distance AS FLOAT64) AS distance,
        CAST(Reporting_Airline AS STRING) AS carrier,
        CAST(Origin AS STRING) AS origin,
        CAST(Dest AS STRING) AS dest,
        CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
      FROM `${TABLE_RAW_PATH}`
      WHERE DepDelay IS NOT NULL AND ArrDelay IS NOT NULL 

    )
    
    , split AS (
      SELECT cf.*,
              CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS data_split_col
      FROM canonical_flights cf
    )

    SELECT
      s.arr_delay,
      s.dep_delay,
      s.distance,
      s.carrier,
      s.origin,
      s.dest,
      EXTRACT(DAYOFWEEK FROM s.flight_date) AS day_of_week
    FROM split AS s
    WHERE s.data_split_col='EVAL'
    LIMIT 2
  )
);

------------------------------------------------------------------------------------------------------

-- 6) LOCALIZED CLASSIFICATION MODEL (TRAINING BLOCK)
======================================================

CREATE OR REPLACE MODEL ${MODEL_LOCALIZED}
OPTIONS (
  MODEL_TYPE='LOGISTIC_REG',
  INPUT_LABEL_COLS=['diverted'],
  L1_REG = 0.1, 
  L2_REG = 0.1,
  MAX_ITERATIONS = 50,
  TRANSFORM=(
    -- Features based on the Engineered Model
    CASE
      WHEN dep_delay < 0 THEN 'early'
      WHEN dep_delay BETWEEN 0 AND 15 THEN 'on_time'
      WHEN dep_delay BETWEEN 16 AND 60 THEN 'minor'
      WHEN dep_delay BETWEEN 61 AND 120 THEN 'moderate'
      ELSE 'major'
    END AS dep_delay_bucket,
    CONCAT(origin, '-', dest) AS route,
    distance,
    carrier,
    EXTRACT(DAYOFWEEK FROM flight_date) AS day_of_week,
    EXTRACT(MONTH FROM flight_date) AS month,
    diverted -- Label
  )
) AS
WITH canonical_flights AS (

  SELECT
    CAST(FlightDate AS DATE) AS flight_date,
    CAST(DepDelay AS FLOAT64) AS dep_delay,
    CAST(distance AS FLOAT64) AS distance,
    CAST(Reporting_Airline AS STRING) AS carrier,
    CAST(Origin AS STRING) AS origin,
    CAST(Dest AS STRING) AS dest,
    CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
  FROM `${TABLE_RAW_PATH}`
  WHERE DepDelay IS NOT NULL AND Diverted IS NOT NULL

)

, split AS (
  SELECT cf.*,
          CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS data_split_col
  FROM canonical_flights cf
)

-- Filter for localized training set
SELECT * FROM split AS s
WHERE s.data_split_col='TRAIN'
  AND s.origin IN UNNEST(@HUBS);


-- 6A) LOCALIZED MODEL EVALUATION
======================================================

SELECT * FROM ML.EVALUATE(
  MODEL ${MODEL_LOCALIZED},
  (
    WITH canonical_flights AS (
      SELECT
        CAST(FlightDate AS DATE) AS flight_date,
        CAST(DepDelay AS FLOAT64) AS dep_delay,
        CAST(distance AS FLOAT64) AS distance,
        CAST(Reporting_Airline AS STRING) AS carrier,
        CAST(Origin AS STRING) AS origin,
        CAST(Dest AS STRING) AS dest,
        CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
      FROM `${TABLE_RAW_PATH}`
      WHERE DepDelay IS NOT NULL AND Diverted IS NOT NULL
    )
    
    , split AS (
      SELECT cf.*,
              CASE WHEN RAND() < 0.8 THEN 'TRAIN' ELSE 'EVAL' END AS data_split_col
      FROM canonical_flights cf
    )

    -- Filter for localized evaluation set
    SELECT *
    FROM split AS s
    WHERE s.data_split_col='EVAL'
      AND s.origin IN UNNEST(@HUBS)
  )
);
