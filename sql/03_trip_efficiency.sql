-- 03_trip_efficiency.sql
-- Objective 3: how fast are trips, and which hours / purposes are slowest?
-- Four independent statements. Run each one separately (highlight it, then Run).
--
-- Notes
--   * Efficiency is based on each trip's average speed (rule defined in 00_create_view.sql).
--   * Trips with duration = 0 have efficiency_category = NULL and are excluded (1,136 trips remain).
--   * Low speed is NOT proof of congestion: short trips are slow on average
--     (see Statement 2). Treat the hour and purpose rankings as indicative.
--   * Hours / purposes with fewer than 10 trips are skipped to avoid noisy percentages.

-- Statement 1: efficiency breakdown by day type
SELECT
  day_type,
  efficiency_category,
  COUNT(*) AS total_trip,
  ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY day_type), 2) AS pct_of_day_type,
  ROUND(AVG(duration), 2) AS avg_duration_minutes,
  ROUND(AVG(distance_km), 2) AS avg_distance_km,
  ROUND(AVG(speed_kmh), 2) AS avg_speed_kmh
FROM `uber-trip-analysis-512812.uber.uber_trips`
WHERE efficiency_category IS NOT NULL
GROUP BY 1, 2
ORDER BY day_type, avg_speed_kmh DESC;

-- Statement 2: is "inefficient" mostly a short-trip effect?
SELECT
  IF(distance_km < 5, 'Under 5 km', '5 km or more') AS distance_band,
  COUNT(*) AS total_trips,
  COUNTIF(efficiency_category = 'Inefficient') AS inefficient_trips,
  ROUND(100 * COUNTIF(efficiency_category = 'Inefficient') / COUNT(*), 1) AS inefficient_pct
FROM `uber-trip-analysis-512812.uber.uber_trips`
WHERE efficiency_category IS NOT NULL
GROUP BY 1
ORDER BY 1;

-- Statement 3: top 5 start hours by share of inefficient trips, per day type
WITH hourly AS (
  SELECT
    day_type,
    CAST(start_hour AS INT64) AS start_hour,
    COUNT(*) AS total_trips,
    COUNTIF(efficiency_category = 'Inefficient') AS inefficient_trips
  FROM `uber-trip-analysis-512812.uber.uber_trips`
  WHERE efficiency_category IS NOT NULL
  GROUP BY 1, 2
)
SELECT
  day_type,
  start_hour,
  inefficient_trips,
  total_trips,
  ROUND(100 * inefficient_trips / total_trips, 2) AS inefficient_pct
FROM hourly
WHERE total_trips >= 10
QUALIFY ROW_NUMBER() OVER (PARTITION BY day_type ORDER BY inefficient_trips / total_trips DESC) <= 5
ORDER BY day_type, inefficient_pct DESC;

-- Statement 4: top 3 trip purposes by share of inefficient trips, per day type
WITH purpose_summary AS (
  SELECT
    day_type,
    purpose,
    COUNT(*) AS total_trips,
    COUNTIF(efficiency_category = 'Inefficient') AS inefficient_trips
  FROM `uber-trip-analysis-512812.uber.uber_trips`
  WHERE efficiency_category IS NOT NULL
  GROUP BY 1, 2
)
SELECT
  day_type,
  purpose,
  inefficient_trips,
  total_trips,
  ROUND(100 * inefficient_trips / total_trips, 2) AS inefficient_pct
FROM purpose_summary
WHERE total_trips >= 10
QUALIFY ROW_NUMBER() OVER (PARTITION BY day_type ORDER BY inefficient_trips / total_trips DESC) <= 3
ORDER BY day_type, inefficient_pct DESC;
