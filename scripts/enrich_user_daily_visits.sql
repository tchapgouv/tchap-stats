WITH batch AS (
    SELECT user_id, device_id, visit_ts
    FROM user_daily_visits
    where platform <> 'Autre' and device_id <> 'Autre'
    LIMIT 1000
)

UPDATE user_daily_visits
SET platform =
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
END,
device_type =
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
END
FROM batch 
WHERE user_daily_visits.device_id = batch.device_id AND user_daily_visits.user_id = batch.user_id AND user_daily_visits.visit_ts = batch.visit_ts;

/* 
 BATCH : 1000 record : 1.19s
 BATCH : 10000 record : 12s
 BATCH : 20000 record : 23s

 BATCH avec conditions platform <> 'Autre' and device_id <> 'Autre': 
  1000 record : 1m40

*/ 