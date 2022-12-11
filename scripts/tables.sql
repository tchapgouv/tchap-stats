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
WHEN user_agent LIKE 'Mozilla%Linux%Firefox%' THEN 'Firefox Linux'
WHEN user_agent LIKE 'Mozilla%Linux%Chrome%' THEN 'Chrome Linux'
WHEN user_agent LIKE 'Mozilla%Android%Firefox%' THEN 'Firefox Android'
WHEN user_agent LIKE 'Mozilla%Android%Chrome%' THEN 'Chrome Android'
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
END as device_type
FROM user_daily_visits
WHERE user_agent != 'matrix-media-repo' /** We remove matrix-media-repo they are duplicate between Tchap iOS and Android **/
GROUP BY device_id, month, user_id, instance, domain, device_type;
