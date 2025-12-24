/* edit: deactivate pushers because it takes 40Go and it is not really used */

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


/* Insert data from the csv file into the DB. Some of the data will be already present in the DB, they will be ignored. */
/* user_name	device_id	app_id	kind	enabled	instance	domain */

CREATE TEMPORARY TABLE pushers_aggregate_temp (user_name VARCHAR, device_id VARCHAR, app_id VARCHAR, kind VARCHAR, is_enabled BOOLEAN, instance VARCHAR, domain VARCHAR );

-- CSV file has fields in this order : user_name, device_id, app_id, kind, enabled, instance, domain
-- If it changes, change this line or it will break.
\copy pushers_aggregate_temp(user_name, device_id, app_id, kind, is_enabled, instance, domain) FROM '/app/pushers.csv' DELIMITER ',' CSV HEADER;

INSERT INTO pushers_aggregate
SELECT *
FROM pushers_aggregate_temp
ON CONFLICT DO NOTHING
