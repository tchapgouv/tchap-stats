/* File name should be passed from args */

CREATE TABLE IF NOT EXISTS subscriptions_aggregate (subscriptions INTEGER, domain VARCHAR, hour timestamp  with time zone, instance VARCHAR);

DROP TABLE IF EXISTS subscriptions_aggregate_temp; 
CREATE TEMP TABLE subscriptions_aggregate_temp (subscriptions INTEGER, domain VARCHAR, hour timestamp  with time zone, instance VARCHAR);

/* TODO : don't hardcode file name */
\copy subscriptions_aggregate_temp(subscriptions, domain, hour, instance) FROM '/app/subscriptions_aggregate_example.csv' DELIMITER ',' CSV HEADER;

