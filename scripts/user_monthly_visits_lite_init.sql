/*
user_monthly_visits_lite table has been initialized with the following requests:
*/
INSERT INTO user_monthly_visits_lite (user_id, visit_ts, instance, domain) 
SELECT DISTINCT ON (user_id, DATE_TRUNC('month', visit_ts)) user_id, DATE_TRUNC('month', visit_ts), instance, domain
FROM user_daily_visits
WHERE DATE_TRUNC('year', visit_ts) = '2024-01-01'
ON CONFLICT(user_id, visit_ts) DO NOTHING;

INSERT INTO user_monthly_visits_lite (user_id, visit_ts, instance, domain) 
SELECT DISTINCT ON (user_id, DATE_TRUNC('month', visit_ts)) user_id, DATE_TRUNC('month', visit_ts), instance, domain
FROM user_daily_visits
WHERE DATE_TRUNC('year', visit_ts) = '2023-01-01'
ON CONFLICT(user_id, visit_ts) DO NOTHING;

INSERT INTO user_monthly_visits_lite (user_id, visit_ts, instance, domain) 
SELECT DISTINCT ON (user_id, DATE_TRUNC('month', visit_ts)) user_id, DATE_TRUNC('month', visit_ts), instance, domain
FROM user_daily_visits
WHERE DATE_TRUNC('year', visit_ts) = '2022-01-01'
ON CONFLICT(user_id, visit_ts) DO NOTHING;

INSERT INTO user_monthly_visits_lite (user_id, visit_ts, instance, domain) 
SELECT DISTINCT ON (user_id, DATE_TRUNC('month', visit_ts)) user_id, DATE_TRUNC('month', visit_ts), instance, domain
FROM user_daily_visits
WHERE DATE_TRUNC('year', visit_ts) = '2021-01-01'
ON CONFLICT(user_id, visit_ts) DO NOTHING;