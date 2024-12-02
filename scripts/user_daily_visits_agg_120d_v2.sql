/*
   vue matérialisée qui agrege les données de user_daily_visits par utilisateur, par jour sur les 120 derniers jours (4 mois)
*/
/* DROP MATERIALIZED VIEW IF EXISTS user_daily_visits_agg_120d_v2; */
SET work_mem = '2GB'; -- Ajustez selon la quantité de RAM disponible

CREATE MATERIALIZED VIEW IF NOT EXISTS user_daily_visits_agg_120d_v2 AS
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

REFRESH MATERIALIZED VIEW user_daily_visits_agg_120d_v2; 