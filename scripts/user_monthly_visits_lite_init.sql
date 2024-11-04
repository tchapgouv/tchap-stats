/*
user_monthly_visits_lite table has been initialized with the following requests:
*/

DELETE FROM user_monthly_visits_lite; -- delete all data

/* add data for year 2021 */
INSERT INTO user_monthly_visits_lite (user_id, visit_ts, instance, domain)
SELECT DISTINCT ON (user_id, DATE_TRUNC('month', visit_ts))
    user_id, 
    DATE_TRUNC('month', visit_ts) AS visit_ts, 
    instance, 
    domain
FROM user_daily_visits udv
WHERE DATE_TRUNC('year', udv.visit_ts) = '2021-01-01'
  AND udv.device_type <> 'Autre'
ON CONFLICT (user_id, visit_ts) DO NOTHING;

/* add data for year 2022 */
INSERT INTO user_monthly_visits_lite (user_id, visit_ts, instance, domain)
SELECT DISTINCT ON (user_id, DATE_TRUNC('month', visit_ts))
    user_id, 
    DATE_TRUNC('month', visit_ts) AS visit_ts, 
    instance, 
    domain
FROM user_daily_visits udv
WHERE udv.visit_ts >= '2022-01-01' -- avoid use of DATE_TRUNC to use the index on visit_ts
  AND udv.visit_ts < '2023-01-01'
  AND udv.device_type <> 'Autre'
ON CONFLICT (user_id, visit_ts) DO NOTHING;

/* add data for year 2023 */
INSERT INTO user_monthly_visits_lite (user_id, visit_ts, instance, domain)
SELECT DISTINCT ON (user_id, DATE_TRUNC('month', visit_ts))
    user_id, 
    DATE_TRUNC('month', visit_ts) AS visit_ts, 
    instance, 
    domain
FROM user_daily_visits udv
WHERE udv.visit_ts >= '2023-01-01'
  AND udv.visit_ts < '2024-01-01'
  AND udv.device_type <> 'Autre'
ON CONFLICT (user_id, visit_ts) DO NOTHING;

/* add data for year 2024 */
INSERT INTO user_monthly_visits_lite (user_id, visit_ts, instance, domain)
SELECT DISTINCT ON (user_id, DATE_TRUNC('month', visit_ts))
    user_id, 
    DATE_TRUNC('month', visit_ts) AS visit_ts, 
    instance, 
    domain
FROM user_daily_visits udv
WHERE udv.visit_ts >= '2024-01-01'
  AND udv.visit_ts < '2025-01-01'
  AND udv.device_type <> 'Autre'
ON CONFLICT (user_id, visit_ts) DO NOTHING;
