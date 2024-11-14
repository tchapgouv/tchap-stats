/*
   vue matérialisée qui agrege les données de user_daily_visits par utilisateur et par jour
   le refresh dure quelques heures
*/
/*
trop lourde, fonctionne mal

CREATE MATERIALIZED VIEW IF NOT EXISTS daily_unique_user_count AS
SELECT
  date_trunc('day', visit_ts) AS day,
  user_id,
  instance,
  domain,
  COUNT(*) AS visits_count,
  COUNT(CASE
    WHEN user_agent LIKE 'Mozilla%' THEN 1
    ELSE NULL
  END) AS web_visits_count,
  COUNT(CASE
    WHEN user_agent LIKE 'Tchap%Android%' OR
         user_agent LIKE 'RiotNSE/2%iOS%' OR
         user_agent LIKE 'RiotSharedExtension/2%iOS%' OR
         user_agent LIKE 'Tchap%iOS%' OR
         user_agent LIKE 'Riot%iOS' OR
         user_agent LIKE 'Riot%Android' OR
         user_agent LIKE 'Element%Android' OR
         user_agent LIKE 'Element%iOS'
    THEN 1
    ELSE NULL
  END) AS mobile_visits_count,
  COUNT(CASE
    WHEN user_agent NOT LIKE 'Mozilla%' AND
         user_agent NOT LIKE 'Tchap%Android%' AND
         user_agent NOT LIKE 'RiotNSE/2%iOS%' AND
         user_agent NOT LIKE 'RiotSharedExtension/2%iOS%' AND
         user_agent NOT LIKE 'Tchap%iOS%' AND
         user_agent NOT LIKE 'Riot%iOS' AND
         user_agent NOT LIKE 'Riot%Android' AND
         user_agent NOT LIKE 'Element%Android' AND
         user_agent NOT LIKE 'Element%iOS'
    THEN 1
    ELSE NULL
  END) AS other_visits_count
FROM
  user_daily_visits
GROUP BY
  date_trunc('day', visit_ts),
  user_id,
  instance,
  domain;
  
CREATE INDEX IF NOT EXISTS idx_daily_unique_user_count_day ON daily_unique_user_count(day);
*/


/* a quoi sert cette vue? 
CREATE MATERIALIZED VIEW IF NOT EXISTS unique_user_daily_count_30d AS
WITH date_range AS (
  SELECT generate_series(
    CURRENT_DATE - INTERVAL '30 days',
    CURRENT_DATE,
    INTERVAL '1 day'
  )::date AS day
),
filtered_daily_unique_user_count AS (
  SELECT
    day,
    user_id
  FROM
    daily_unique_user_count
  WHERE
    day > CURRENT_DATE - INTERVAL '60 days' AND
    NOT (mobile_visits_count = 0 AND web_visits_count = 0 AND other_visits_count > 0)
),
unique_users_per_day AS (
  SELECT
    date_range.day,
    COUNT(DISTINCT filtered_daily_unique_user_count.user_id) AS unique_user_count
  FROM
    date_range
    LEFT JOIN filtered_daily_unique_user_count ON filtered_daily_unique_user_count.day BETWEEN date_range.day - INTERVAL '30 days' AND date_range.day - INTERVAL '1 day'
  GROUP BY
    date_range.day
)
SELECT
  day,
  unique_user_count
FROM
  unique_users_per_day;
*/ 