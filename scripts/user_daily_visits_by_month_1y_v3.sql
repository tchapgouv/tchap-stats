/*
   vue matérialisée qui agrege les données de user_daily_visits par device et par  utilisateur et par mois
   utilisée par le dashboard public
   - la difference avec la V2 est que le champs visit_date (de type date, sans timezone) est utilisé à la place de visit_ts (timestamp avec timezone)

*/
/* DROP MATERIALIZED VIEW IF EXISTS user_daily_visits_by_month_1y_v3; */

/** User Monthly Visits **/
SET work_mem = '2GB'; -- Ajustez selon la quantité de RAM disponible
CREATE MATERIALIZED VIEW IF NOT EXISTS user_daily_visits_by_month_1y_v3 AS
SELECT 
  user_id,
  date_trunc('month'::text, visit_date::timestamp without time zone)::date as month,
  device_id,
  instance,
  domain,
  device_type,
  platform
FROM user_daily_visits
WHERE 
  visit_date >= NOW() - INTERVAL '12 month' /* only one year */ 
  AND device_type <> 'Autre'
GROUP BY 
  month, 
  platform,
  user_id, 
  device_id, 
  instance, 
  domain, 
  device_type,
  platform

CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v3_month ON user_daily_visits_by_month_1y_v3 (month);
CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v3_device_id ON user_daily_visits_by_month_1y_v3 (device_id);
CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v3_user_id ON user_daily_visits_by_month_1y_v3 (user_id);
CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v3_instance ON user_daily_visits_by_month_1y_v3 (instance);
CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v3_domain ON user_daily_visits_by_month_1y_v3 (domain);
CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v3_device_type ON user_daily_visits_by_month_1y_v3 (device_type);
CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v3_platform ON user_daily_visits_by_month_1y_v3 (platform);

REFRESH MATERIALIZED VIEW user_daily_visits_by_month_1y_v3; 
