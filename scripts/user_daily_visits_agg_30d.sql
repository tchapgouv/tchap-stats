/*
   vue matérialisée qui agrege les données de user_daily_visits par utilisateur, par jour sur les 30 derniers jours
*/
/* DROP MATERIALIZED VIEW IF EXISTS user_daily_visits_agg_30d; */
SET work_mem = '2GB'; -- Ajustez selon la quantité de RAM disponible

CREATE MATERIALIZED VIEW IF NOT EXISTS user_daily_visits_agg_30d AS
SELECT
  date_trunc('day', visit_ts) AS day,
  user_id,
  instance,
  domain,
  COUNT(*) AS visits_count,
  COUNT(CASE
    WHEN user_agent LIKE 'Mozilla%' THEN 1
    ELSE NULL
  END) AS web_visits_count,
  COUNT(CASE
    WHEN user_agent LIKE 'Tchap%Android%' OR
         user_agent LIKE 'RiotNSE/2%iOS%' OR
         user_agent LIKE 'RiotSharedExtension/2%iOS%' OR
         user_agent LIKE 'Tchap%iOS%' OR
         user_agent LIKE 'Riot%iOS' OR
         user_agent LIKE 'Riot%Android' OR
         user_agent LIKE 'Element%Android' OR
         user_agent LIKE 'Element%iOS'
    THEN 1
    ELSE NULL
  END) AS mobile_visits_count,
  COUNT(CASE
    WHEN user_agent NOT LIKE 'Mozilla%' AND
         user_agent NOT LIKE 'Tchap%Android%' AND
         user_agent NOT LIKE 'RiotNSE/2%iOS%' AND
         user_agent NOT LIKE 'RiotSharedExtension/2%iOS%' AND
         user_agent NOT LIKE 'Tchap%iOS%' AND
         user_agent NOT LIKE 'Riot%iOS' AND
         user_agent NOT LIKE 'Riot%Android' AND
         user_agent NOT LIKE 'Element%Android' AND
         user_agent NOT LIKE 'Element%iOS'
    THEN 1
    ELSE NULL
  END) AS other_visits_count
FROM
  user_daily_visits
WHERE 
  visit_ts >= NOW() - INTERVAL '30 day' 
GROUP BY
  date_trunc('day', visit_ts),
  user_id,
  instance,
  domain;


CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_30d_user_id ON user_daily_visits_agg_30d (user_id);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_30d_day ON user_daily_visits_agg_30d (day);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_30d_instance ON user_daily_visits_agg_30d (instance);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_30d_domain ON user_daily_visits_agg_30d (domain);

/* index on counts */
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_30d_visits_count ON user_daily_visits_agg_30d (visits_count);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_30d_web_visits_count ON user_daily_visits_agg_30d (web_visits_count);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_30d_mobile_visits_count ON user_daily_visits_agg_30d (mobile_visits_count);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_30d_other_visits_count ON user_daily_visits_agg_30d (other_visits_count);

REFRESH MATERIALIZED VIEW user_daily_visits_agg_30d;