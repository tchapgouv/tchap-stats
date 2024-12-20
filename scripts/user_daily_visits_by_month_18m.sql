/*
   vue matérialisée qui agrege les données de user_daily_visits par device et par utilisateur et par mois sur 18 mois
*/
/* DROP MATERIALIZED VIEW IF EXISTS user_daily_visits_by_month_18m; */
SET work_mem = '2GB'; -- Ajustez selon la quantité de RAM disponible

/** User Monthly Visits **/
CREATE MATERIALIZED VIEW IF NOT EXISTS user_daily_visits_by_month_18m AS
SELECT device_id,
date_trunc('month', visit_ts) as month,
user_id,
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
