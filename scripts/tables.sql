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
  device_type VARCHAR, /* can be null */
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
CREATE INDEX IF NOT EXISTS user_daily_visits_visit_ts_desc_idx ON user_daily_visits (visit_ts DESC);
/* test index to speed up invalid data retrieval */ 
CREATE INDEX IF NOT EXISTS user_daily_visits_platform_null_idx ON user_daily_visits (platform) WHERE platform IS NULL;


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