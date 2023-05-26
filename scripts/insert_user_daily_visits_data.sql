/* Insert data from the csv file into the DB. Some of the data will be already present in the DB, they will be ignored. */

CREATE TEMPORARY TABLE user_daily_visits_temp (user_id VARCHAR, device_id VARCHAR, visit_ts timestamp with time zone, user_agent VARCHAR, instance VARCHAR, domain VARCHAR);

\COPY user_daily_visits_temp(user_id, device_id, visit_ts, user_agent, instance, domain) FROM '/app/user_daily_visits.csv' DELIMITER ',' CSV HEADER;

INSERT INTO user_daily_visits
SELECT *
FROM user_daily_visits_temp
ON CONFLICT DO NOTHING

