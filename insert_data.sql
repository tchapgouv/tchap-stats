/* File path should be passed from args */

CREATE TABLE IF NOT EXISTS subscriptions_aggregate (subscriptions INTEGER, domain VARCHAR, hour timestamp  with time zone, instance VARCHAR);

DROP TABLE IF EXISTS subscriptions_aggregate_temp; 
/* TODO use temp table */
CREATE TABLE subscriptions_aggregate_temp (subscriptions INTEGER, domain VARCHAR, hour timestamp  with time zone, instance VARCHAR);

\copy subscriptions_aggregate_temp(subscriptions, domain, hour, instance) FROM :'filepath' DELIMITER ',' CSV HEADER;
