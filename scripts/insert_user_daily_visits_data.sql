/* Insert data from the csv file into the DB. Some of the data will be already present in the DB, they will be ignored. */

CREATE TEMPORARY TABLE user_daily_visits_temp (user_id VARCHAR, device_id VARCHAR, visit_ts timestamp with time zone, user_agent VARCHAR, instance VARCHAR, domain VARCHAR);

\COPY user_daily_visits_temp(user_id, device_id, visit_ts, user_agent, instance, domain) FROM '/app/user_daily_visits.csv' DELIMITER ',' CSV HEADER;

INSERT INTO user_daily_visits
SELECT user_id,
device_id,
visit_ts,
user_agent,
instance,
domain,
CASE
    WHEN user_agent LIKE 'Mozilla%Windows%Firefox%' THEN 'Firefox Windows'
    WHEN user_agent LIKE 'Mozilla%Windows%Chrome%' THEN 'Chrome Windows'
    WHEN user_agent LIKE 'Mozilla%Windows%Trident%' THEN 'Internet Explorer Windows'
    WHEN user_agent LIKE 'Mozilla%Mac OS%Firefox%' THEN 'Firefox Mac OS'
    WHEN user_agent LIKE 'Mozilla%Mac OS%Chrome%' THEN 'Chrome Mac OS'
    WHEN user_agent LIKE 'Mozilla%Mac OS%Safari%' THEN 'Safari Mac OS'
    WHEN user_agent LIKE 'Mozilla%Android%Firefox%' THEN 'Firefox Android'
    WHEN user_agent LIKE 'Mozilla%Android%Chrome%' THEN 'Chrome Android'
    WHEN user_agent LIKE 'Mozilla%Linux%Firefox%' THEN 'Firefox Linux'
    WHEN user_agent LIKE 'Mozilla%Linux%Chrome%' THEN 'Chrome Linux'
    WHEN user_agent LIKE 'Mozilla%CrOS%Chrome%' THEN 'Chrome OS'
    WHEN user_agent LIKE 'Mozilla%Mobile%' THEN 'Navigateur Mobile'
    WHEN user_agent LIKE 'Mozilla%' THEN 'Autre Navigateur'
    WHEN user_agent LIKE 'Tchap%NEO%' THEN 'Tchap Android NEO'
    WHEN user_agent LIKE 'Tchap%Android%' THEN 'Tchap Android'
    WHEN user_agent LIKE 'RiotNSE/2%iOS%' THEN 'Tchap iOS'
    WHEN user_agent LIKE 'RiotSharedExtension/2%iOS%' THEN 'Tchap iOS'
    WHEN user_agent LIKE 'Tchap%iOS%' THEN 'Tchap iOS'
    WHEN user_agent LIKE 'Riot%' THEN 'Element'
    WHEN user_agent LIKE 'Element%' THEN 'Element'
    ELSE 'Autre'
END as device_type,
CASE
    WHEN user_agent LIKE 'Mozilla%' THEN 'Web'
    WHEN user_agent LIKE 'Tchap%Android%' THEN 'Mobile'
    WHEN user_agent LIKE 'RiotNSE/2%iOS%' THEN 'Mobile'
    WHEN user_agent LIKE 'RiotSharedExtension/2%iOS%' THEN 'Mobile'
    WHEN user_agent LIKE 'Tchap%iOS%' THEN 'Mobile'
    WHEN user_agent LIKE 'Riot%iOS' THEN 'Mobile'
    WHEN user_agent LIKE 'Riot%Android' THEN 'Mobile'
    WHEN user_agent LIKE 'Element%Android' THEN 'Mobile'
    WHEN user_agent LIKE 'Element%iOS' THEN 'Mobile'
    ELSE 'Autre'
END as platform
FROM user_daily_visits_temp
ON CONFLICT DO NOTHING

