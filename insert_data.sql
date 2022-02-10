/* Insert data from the csv file into the DB. Some of the data will be already present in the DB, so we use a MERGE. */

CREATE TEMPORARY TABLE subscriptions_aggregate_temp (subscriptions INTEGER, domain VARCHAR, hour timestamp  with time zone, instance VARCHAR);

\copy subscriptions_aggregate_temp(subscriptions, domain, hour, instance) FROM '/app/subscriptions_aggregate.csv' DELIMITER ',' CSV HEADER;
-- \copy subscriptions_aggregate_temp(subscriptions, domain, hour, instance) FROM './subscriptions_aggregate.csv' DELIMITER ',' CSV HEADER;


INSERT INTO subscriptions_aggregate
SELECT *
FROM subscriptions_aggregate_temp
ON CONFLICT DO NOTHING

-- /* TODO : ON should use multiple fields (or an id that we generate from the multiple fields ? ) */
-- MERGE INTO subscriptions_aggregate main
-- USING subscriptions_aggregate_temp temp
-- -- ON main.hour || main.domain || main.instance = temp.hour || temp.domain || temp.instance
-- -- ON (main.hour, main.domain, main.instance) = (temp.hour, temp.domain, temp.instance)
-- ON main.hour = temp.hour
-- WHEN MATCHED THEN
--     DO NOTHING
-- WHEN NOT MATCHED THEN
--     INSERT VALUES (subscriptions, domain, hour, instance);
