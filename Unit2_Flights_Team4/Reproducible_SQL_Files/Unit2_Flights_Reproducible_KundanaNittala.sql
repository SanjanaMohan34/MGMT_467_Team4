
-- 0 -- CONFIG & VARIABLES
======================================================
DECLARE PROJECT_ID STRING DEFAULT 'mgmt-467-55510';
DECLARE DATASET_ID STRING DEFAULT 'unit2_flights';
DECLARE TABLE_PATH STRING DEFAULT 'mgmt-467-55510.unit2_flights.flights_data_2023_1_from_gcs';

-- Classification hyperparameters/costs (can be tuned)
DECLARE THRESH FLOAT64 DEFAULT 0.75;
DECLARE C_FP INT64 DEFAULT 1000;
DECLARE C_FN INT64 DEFAULT 6000;

-- Model names (built dynamically)
DECLARE MODEL_BASE STRING;
DECLARE MODEL_ENG STRING;
DECLARE MODEL_REG STRING;

-- Assign model names after declarations
SET MODEL_BASE = FORMAT("%s.%s.clf_diverted_base", PROJECT_ID, DATASET_ID);
SET MODEL_ENG = FORMAT("%s.%s.clf_diverted_engineered", PROJECT_ID, DATASET_ID);
SET MODEL_REG = FORMAT("%s.%s.reg_arr_delay", PROJECT_ID, DATASET_ID);

-- Create schema if needed
EXECUTE IMMEDIATE FORMAT("""
CREATE SCHEMA IF NOT EXISTS %s.%s;
""", PROJECT_ID, DATASET_ID);



-- 1) BASELINE CLASSIFICATION MODEL — LOGISTIC_REG (TRAINING BLOCK)
-- ... (Full SQL to create model $MODEL_BASE) ...



-- 2) ENGINEERED CLASSIFICATION MODEL — LOGISTIC_REG with TRANSFORM (TRAINING BLOCK)
-- ... (Full SQL to create model $MODEL_ENG) ...



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
    CAST(distance  AS FLOAT64) AS distance,
    CAST(Reporting_Airline AS STRING) AS carrier,
    CAST(Origin AS STRING) AS origin,
    CAST(Dest AS STRING) AS dest,
    CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
  FROM `${TABLE_PATH}`
  WHERE DepDelay IS NOT NULL AND ArrDelay IS NOT NULL -- Required filter for regression

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
    CAST(distance  AS FLOAT64) AS distance,
    CAST(Reporting_Airline AS STRING) AS carrier,
    CAST(Origin AS STRING) AS origin,
    CAST(Dest AS STRING) AS dest,
    CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
  FROM `${TABLE_PATH}`
  WHERE DepDelay IS NOT NULL AND ArrDelay IS NOT NULL -- Required filter for regression

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
    CAST(distance  AS FLOAT64) AS distance,
    CAST(Reporting_Airline AS STRING) AS carrier,
    CAST(Origin AS STRING) AS origin,
    CAST(Dest AS STRING) AS dest,
    CAST((CASE WHEN SAFE_CAST(Diverted AS INT64)=1 OR LOWER(CAST(Diverted AS STRING))='true' THEN TRUE ELSE FALSE END) AS BOOL) AS diverted
  FROM `${TABLE_PATH}`
  WHERE DepDelay IS NOT NULL AND ArrDelay IS NOT NULL -- Required filter for regression

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
