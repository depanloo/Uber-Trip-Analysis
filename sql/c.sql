-- poin 3

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
),

threshold as (
  select *,
    case
      when speed_kmh > 40 then 'Efficient'
      when speed_kmh between 25 and 40 then 'Moderate'
      else 'Inefficient'
    end as efficiency_category
  from base_data
),

horly_summary as (
  select
    day_type,
    start_hour,
    count(*) as total_trips,
    countif(efficiency_category = 'Inefficient') as inefficient_trips
  from threshold
  group by 1, 2
),

purpose_summary as (
  select
    day_type,
    purpose,
    count(*) as total_trips,
    countif(efficiency_category = 'Inefficient') as inefficient_trips
  from threshold
  group by 1, 2
)

-- select
--   day_type,
--   efficiency_category,
--   count(*) total_trip,
--   round(avg(case when duration > 0 then duration end), 2) as avg_duration_minutes,
--   round(avg(distance_km), 2) as avg_distance_km,
--   round(avg(case when duration > 0 then speed_kmh end), 2) as avg_speed_kmh
-- from threshold
-- group by 1,2 order by 1,2;

-- select
--   day_type,
--   start_hour,
--   inefficient_trips,
--   total_trips,
--   round((inefficient_trips/total_trips)*100, 2) as inefficient_percentage
-- from horly_summary
-- where total_trips > 10
-- qualify row_number() over (partition by day_type order by inefficient_trips/total_trips desc) <= 5
-- order by 1, 5 desc;

select
  day_type,
  purpose,
  inefficient_trips,
  total_trips,
  round((inefficient_trips/total_trips)*100, 2) as inefficient_percentage
from purpose_summary
-- where total_trips > 10
qualify row_number() over (partition by day_type order by inefficient_trips/total_trips desc) <= 2
order by 1, 5 desc;


