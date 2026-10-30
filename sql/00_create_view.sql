-- 00_create_view.sql
-- Base view used by every analysis query. Run this FIRST.
--
-- Data notes
--   * `miles` and `speed` in uber_clean are ALREADY in km and km/h
--     (the cleaning step converted them), so they are only renamed here.
--     Do NOT multiply them by 1.60934 again.
--   * SELECT DISTINCT removes 1 exact duplicate trip (1,141 -> 1,140 rows).
--   * 4 trips have duration = 0 (speed is undefined), so efficiency_category
--     is NULL for them and they are left out of all speed-based metrics.
--
-- Efficiency rule (average speed of the trip)
--   Efficient   : > 40 km/h
--   Moderate    : 25 - 40 km/h
--   Inefficient : < 25 km/h

CREATE OR REPLACE VIEW `uber-trip-analysis-512812.uber.uber_trips` AS
SELECT DISTINCT
  * EXCEPT (miles, speed),
  miles AS distance_km,
  speed AS speed_kmh,
  CASE
    WHEN day IN ('Saturday', 'Sunday') THEN 'Weekend'
    ELSE 'Weekday'
  END AS day_type,
  CASE
    WHEN duration <= 0 THEN NULL
    WHEN speed > 40 THEN 'Efficient'
    WHEN speed >= 25 THEN 'Moderate'
    ELSE 'Inefficient'
  END AS efficiency_category
FROM `uber-trip-analysis-512812.uber.uber_clean`;
