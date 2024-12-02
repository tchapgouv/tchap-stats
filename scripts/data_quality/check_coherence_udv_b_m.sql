SET work_mem = '2GB'; -- Ajustez selon la quantité de RAM disponible

WITH udv_b_m_visits AS (
  -- requête sur user_daily_visits_by_month_1y_v3
  SELECT
    DATE_TRUNC('month', "public"."user_daily_visits_by_month_1y_v3"."month")::date AS "month",
    COUNT(DISTINCT "public"."user_daily_visits_by_month_1y_v3"."user_id") AS "user_count_udv_b_m"
  FROM
    "public"."user_daily_visits_by_month_1y_v3"
  WHERE
    "public"."user_daily_visits_by_month_1y_v3"."month" >= DATE_TRUNC('month', NOW() + INTERVAL '-3 month')
    AND "public"."user_daily_visits_by_month_1y_v3"."month" < NOW()
  GROUP BY
    "month"
),

v0_visits AS (
  -- Requête sur user_daily_visits
  SELECT 
    DATE_TRUNC('month', udv.visit_date)::date AS "month",
    COUNT(DISTINCT udv.user_id) AS "user_count_reference"
  FROM 
    "public"."user_daily_visits" udv
  WHERE 
    udv.visit_date >= DATE_TRUNC('month', NOW() + INTERVAL '-3 month')                     
    AND udv.visit_date < NOW()
    AND udv.device_type <> 'Autre'
  GROUP BY 
    "month"
)

-- Jointure des résultats des deux requêtes sur le mois et calcul de différence
SELECT 
  COALESCE(udv_b_m_visits.month, v0_visits.month) AS month,  -- Garder le mois même s'il n'existe que dans une des tables
  COALESCE(udv_b_m_visits.user_count_udv_b_m, 0) AS user_count_udv_b_m,  -- Utilisateurs distincts dans la première table
  COALESCE(v0_visits.user_count_reference, 0) AS user_count_reference,  -- Utilisateurs distincts dans la troisième table
  (COALESCE(v0_visits.user_count_reference, 0) - COALESCE(udv_b_m_visits.user_count_udv_b_m, 0)) AS user_count_difference  -- Calcul de la différence
FROM 
  udv_b_m_visits
FULL OUTER JOIN v0_visits 
  ON udv_b_m_visits.month = v0_visits.month  -- Jointure sur le mois entre udv_b_m_visits et v0_visits
ORDER BY 
  COALESCE(udv_b_m_visits.month, v0_visits.month) ASC;  -- Tri des résultats


/*
month     |user_count_udv_b_m|user_count_reference|user_count_difference|
----------+------------------+--------------------+---------------------+
2024-05-01|            226855|              226855|                    0|
2024-06-01|            241295|              241295|                    0|
2024-07-01|            230561|              230561|                    0|
2024-08-01|            212832|              212832|                    0|
2024-09-01|            264509|              264509|                    0|
2024-10-01|            270223|              270223|                    0|
2024-11-01|            263631|              263631|                    0|
*/