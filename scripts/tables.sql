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
CREATE TABLE IF NOT EXISTS user_daily_visits_aggregate (
  visits INTEGER NOT NULL,
  domain VARCHAR NOT NULL,
  instance VARCHAR NOT NULL,
  visit_ts timestamp with time zone NOT NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS unique_user_daily_connections_idx ON user_daily_visits_aggregate (domain, visit_ts, instance);
CREATE INDEX IF NOT EXISTS events_aggregate_hour_to_week ON user_daily_visits_aggregate (visit_ts);
