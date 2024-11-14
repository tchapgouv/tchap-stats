/*
   vue matérialisée qui agrege les données de user_daily_visits par device et par utilisateur et par mois sur 18 mois
*/
/* DROP MATERIALIZED VIEW IF EXISTS user_daily_visits_by_month_18m; */

/** User Monthly Visits **/
CREATE MATERIALIZED VIEW IF NOT EXISTS user_daily_visits_by_month_18m AS
SELECT device_id,
date_trunc('month', visit_ts) as month,
user_id,
instance,
domain,
device_type,
platform
FROM user_daily_visits
WHERE user_agent != 'matrix-media-repo'  /** We remove matrix-media-repo they are duplicate between Tchap iOS and Android **/
  AND visit_ts >= NOW() - INTERVAL '18 months' /* only 18 months */ 
GROUP BY 
  device_id, 
  month, 
  user_id, 
  instance, 
  domain, 
  device_type, 
  platform;

CREATE INDEX IF NOT EXISTS idx_user_daily_visits_by_month_18m_month ON user_daily_visits_by_month_18m (month);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_by_month_18m_device_id ON user_daily_visits_by_month_18m (device_id);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_by_month_18m_user_id ON user_daily_visits_by_month_18m (user_id);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_by_month_18m_instance ON user_daily_visits_by_month_18m (instance);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_by_month_18m_domain ON user_daily_visits_by_month_18m (domain);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_by_month_18m_device_type ON user_daily_visits_by_month_18m (device_type);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_by_month_18m_platform ON user_daily_visits_by_month_18m (platform);

REFRESH MATERIALIZED VIEW user_daily_visits_by_month_18m; 
