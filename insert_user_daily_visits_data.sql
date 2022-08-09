/* Insert data from the csv file into the DB. Some of the data will be already present in the DB, they will be ignored. */

CREATE TEMPORARY TABLE user_daily_visits_aggregate_temp (visits INTEGER, domain VARCHAR, instance VARCHAR, visit_ts timestamp with time zone);

\copy user_daily_visits_aggregate_temp(visits, visit_ts, domain, instance) FROM '/app/user_daily_visits_aggregate_temp.csv' DELIMITER ',' CSV HEADER;

INSERT INTO user_daily_visits_aggregate
SELECT *
FROM user_daily_visits_aggregate_temp
ON CONFLICT DO NOTHING
