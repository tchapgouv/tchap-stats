/* deprecated, use users table */
/* Insert data from the csv file into the DB. Some of the data will be already present in the DB, they will be ignored. */

CREATE TEMPORARY TABLE subscriptions_aggregate_temp (subscriptions INTEGER, domain VARCHAR, hour timestamp with time zone, instance VARCHAR);

\copy subscriptions_aggregate_temp(subscriptions, domain, hour, instance) FROM '/app/subscriptions_aggregate.csv' DELIMITER ',' CSV HEADER;

INSERT INTO subscriptions_aggregate
SELECT *
FROM subscriptions_aggregate_temp
ON CONFLICT DO NOTHING
