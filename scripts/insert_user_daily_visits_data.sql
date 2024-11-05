/* Insert data from the csv file into the DB. Some of the data will be already present in the DB, they will be ignored. */

CREATE TEMPORARY TABLE user_daily_visits_temp (user_id VARCHAR, device_id VARCHAR, visit_ts date, user_agent VARCHAR, instance VARCHAR, domain VARCHAR);

\COPY user_daily_visits_temp(user_id, device_id, visit_ts, user_agent, instance, domain) FROM '/app/user_daily_visits.csv' DELIMITER ',' CSV HEADER;

INSERT INTO user_daily_visits(user_id, device_id, visit_ts, user_agent, instance, domain, visit_ts)
SELECT (user_id, device_id, visit_ts, user_agent, instance, domain, added_date) -- new column added_date converted from visit_ts
FROM user_daily_visits_temp udvt
WHERE 
  udvt.visit_ts >= NOW() - INTERVAL '30 days' -- insert only 3 days of history to speed up
ON CONFLICT DO NOTHING

