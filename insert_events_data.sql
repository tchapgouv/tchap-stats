/* Insert data from the csv file into the DB. Some of the data will be already present in the DB, they will be ignored. */

CREATE TEMPORARY TABLE events_aggregate_temp (events INTEGER, domain VARCHAR, hour timestamp with time zone, instance VARCHAR, type VARCHAR);

\copy events_aggregate_temp(events, domain, hour, instance, type) FROM '/app/events_aggregate.csv' DELIMITER ',' CSV HEADER;

INSERT INTO events_aggregate
SELECT *
FROM events_aggregate_temp
ON CONFLICT DO NOTHING
