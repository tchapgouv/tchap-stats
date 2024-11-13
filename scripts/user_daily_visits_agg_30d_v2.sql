/*
   vue matérialisée qui agrege les données de user_daily_visits par utilisateur, par jour sur les 30 derniers jours
*/
/* DROP MATERIALIZED VIEW IF EXISTS user_daily_visits_agg_30d; */

CREATE MATERIALIZED VIEW IF NOT EXISTS user_daily_visits_agg_30d AS
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