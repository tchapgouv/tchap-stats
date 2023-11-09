/* Insert data from the csv file into the DB. */
/* If data is already present, update the content field */
/* user_id	account_data_type	content	instance domain*/

CREATE TEMPORARY TABLE account_data_aggregate_temp (user_id VARCHAR, account_data_type VARCHAR, content VARCHAR, instance VARCHAR, domain VARCHAR);

-- CSV file has fields in this order : user_id	account_data_type	content	instance domain
-- If it changes, change this line or it will break.
\copy account_data_aggregate_temp(user_id, account_data_type, content, instance, domain) FROM '/app/account_data.csv' DELIMITER ',' CSV HEADER;

INSERT INTO account_data_aggregate
SELECT *
FROM account_data_aggregate_temp
ON CONFLICT DO UPDATE SET account_data_aggregate.content = account_data_aggregate_temp.content