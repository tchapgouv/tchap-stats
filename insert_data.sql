/* File path should be passed from args */

DROP TABLE IF EXISTS subscriptions_aggregate_temp; 
/* TODO use temp table */
CREATE TABLE subscriptions_aggregate_temp (subscriptions INTEGER, domain VARCHAR, hour timestamp  with time zone, instance VARCHAR);

\copy subscriptions_aggregate_temp(subscriptions, domain, hour, instance) FROM '/app/subscriptions_aggregate_2022-02-09.csv' DELIMITER ',' CSV HEADER;

SELECT merge_tables(subscriptions_aggregate, subscriptions_aggregate_temp);
