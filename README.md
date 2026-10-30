# 🚗 Uber Trip Data Analysis (SQL · BigQuery)

**TL;DR:** SQL analysis of **1,140 trips** from one rider's 2016 Uber trip log, built in Google BigQuery. It profiles trip patterns (Business vs Personal, weekday vs weekend), finds peak demand hours, and classifies trips by average speed. Main findings: **93% of trips are Business**, weekday demand peaks at **13:00** and weekend demand at **18:00**, and only **34% of trips average above 40 km/h** while **28% fall below 25 km/h**. Most slow trips are short ones, so low speed should not be read as congestion.

| | |
|---|---|
| **Tools** | Google BigQuery (SQL: CTEs, window functions, `QUALIFY`, `COUNTIF`, `PERCENTILE_CONT`), Python + Matplotlib (chart) |
| **Type** | Individual project |
| **Data** | `data/UberDatasetCleaned.csv`, public personal trip-log dataset. *Source link: add here.* |

---

## 1. Questions
1. How do trip volume, duration and distance differ by **category** (Business vs Personal) and **day type** (weekday vs weekend)?
2. **When** is demand highest, by hour and by day?
3. How **fast** are trips, and which hours and purposes have the most slow trips?

## 2. Data & Process
* **Dataset:** 1,141 raw rows, 17 columns, one row per trip. Trips cover **1 Jan – 31 Dec 2016** (294 distinct dates), mostly starting around Cary and Morrisville. This is a **single rider's log**, not Uber platform data, so it has no fares, drivers, wait times or revenue.
* **Cleaning (documented in `sql/00_create_view.sql`):**
  * Removed **1 exact duplicate** trip → 1,140 trips.
  * **4 trips have duration = 0**, so speed is undefined. They are kept for volume counts but excluded from speed and efficiency metrics (1,136 trips analyzed there).
  * `distance` and `speed` in the cleaned file are **already in km and km/h**, so no further unit conversion is applied in SQL.
* **Definitions:**
  * *Avg trip per active day* = trips ÷ distinct dates with at least one trip.
  * *Avg speed* = mean of each trip's speed (km/h).
  * *Efficiency* by trip speed: **Efficient** > 40 km/h · **Moderate** 25–40 km/h · **Inefficient** < 25 km/h.

## 3. Results

### A. Trip patterns by category

| Category | Day type | Trips | Avg trips / active day | Avg duration (min) | Avg distance (km) | Median distance (km) | Avg speed (km/h) |
| :--- | :--- | ---: | ---: | ---: | ---: | ---: | ---: |
| Business | Weekday | 795 | 3.79 | 22.63 | 15.66 | 9.66 | 44.30 |
| Business | Weekend | 270 | 3.55 | 23.76 | 18.48 | 9.82 | 41.59 |
| Personal | Weekday | 52 | 2.36 | 15.46 | 9.62 | 5.55 | 32.53 |
| Personal | Weekend | 23 | 2.30 | 31.78 | 27.67 | 10.78 | 36.22 |

* **Business dominates:** 1,065 of 1,140 trips (93.4%), with 795 on weekdays.
* **A typical business trip is about 10 km on both weekdays and weekends** (median 9.66 vs 9.82 km). Averages are higher because a few very long trips pull them up (longest trip: 499 km), so medians describe typical trips better.
* **Personal weekend trips are the longest on average** (27.67 km, 31.78 min), but there are only 23 of them and the median is 10.78 km, so a handful of long trips drive this.

### B. Peak hours

![Hourly trip distribution](assets/hourly_trip_distribution.png)

* **Weekdays:** demand rises from 08:00 (31 trips), stays high through the day, and peaks at **13:00 (81 trips)**.
* **Weekends:** demand is spread across the afternoon and peaks at **18:00 (29 trips)**.

**Top 10 busiest day + hour combinations** (totals over the year):

| Rank | Day | Start hour | Trips |
| :---: | :--- | :---: | :---: |
| 1 | Friday | 11:00 | 24 |
| 2 | Friday | 13:00 | 24 |
| 3 | Tuesday | 13:00 | 18 |
| 4 | Tuesday | 17:00 | 18 |
| 5 | Wednesday | 17:00 | 18 |
| 6 | Friday | 15:00 | 17 |
| 7 | Monday | 14:00 | 17 |
| 8 | Saturday | 17:00 | 17 |
| 9 | Sunday | 18:00 | 17 |
| 10 | Thursday | 18:00 | 17 |

* **Friday is the busiest day**, holding the top two slots.
* **Five of the top 10 slots fall at 17:00 or 18:00**, the evening rush.

### C. Trip efficiency (1,136 trips with valid speed)

| Day type | Efficiency | Trips | % of day type | Avg duration (min) | Avg distance (km) | Avg speed (km/h) |
| :--- | :--- | ---: | ---: | ---: | ---: | ---: |
| Weekday | Efficient | 272 | 32.2% | 26.40 | 28.93 | 79.58 |
| Weekday | Moderate | 335 | 39.7% | 19.46 | 10.56 | 32.50 |
| Weekday | Inefficient | 237 | 28.1% | 21.23 | 6.04 | 17.92 |
| Weekend | Efficient | 113 | 38.7% | 31.89 | 35.78 | 64.99 |
| Weekend | Moderate | 99 | 33.9% | 20.97 | 11.45 | 32.42 |
| Weekend | Inefficient | 80 | 27.4% | 18.04 | 5.55 | 18.35 |

* **Overall:** 33.9% of trips are Efficient, 38.2% Moderate and 27.9% Inefficient.
* **Slow trips are mostly short trips.** 59.6% of trips under 5 km are "Inefficient" (204 of 342), against 14.2% for trips of 5 km or more (113 of 794). Inefficient trips average only about 6 km. Low average speed therefore reflects short hops, stops and parking at least as much as traffic.

**Start hours with the highest share of inefficient trips** (hours with at least 10 trips):

| Day type | Hour | Inefficient / total | Inefficient % |
| :--- | :---: | :---: | ---: |
| Weekday | 16:00 | 27 / 69 | 39.13% |
| Weekday | 19:00 | 17 / 47 | 36.17% |
| Weekday | 18:00 | 23 / 65 | 35.38% |
| Weekday | 17:00 | 23 / 67 | 34.33% |
| Weekday | 08:00 | 10 / 31 | 32.26% |
| Weekend | 13:00 | 7 / 13 | 53.85% |
| Weekend | 10:00 | 7 / 14 | 50.00% |
| Weekend | 11:00 | 5 / 12 | 41.67% |
| Weekend | 15:00 | 9 / 26 | 34.62% |
| Weekend | 14:00 | 8 / 26 | 30.77% |

**Purposes with the highest share of inefficient trips** (top 3 per day type, at least 10 trips):

| Day type | Purpose | Inefficient / total | Inefficient % |
| :--- | :--- | :---: | ---: |
| Weekday | Errand/Supplies | 48 / 123 | 39.02% |
| Weekday | Meal/Entertain | 56 / 180 | 31.11% |
| Weekday | Airport/Travel | 12 / 39 | 30.77% |
| Weekend | Customer Visit | 12 / 31 | 38.71% |
| Weekend | Meeting | 28 / 85 | 32.94% |
| Weekend | Errand/Supplies | 16 / 50 | 32.00% |

* **Weekday late afternoon (16:00–19:00)** has three of the five highest inefficiency rates, with 16:00 the highest at 39.1%.
* **Errand/Supplies** trips are the most often slow on weekdays (39.0%), consistent with short, stop-and-go errands.
* **Weekend hours rest on 12–14 trips each** (for example 7 of 13 at 13:00), so those percentages are indicative only.

## 4. Limitations
* **One rider, one year:** the findings describe this person's trips, not Uber demand in general. No fares, drivers, wait times or revenue are available, so operational questions (driver supply, pricing, promotions) cannot be answered.
* **Speed is a rough proxy for efficiency.** Trip speed is distance ÷ duration; it does not separate traffic from trip length, parking or stops. There is no route or road-condition data.
* **Small samples:** 23 Personal weekend trips, and several hour-level percentages based on 12–14 trips.
* **Peak-hour counts are yearly totals**, not per-day averages, and the data is not adjusted for the number of weekdays vs weekend days.
* Descriptive analysis only; no statistical testing.

## 5. Possible Next Steps
* Add road distance or map-matched travel time to separate congestion from short-trip effects.
* Break the hourly pattern down by month to check seasonality.
* Repeat the analysis on platform-level data (fares, wait time, supply) to answer operational questions.

## 6. Repository Structure
```
├── README.md
├── assets/
│   └── hourly_trip_distribution.png     # Hourly demand chart
├── data/
│   └── UberDatasetCleaned.csv           # Cleaned trip log (1,141 rows)
└── sql/
    ├── 00_create_view.sql               # Base view: dedup, units, day type, efficiency rule
    ├── 01_trip_patterns.sql             # Section A
    ├── 02_peak_hours.sql                # Section B
    └── 03_trip_efficiency.sql           # Section C
```

**To reproduce:** load `data/UberDatasetCleaned.csv` into BigQuery as `uber.uber_clean` (schema auto-detect), replace the project ID `uber-trip-analysis-512812` in the SQL files with your own, run `00_create_view.sql` first, then the other files. In files with several statements, run each statement separately.
