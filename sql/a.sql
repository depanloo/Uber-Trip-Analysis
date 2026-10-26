-- poin 1

with base_data as (
  select *,
  -- convert miles dan speed ke km dan km/h
  miles * 1.60934 as distance_km,
  speed * 1.60934 as speed_kmh,
  -- beri keterangan day type
  case 
    when day in ('Saturday', 'Sunday') then 'Weekend'
    else 'Weekday' end as day_type
  from `uber-trip-analysis-512812.uber.uber_clean`
)

select 
  category, day_type,
  count(*) as total_trip,
  round(count(*)/count(distinct start_date),2) as avg_trip_per_day,
  round(avg(case when duration > 0 then duration end), 2) as avg_duration_minutes,
  round(avg(distance_km), 2) as avg_distance_km,
  round(avg(case when duration > 0 then speed_kmh end), 2) as avg_speed_kmh
from base_data
group by 1, 2;
