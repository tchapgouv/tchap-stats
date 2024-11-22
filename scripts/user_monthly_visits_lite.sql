/*
 * This table is a lite version of the user daily visits aggregated by month
 * Data is focus on user and visit, all information about deviceId, device type, user agent is dropped
 * To init this table, use scripts/user_monthly_visits_lite_init.sql
 */ 
CREATE TABLE IF NOT EXISTS user_monthly_visits_lite (
  user_id VARCHAR NOT NULL,
  visit_date DATE NOT NULL,
  instance VARCHAR NOT NULL,
  domain VARCHAR NOT NULL
);

create UNIQUE INDEX IF NOT EXISTS user_monthly_visits_lite_unique ON user_monthly_visits_lite (user_id, visit_ts);
CREATE INDEX IF NOT EXISTS user_monthly_visits_lite_month_instance ON user_monthly_visits_lite (visit_ts, instance);
/*
ALTER TABLE public.user_monthly_visits_lite RENAME COLUMN visit_ts TO visit_date;
*/

/* insert data of the last 30 days */ 
INSERT INTO user_monthly_visits_lite (user_id, visit_date, instance, domain)
SELECT DISTINCT ON (user_id, DATE_TRUNC('month', visit_date))
    user_id, 
    DATE_TRUNC('month', visit_date) AS visit_date, 
    instance, 
    domain
FROM user_daily_visits udv
WHERE udv.visit_date >= CURRENT_DATE - INTERVAL '30 days'
  AND udv.device_type <> 'Autre'
ON CONFLICT (user_id, visit_date) DO NOTHING;