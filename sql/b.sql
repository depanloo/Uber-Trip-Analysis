-- poin 2 
-- total trip per jam pada weekend dan weekday
-- top 10 hari dan jam tersibuk

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

-- weekend
-- select start_hour, count(*) as count_trip_weekend
-- from base_data
-- where day_type = 'Weekend'
-- group by 1 order by start_hour;

-- weekday
-- select start_hour, count(*) as count_trip_weekday
-- from base_data
-- where day_type = 'Weekday'
-- group by 1 order by start_hour;

-- top 10 hari dan jam tersibuk (peak hour)
select day, start_hour, count(*) as count_trip
from base_data
group by 1, 2
order by count(*) desc limit 10;