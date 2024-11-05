-- Step 1: Create a temporary table to store the data loaded from the CSV file
CREATE TEMPORARY TABLE user_daily_visits_temp (
  user_id VARCHAR, 
  device_id VARCHAR, 
  visit_ts DATE, 
  user_agent VARCHAR, 
  instance VARCHAR, 
  domain VARCHAR
);

-- Step 2: Copy the data from the CSV file into the temporary table
\COPY user_daily_visits_temp(user_id, device_id, visit_ts, user_agent, instance, domain) FROM '/app/user_daily_visits.csv' DELIMITER ',' CSV HEADER;

-- Step 3: Insert data from the temporary table into the main table
-- The 'added_date' column will receive the value from 'visit_ts'
-- Entries from the last 30 days are inserted; duplicates are ignored
INSERT INTO user_daily_visits(user_id, device_id, visit_ts, user_agent, instance, domain, visit_date)
SELECT 
  user_id, 
  device_id, 
  visit_ts, 
  user_agent, 
  instance, 
  domain, 
  visit_ts -- Use 'visit_ts' as the value for the 'added_date' column
FROM user_daily_visits_temp udvt
WHERE 
  udvt.visit_ts >= NOW() - INTERVAL '30 days' -- Only insert records from the last 30 days
ON CONFLICT DO NOTHING; -- Ignore records that already exist (handle unique constraint conflicts)