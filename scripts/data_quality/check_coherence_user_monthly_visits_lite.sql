WITH original_visits AS (
  -- Première requête sur user_monthly_visits_lite
  SELECT
    DATE_TRUNC('month', "public"."user_monthly_visits_lite"."visit_date"::date)::date AS "month",
    COUNT(DISTINCT "public"."user_monthly_visits_lite"."user_id") AS "user_count_umvl"
  FROM
    "public"."user_monthly_visits_lite"
  WHERE
    "public"."user_monthly_visits_lite"."visit_date" >= DATE_TRUNC('month', NOW() + INTERVAL '-5 month')
    AND "public"."user_monthly_visits_lite"."visit_date" < NOW()
  GROUP BY
    month
),

v0_visits AS (
  -- Requête sur user_daily_visits
  SELECT 
    DATE_TRUNC('month', udv.visit_date)::date AS "month",
    COUNT(DISTINCT udv.user_id) AS "user_count_reference"
  FROM 
    "public"."user_daily_visits" udv
  WHERE 
    udv.visit_date >= DATE_TRUNC('month', NOW() + INTERVAL '-5 month')                     
    AND udv.visit_date < NOW()
    AND udv.device_type <> 'Autre'
  GROUP BY 
    "month"
)

-- Jointure des résultats des deux requêtes sur le mois et calcul de différence
SELECT 
  COALESCE(original_visits.month, v0_visits.month) AS month,  -- Garder le mois même s'il n'existe que dans une des tables
  COALESCE(original_visits.user_count_umvl, 0) AS user_count_umvl,  -- Utilisateurs distincts dans la première table
  COALESCE(v0_visits.user_count_reference, 0) AS user_count_reference,  -- Utilisateurs distincts dans la troisième table
  (COALESCE(v0_visits.user_count_reference, 0) - COALESCE(original_visits.user_count_umvl, 0)) AS user_count_difference  -- Calcul de la différence
FROM 
  original_visits
FULL OUTER JOIN v0_visits 
  ON original_visits.month = v0_visits.month  -- Jointure sur le mois entre original_visits et v0_visits
ORDER BY 
  COALESCE(original_visits.month, v0_visits.month) ASC;  -- Tri des résultats


/*

month     |user_count_original|user_count_reference|user_count_difference|
----------+-------------------+-------------+---------------------+
2024-06-01|             241295|       241295|                    0|
2024-07-01|             230561|       230561|                    0|
2024-08-01|             212832|       212832|                    0|
2024-09-01|             264509|       264509|                    0|
2024-10-01|             270223|       270223|                    0|
2024-11-01|             250898|       250898|                    0|

*/