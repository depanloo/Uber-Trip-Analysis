-- 02_peak_hours.sql
-- Objective 2: when is demand highest?
-- Two independent statements. Run each one separately (highlight it, then Run).
-- Counts are totals over the whole year (Jan-Dec 2016), not per-day averages.

-- Statement 1: trips per start hour, weekday vs weekend
SELECT
  CAST(start_hour AS INT64) AS start_hour,
  COUNTIF(day_type = 'Weekday') AS trips_weekday,
  COUNTIF(day_type = 'Weekend') AS trips_weekend
FROM `uber-trip-analysis-512812.uber.uber_trips`
GROUP BY 1
ORDER BY 1;

-- Statement 2: top 10 busiest day + hour combinations
-- (ties are broken by day name, then hour, so the result is reproducible)
SELECT
  day,
  CAST(start_hour AS INT64) AS start_hour,
  COUNT(*) AS trip_count
FROM `uber-trip-analysis-512812.uber.uber_trips`
GROUP BY 1, 2
ORDER BY trip_count DESC, day, start_hour
LIMIT 10;
