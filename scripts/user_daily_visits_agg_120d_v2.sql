/*
   vue matérialisée qui agrege les données de user_daily_visits par utilisateur, par jour sur les 120 derniers jours (4 mois)
*/
/* DROP MATERIALIZED VIEW IF EXISTS user_daily_visits_agg_120d; */

CREATE MATERIALIZED VIEW IF NOT EXISTS user_daily_visits_agg_120d AS
SELECT
  date_trunc('day', visit_ts) AS day,
  user_id,
  instance,
  domain,
    COUNT(*) AS visits_count,
  COUNT(CASE
    WHEN platform = 'Web' THEN 1
    ELSE NULL
  END) AS web_visits_count,
  COUNT(CASE
    WHEN platform = 'Mobile' THEN 1
    ELSE NULL
  END) AS mobile_visits_count,
  COUNT(CASE
    WHEN platform = 'Autre' THEN 1
    ELSE NULL
  END) AS other_visits_count
FROM
  user_daily_visits
WHERE 
  visit_ts >= NOW() - INTERVAL '120 day' 
GROUP BY
  date_trunc('day', visit_ts),
  user_id,
  instance,
  domain;

/* used less than 100 times
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_120d_day ON user_daily_visits_agg_120d (day);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_120d_instance ON user_daily_visits_agg_120d (instance);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_120d_visits_count ON user_daily_visits_agg_120d (visits_count);
*/

/* not used so far
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_120d_user_id ON user_daily_visits_agg_120d (user_id);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_120d_domain ON user_daily_visits_agg_120d (domain);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_120d_web_visits_count ON user_daily_visits_agg_120d (web_visits_count);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_120d_mobile_visits_count ON user_daily_visits_agg_120d (mobile_visits_count);
CREATE INDEX IF NOT EXISTS idx_user_daily_visits_agg_120d_other_visits_count ON user_daily_visits_agg_120d (other_visits_count);
*/
REFRESH MATERIALIZED VIEW user_daily_visits_agg_120d; 