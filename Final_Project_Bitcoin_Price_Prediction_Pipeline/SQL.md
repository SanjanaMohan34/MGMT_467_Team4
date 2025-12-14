## First, let's check the batch data quality
batch_check_query = f"""
SELECT
  COUNT(*) AS total_rows,
  COUNTIF(Close IS NOT NULL) AS close_not_null,
  COUNTIF(Volume IS NOT NULL) AS volume_not_null,
  COUNTIF(Open IS NOT NULL) AS open_not_null,
  COUNTIF(High IS NOT NULL) AS high_not_null,
  COUNTIF(Low IS NOT NULL) AS low_not_null
FROM `{PROJECT_ID}.{BQ_DATASET}.{BATCH_ANALYTICS_VIEW}`
"""

## (previously, ML.EVALUATE reported only 37 training records despite LIMIT 10000)
create_combined_model_query = f"""
CREATE OR REPLACE MODEL `{PROJECT_ID}.{BQ_DATASET}.bitcoin_combined_predictor`
OPTIONS(
  model_type='LINEAR_REG',
  input_label_cols=['price_usd']
) AS
SELECT
  s.price_usd,
  COALESCE(s.change_percent_24h, 0) AS streaming_change_24h,
  COALESCE(s.volume_usd_24h, 0) AS streaming_volume_24h,
  COALESCE(b.Close, 0) AS batch_latest_close,
  COALESCE(b.Volume, 0) AS batch_latest_volume,
  COALESCE(b.Open, 0) AS batch_latest_open,
  COALESCE(b.High, 0) AS batch_latest_high,
  COALESCE(b.Low, 0) AS batch_latest_low,
  TIMESTAMP_DIFF(s.ingestion_time, TIMESTAMP(b.datetime), MINUTE) AS minutes_since_batch
FROM
  `{PROJECT_ID}.{BQ_DATASET}.{STREAMING_TABLE}` s
CROSS JOIN (
  -- Get the most recent batch data point that has non-NULL values
  SELECT
    COALESCE(Close, 0) AS Close,
    COALESCE(Volume, 0) AS Volume,
    COALESCE(Open, 0) AS Open,
    COALESCE(High, 0) AS High,
    COALESCE(Low, 0) AS Low,
    datetime
  FROM `{PROJECT_ID}.{BQ_DATASET}.{BATCH_ANALYTICS_VIEW}`
  WHERE Close IS NOT NULL  -- Only get rows with valid Close prices
  ORDER BY TIMESTAMP(datetime) DESC
  LIMIT 1
) b
WHERE
  s.price_usd IS NOT NULL
  AND s.ingestion_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY);
"""

##  Evaluating combined BQML model

evaluate_query = f"""
SELECT
  mean_absolute_error,
  mean_squared_error,
  mean_squared_log_error,
  median_absolute_error,
  r2_score,
  explained_variance
FROM
  ML.EVALUATE(MODEL `{PROJECT_ID}.{BQ_DATASET}.bitcoin_combined_predictor`)
"""

## ML.explain_predict

f"""
SELECT
  *
FROM
  ML.EXPLAIN_PREDICT(
    MODEL `{PROJECT_ID}.{BQ_DATASET}.bitcoin_combined_predictor`,
    (SELECT
       s.price_usd,
       COALESCE(s.change_percent_24h, 0) AS streaming_change_24h,
       COALESCE(s.volume_usd_24h, 0) AS streaming_volume_24h,
       COALESCE(b.Close, 0) AS batch_latest_close,
       COALESCE(b.Volume, 0) AS batch_latest_volume,
       COALESCE(b.Open, 0) AS batch_latest_open,
       COALESCE(b.High, 0) AS batch_latest_high,
       COALESCE(b.Low, 0) AS batch_latest_low,
       TIMESTAMP_DIFF(s.ingestion_time, TIMESTAMP(b.datetime), MINUTE) AS minutes_since_batch
     FROM `{PROJECT_ID}.{BQ_DATASET}.{STREAMING_TABLE}` s
     CROSS JOIN (
       SELECT Close, Volume, Open, High, Low, datetime
       FROM `{PROJECT_ID}.{BQ_DATASET}.{BATCH_ANALYTICS_VIEW}`
       WHERE Close IS NOT NULL
       ORDER BY TIMESTAMP(datetime) DESC LIMIT 1
     ) b
     ORDER BY s.ingestion_time DESC
     LIMIT 5),
    STRUCT(5 AS top_k_features)
  )
"""

## ML.Predict

f"""
SELECT
  s.ingestion_time,
  s.asset,
  s.price_usd AS actual_price,
  pred.predicted_price_usd,
  ABS(s.price_usd - pred.predicted_price_usd) AS prediction_error,
  ROUND((ABS(s.price_usd - pred.predicted_price_usd) / s.price_usd) * 100, 2) AS error_percentage,
  s.change_percent_24h,
  b.batch_latest_close
FROM
  ML.PREDICT(MODEL `{PROJECT_ID}.{BQ_DATASET}.bitcoin_combined_predictor`,
    (SELECT
       s.ingestion_time,
       s.asset,
       s.price_usd,
       COALESCE(s.change_percent_24h, 0) AS streaming_change_24h,
       COALESCE(s.volume_usd_24h, 0) AS streaming_volume_24h,
       COALESCE(b.Close, 0) AS batch_latest_close,
       COALESCE(b.Volume, 0) AS batch_latest_volume,
       COALESCE(b.Open, 0) AS batch_latest_open,
       COALESCE(b.High, 0) AS batch_latest_high,
       COALESCE(b.Low, 0) AS batch_latest_low,
       TIMESTAMP_DIFF(s.ingestion_time, TIMESTAMP(b.datetime), MINUTE) AS minutes_since_batch
     FROM `{PROJECT_ID}.{BQ_DATASET}.{STREAMING_TABLE}` s
     CROSS JOIN (
       SELECT Close, Volume, Open, High, Low, datetime
       FROM `{PROJECT_ID}.{BQ_DATASET}.{BATCH_ANALYTICS_VIEW}`
       WHERE Close IS NOT NULL
       ORDER BY TIMESTAMP(datetime) DESC LIMIT 1
     ) b
     ORDER BY s.ingestion_time DESC
     LIMIT 25)
  ) pred
JOIN `{PROJECT_ID}.{BQ_DATASET}.{STREAMING_TABLE}` s
  ON pred.ingestion_time = s.ingestion_time
CROSS JOIN (
  SELECT Close AS batch_latest_close
  FROM `{PROJECT_ID}.{BQ_DATASET}.{BATCH_ANALYTICS_VIEW}`
  WHERE Close IS NOT NULL
  ORDER BY TIMESTAMP(datetime) DESC LIMIT 1
) b
ORDER BY pred.ingestion_time DESC;
"""

## plotly

f"""
SELECT
  s.ingestion_time,
  s.price_usd AS actual_price,
  pred.predicted_price_usd,
  ABS(s.price_usd - pred.predicted_price_usd) AS error,
  s.change_percent_24h,
  b.batch_latest_close
FROM
  ML.PREDICT(MODEL `{PROJECT_ID}.{BQ_DATASET}.bitcoin_combined_predictor`,
    (SELECT
       s.ingestion_time,
       s.price_usd,
       COALESCE(s.change_percent_24h, 0) AS streaming_change_24h,
       COALESCE(s.volume_usd_24h, 0) AS streaming_volume_24h,
       COALESCE(b.Close, 0) AS batch_latest_close,
       COALESCE(b.Volume, 0) AS batch_latest_volume,
       COALESCE(b.Open, 0) AS batch_latest_open,
       COALESCE(b.High, 0) AS batch_latest_high,
       COALESCE(b.Low, 0) AS batch_latest_low,
       TIMESTAMP_DIFF(s.ingestion_time, TIMESTAMP(b.datetime), MINUTE) AS minutes_since_batch
     FROM `{PROJECT_ID}.{BQ_DATASET}.{STREAMING_TABLE}` s
     CROSS JOIN (
       SELECT Close, Volume, Open, High, Low, datetime
       FROM `{PROJECT_ID}.{BQ_DATASET}.{BATCH_ANALYTICS_VIEW}`
       WHERE Close IS NOT NULL
       ORDER BY TIMESTAMP(datetime) DESC LIMIT 1
     ) b
     ORDER BY s.ingestion_time DESC)
  ) pred
JOIN `{PROJECT_ID}.{BQ_DATASET}.{STREAMING_TABLE}` s
  ON pred.ingestion_time = s.ingestion_time
CROSS JOIN (
  SELECT Close AS batch_latest_close
  FROM `{PROJECT_ID}.{BQ_DATASET}.{BATCH_ANALYTICS_VIEW}`
  WHERE Close IS NOT NULL
  ORDER BY TIMESTAMP(datetime) DESC LIMIT 1
) b
ORDER BY s.ingestion_time ASC;
"""

## looker studio data

f"""
CREATE OR REPLACE VIEW `{VIEW_ID}` AS
WITH
-- 1. Get the latest Close price from your batch data (yesterday's close)
latest_batch AS (
  SELECT
    Close AS last_batch_close
  FROM `{PROJECT_ID}.bitcoin_data_set.bitcoin_analytics_view`
  ORDER BY datetime DESC
  LIMIT 1
)
-- 2. Combine all streaming data with the single latest batch price
SELECT
  t1.ingestion_time,
  t1.price_usd,
  t2.last_batch_close
FROM `{PROJECT_ID}.bitcoin_data_set.bitcoin_streaming` AS t1
CROSS JOIN latest_batch AS t2
"""

f"{PROJECT_ID}.bitcoin_data_set.bitcoin_realtime_vs_batch_v"
sql = f"""
CREATE OR REPLACE VIEW `{VIEW_ID}` AS
WITH
-- 1. Finds the single latest closing price from the batch table
latest_batch AS (
  SELECT
    Close AS last_batch_close
  FROM `{PROJECT_ID}.bitcoin_data_set.bitcoin_analytics_view`
  ORDER BY datetime DESC
  LIMIT 1
)
-- 2. Cross-joins this single price to every streaming row
SELECT
  t1.ingestion_time,
  t1.price_usd,
  t2.last_batch_close
FROM `{PROJECT_ID}.bitcoin_data_set.bitcoin_streaming` AS t1
CROSS JOIN latest_batch AS t2;
"""

f"{PROJECT_ID}.{DATASET}.latest_live_price_v"
sql_live = f"""
CREATE OR REPLACE VIEW `{VIEW_ID_LIVE}` AS
SELECT
  price_usd
FROM
  `{PROJECT_ID}.{DATASET}.{STREAMING_TABLE}`
QUALIFY ROW_NUMBER() OVER (ORDER BY ingestion_time DESC) = 1
"""

## ML.predict

f"""
CREATE OR REPLACE VIEW `{ML_PREDICTIONS_VIEW_ID}` AS
SELECT
  predictions.ingestion_time AS prediction_time,
  predictions.predicted_price_usd AS predicted_price,
  ABS(streaming.price_usd - predictions.predicted_price_usd) AS average_absolute_error -- Calculate the absolute error
FROM
  ML.PREDICT(
    MODEL `{PROJECT_ID}.{BQ_DATASET}.bitcoin_combined_predictor`,
    (SELECT
       s.ingestion_time,
       s.price_usd, -- Include actual price for error calculation
       COALESCE(s.change_percent_24h, 0) AS streaming_change_24h,
       COALESCE(s.volume_usd_24h, 0) AS streaming_volume_24h,
       COALESCE(b.Close, 0) AS batch_latest_close,
       COALESCE(b.Volume, 0) AS batch_latest_volume,
       COALESCE(b.Open, 0) AS batch_latest_open,
       COALESCE(b.High, 0) AS batch_latest_high,
       COALESCE(b.Low, 0) AS batch_latest_low,
       TIMESTAMP_DIFF(s.ingestion_time, TIMESTAMP(b.datetime), MINUTE) AS minutes_since_batch
     FROM `{PROJECT_ID}.{BQ_DATASET}.{STREAMING_TABLE}` s
     CROSS JOIN (
       SELECT Close, Volume, Open, High, Low, datetime
       FROM `{PROJECT_ID}.{BQ_DATASET}.{BATCH_ANALYTICS_VIEW}`
       WHERE Close IS NOT NULL
       ORDER BY TIMESTAMP(datetime) DESC LIMIT 1
     ) b
     ORDER BY s.ingestion_time DESC
     LIMIT 25) -- Use a limited set of recent streaming data for predictions
  ) AS predictions
JOIN `{PROJECT_ID}.{BQ_DATASET}.{STREAMING_TABLE}` AS streaming
  ON predictions.ingestion_time = streaming.ingestion_time
ORDER BY prediction_time DESC
"""

