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
