/* Insert data from the csv file into the DB. */
/* If data is already present, update the content field */
/* user_id	account_data_type	content	instance domain*/

CREATE TEMPORARY TABLE sso_aggregate_temp (
total_users INTEGER,
domain VARCHAR,
instance VARCHAR,
users_legacy INTEGER,
users_both_authentication INTEGER,
users_proconnect INTEGER
);

-- CSV file has fields in this order : user_id	account_data_type	content	instance domain
-- If it changes, change this line or it will break.
\copy sso_aggregate_temp(total_users, domain, instance, users_legacy, users_both_authentication, users_proconnect) FROM '/app/sso.csv' DELIMITER ',' CSV HEADER;


INSERT INTO sso_aggregate
SELECT *
FROM sso_aggregate_temp
ON CONFLICT DO NOTHING;