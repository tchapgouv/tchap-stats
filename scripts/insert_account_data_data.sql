/* Insert data from the csv file into the DB. */
/* If data is already present, update the content field */
/* user_id	account_data_type	content	instance domain*/

CREATE TEMPORARY TABLE account_data_aggregate_temp (user_id VARCHAR, account_data_type VARCHAR, content VARCHAR, instance VARCHAR, domain VARCHAR);

-- CSV file has fields in this order : user_id	account_data_type	content	instance domain
-- If it changes, change this line or it will break.
\copy account_data_aggregate_temp(user_id, account_data_type, content, instance, domain) FROM '/app/account_data.csv' DELIMITER ',' CSV HEADER;


-- deduplicate data before inserting in the aggregate
-- when multiple values of content are present in the file, we keep only one randomly
CREATE TEMPORARY TABLE account_data_aggregate_deduplicated AS
SELECT DISTINCT ON (user_id, account_data_type) 
    user_id, account_data_type, content, instance, domain
FROM account_data_aggregate_temp
ORDER BY user_id, account_data_type, content;

INSERT INTO account_data_aggregate(user_id, account_data_type, content, instance, domain)
SELECT user_id, account_data_type, content, instance, domain
FROM account_data_aggregate_deduplicated
ON CONFLICT (user_id, account_data_type) DO update set content=EXCLUDED.content;