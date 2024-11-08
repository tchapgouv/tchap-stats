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

/** User Daily Visits 
* in fact it is more device daily visits as one line links to a device_id
**/
CREATE TABLE IF NOT EXISTS user_daily_visits (
  user_id VARCHAR NOT NULL,
  device_id VARCHAR NOT NULL,
  visit_ts timestamp with time zone NOT NULL,
  user_agent VARCHAR NOT NULL,
  instance VARCHAR NOT NULL,
  domain VARCHAR NOT NULL,
  platform VARCHAR, /* can be null */
  device_type VARCHAR /* can be null */
  visit_date DATE /* can be null */
);

/* tables have been altered */ 
/* 

ALTER TABLE user_daily_visits
ADD COLUMN platform VARCHAR;

ALTER TABLE user_daily_visits
ADD COLUMN device_type VARCHAR;

ALTER TABLE user_daily_visits
ADD COLUMN visit_date DATE;

*/




CREATE UNIQUE INDEX IF NOT EXISTS unique_user_daily_idx ON user_daily_visits (user_id, device_id, visit_ts);
CREATE INDEX IF NOT EXISTS user_daily_visit_ts_idx ON user_daily_visits (visit_ts);
CREATE INDEX IF NOT EXISTS user_visit_user_id_visit_ts_idx ON user_daily_visits (user_id, visit_ts);
CREATE INDEX IF NOT EXISTS user_daily_visits_visit_ts_desc_idx ON user_daily_visits (visit_ts DESC);
CREATE INDEX IF NOT EXISTS user_daily_visits_visit_date_desc_idx ON user_daily_visits (visit_date DESC);


/* ajouter des colonnes */
ALTER TABLE user_daily_visits
ADD COLUMN platform VARCHAR;

/* ajouter des colonnes */
ALTER TABLE user_daily_visits
ADD COLUMN device_type VARCHAR;



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

/** Pushers aggregate data 
user_name, device_id, app_id, kind, enabled, instance, domain
**/
CREATE TABLE IF NOT EXISTS pushers_aggregate (
  user_name VARCHAR NOT NULL,
  device_id VARCHAR NOT NULL,
  app_id VARCHAR,
  kind VARCHAR ,
  is_enabled BOOLEAN,
  instance VARCHAR NOT NULL,
  domain VARCHAR NOT NULL,
  added_date DATE NOT NULL DEFAULT current_date   -- new column to store added date
);

/* this unique index is optimized to group on date/kind */
CREATE UNIQUE INDEX IF NOT EXISTS pushers_aggregate_unique ON pushers_aggregate (added_date, kind, app_id,device_id);
CREATE INDEX IF NOT EXISTS pushers_aggregate_kind_idx ON pushers_aggregate (kind);



/** Accounts data aggregate data 
user_id	account_data_type	content	instance domain
**/
CREATE TABLE IF NOT EXISTS account_data_aggregate (
  user_id VARCHAR NOT NULL,
  account_data_type VARCHAR NOT NULL,
  content VARCHAR,
  instance VARCHAR NOT NULL,
  domain VARCHAR NOT NULL
);

/* create a unique index to avoid duplicates when importing data */
CREATE INDEX IF NOT EXISTS unique_account_data_aggregate_idx ON account_data_aggregate (user_id, account_data_type);
CREATE INDEX IF NOT EXISTS account_data_aggregate_domain_idx ON account_data_aggregate (domain);
CREATE INDEX IF NOT EXISTS account_data_aggregate_type_idx ON account_data_aggregate (account_data_type);
CREATE INDEX IF NOT EXISTS account_data_aggregate_instance_idx ON account_data_aggregate (instance);
