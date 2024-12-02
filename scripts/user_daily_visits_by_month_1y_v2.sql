/*
   vue matérialisée qui agrege les données de user_daily_visits par device et par  utilisateur et par mois
   utilisée par le dashboard public
*/
/* DROP MATERIALIZED VIEW IF EXISTS user_daily_visits_by_month_1y_v2; */
SET work_mem = '2GB'; -- Ajustez selon la quantité de RAM disponible

/** User Monthly Visits **/
CREATE MATERIALIZED VIEW IF NOT EXISTS user_daily_visits_by_month_1y_v2 AS
SELECT device_id,
date_trunc('month', visit_ts) as month,
user_id,
instance,
domain,
device_type,
platform
FROM user_daily_visits
WHERE user_agent != 'matrix-media-repo'  /** We remove matrix-media-repo they are duplicate between Tchap iOS and Android **/
  AND visit_ts >= NOW() - INTERVAL '1 year' /* only one year */ 
GROUP BY 
  device_id, 
  month, 
  user_id, 
  instance, 
  domain, 
  device_type, 
  platform,
  user_agent;

CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v2_month ON user_daily_visits_by_month_1y_v2 (month);
CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v2_device_id ON user_daily_visits_by_month_1y_v2 (device_id);
CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v2_user_id ON user_daily_visits_by_month_1y_v2 (user_id);
CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v2_instance ON user_daily_visits_by_month_1y_v2 (instance);
CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v2_domain ON user_daily_visits_by_month_1y_v2 (domain);
CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v2_device_type ON user_daily_visits_by_month_1y_v2 (device_type);
CREATE INDEX IF NOT EXISTS user_daily_visits_by_month_1y_v2_platform ON user_daily_visits_by_month_1y_v2 (platform);

REFRESH MATERIALIZED VIEW user_daily_visits_by_month_1y_v2; 
