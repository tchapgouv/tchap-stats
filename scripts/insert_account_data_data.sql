/* Insert data from the csv file into the DB. */
/* If data is already present, update the content field */
/* user_id	account_data_type	content	instance domain*/

CREATE TEMPORARY TABLE account_data_aggregate_temp (user_id VARCHAR, account_data_type VARCHAR, content VARCHAR, instance VARCHAR, domain VARCHAR);

-- CSV file has fields in this order : user_id	account_data_type	content	instance domain
-- If it changes, change this line or it will break.
\copy account_data_aggregate_temp(user_id, account_data_type, content, instance, domain) FROM '/app/account_data.csv' DELIMITER ',' CSV HEADER;


INSERT INTO account_data_aggregate(user_id, account_data_type, content, instance, domain)
SELECT user_id, account_data_type, content c, instance, domain
FROM account_data_aggregate_temp
ON CONFLICT (user_id, account_data_type) DO update set content=EXCLUDED.content;