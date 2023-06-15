/** Subscription **/
CREATE TABLE IF NOT EXISTS subscriptions_aggregate (
  subscriptions INTEGER NOT NULL,
  domain VARCHAR NOT NULL,
  hour timestamp with time zone NOT NULL,
  instance VARCHAR NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS unique_subscriptions_idx ON subscriptions_aggregate (domain, hour, instance);

/** Events **/
CREATE TABLE IF NOT EXISTS events_aggregate (
  events INTEGER NOT NULL,
  domain VARCHAR NOT NULL,
  hour timestamp with time zone NOT NULL,
  instance VARCHAR NOT NULL,
  type VARCHAR NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS unique_events_idx ON events_aggregate (domain, hour, instance, type);

-- Index on event datetime, increasing select performance
CREATE INDEX IF NOT EXISTS events_aggregate_hour_to_week ON events_aggregate (hour);

/** User Daily Visits **/
CREATE TABLE IF NOT EXISTS user_daily_visits (
  user_id VARCHAR NOT NULL,
  device_id VARCHAR NOT NULL,
  visit_ts timestamp with time zone NOT NULL,
  user_agent VARCHAR NOT NULL,
  instance VARCHAR NOT NULL,
  domain VARCHAR NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS unique_user_daily_idx ON user_daily_visits (user_id, device_id, visit_ts);
CREATE INDEX IF NOT EXISTS user_daily_visit_ts_idx ON user_daily_visits (visit_ts);
CREATE INDEX IF NOT EXISTS user_visit_user_id_visit_ts_idx ON user_daily_visits (user_id, visit_ts);


/** User Monthly Visits **/
CREATE MATERIALIZED VIEW IF NOT EXISTS user_monthly_visits AS
SELECT device_id,
date_trunc('month', visit_ts) as month,
user_id,
instance,
domain,
CASE
WHEN user_agent LIKE 'Mozilla%Windows%Firefox%' THEN 'Firefox Windows'
WHEN user_agent LIKE 'Mozilla%Windows%Chrome%' THEN 'Chrome Windows'
WHEN user_agent LIKE 'Mozilla%Windows%Trident%' THEN 'Internet Explorer Windows'
WHEN user_agent LIKE 'Mozilla%Mac OS%Firefox%' THEN 'Firefox Mac OS'
WHEN user_agent LIKE 'Mozilla%Mac OS%Chrome%' THEN 'Chrome Mac OS'
WHEN user_agent LIKE 'Mozilla%Mac OS%Safari%' THEN 'Safari Mac OS'
WHEN user_agent LIKE 'Mozilla%Android%Firefox%' THEN 'Firefox Android'
WHEN user_agent LIKE 'Mozilla%Android%Chrome%' THEN 'Chrome Android'
WHEN user_agent LIKE 'Mozilla%Linux%Firefox%' THEN 'Firefox Linux'
WHEN user_agent LIKE 'Mozilla%Linux%Chrome%' THEN 'Chrome Linux'
WHEN user_agent LIKE 'Mozilla%CrOS%Chrome%' THEN 'Chrome OS'
WHEN user_agent LIKE 'Mozilla%Mobile%' THEN 'Navigateur Mobile'
WHEN user_agent LIKE 'Mozilla%' THEN 'Autre Navigateur'
WHEN user_agent LIKE 'Tchap%NEO%' THEN 'Tchap Android NEO'
WHEN user_agent LIKE 'Tchap%Android%' THEN 'Tchap Android'
WHEN user_agent LIKE 'RiotNSE/2%iOS%' THEN 'Tchap iOS'
WHEN user_agent LIKE 'RiotSharedExtension/2%iOS%' THEN 'Tchap iOS'
WHEN user_agent LIKE 'Tchap%iOS%' THEN 'Tchap iOS'
WHEN user_agent LIKE 'Riot%' THEN 'Element'
WHEN user_agent LIKE 'Element%' THEN 'Element'
ELSE 'Autre'
END as device_type,
CASE
WHEN user_agent LIKE 'Mozilla%' THEN 'Web'
WHEN user_agent LIKE 'Tchap%Android%' THEN 'Mobile'
WHEN user_agent LIKE 'RiotNSE/2%iOS%' THEN 'Mobile'
WHEN user_agent LIKE 'RiotSharedExtension/2%iOS%' THEN 'Mobile'
WHEN user_agent LIKE 'Tchap%iOS%' THEN 'Mobile'
WHEN user_agent LIKE 'Riot%iOS' THEN 'Mobile'
WHEN user_agent LIKE 'Riot%Android' THEN 'Mobile'
WHEN user_agent LIKE 'Element%Android' THEN 'Mobile'
WHEN user_agent LIKE 'Element%iOS' THEN 'Mobile'
ELSE 'Autre'
END as platform
FROM user_daily_visits
WHERE user_agent != 'matrix-media-repo' /** We remove matrix-media-repo they are duplicate between Tchap iOS and Android **/
GROUP BY device_id, month, user_id, instance, domain, device_type, platform;

CREATE INDEX IF NOT EXISTS idx_month ON user_monthly_visits (month);
CREATE UNIQUE INDEX IF NOT EXISTS user_monthly_visits_index ON user_monthly_visits (month,device_id,user_id,device_type);
CREATE INDEX IF NOT EXISTS;


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
