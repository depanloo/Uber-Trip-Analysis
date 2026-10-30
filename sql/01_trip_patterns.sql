-- 01_trip_patterns.sql
-- Objective 1: trip volume, duration, distance and speed by category and day type.
--
-- Notes
--   * avg_trip_per_active_day = trips / number of distinct dates that had at least
--     one trip in that group (not per calendar day).
--   * Duration and speed averages exclude the 4 trips with duration = 0.
--   * Median distance is included because the mean is pulled up by a few very long
--     trips (max = 499 km).

WITH summary AS (
  SELECT
    category,
    day_type,
    COUNT(*) AS total_trip,
    ROUND(COUNT(*) / COUNT(DISTINCT start_date), 2) AS avg_trip_per_active_day,
    ROUND(AVG(IF(duration > 0, duration, NULL)), 2) AS avg_duration_minutes,
    ROUND(AVG(distance_km), 2) AS avg_distance_km,
    ROUND(AVG(IF(duration > 0, speed_kmh, NULL)), 2) AS avg_speed_kmh
  FROM `uber-trip-analysis-512812.uber.uber_trips`
  GROUP BY 1, 2
),

medians AS (
  SELECT DISTINCT
    category,
    day_type,
    ROUND(PERCENTILE_CONT(distance_km, 0.5) OVER (PARTITION BY category, day_type), 2) AS median_distance_km
  FROM `uber-trip-analysis-512812.uber.uber_trips`
)

SELECT
  s.*,
  m.median_distance_km
FROM summary AS s
JOIN medians AS m USING (category, day_type)
ORDER BY category, day_type;
