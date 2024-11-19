WITH original_visits AS (
  -- Première requête sur user_monthly_visits_lite
  SELECT
    DATE_TRUNC('month', "public"."user_monthly_visits_lite"."visit_ts") AS "month",
    COUNT(DISTINCT "public"."user_monthly_visits_lite"."user_id") AS "user_count_original"
  FROM
    "public"."user_monthly_visits_lite"
  WHERE
    "public"."user_monthly_visits_lite"."visit_ts" >= DATE_TRUNC('month', NOW() + INTERVAL '-12 month')
    AND "public"."user_monthly_visits_lite"."visit_ts" < DATE_TRUNC('month', NOW())
  GROUP BY
    DATE_TRUNC('month', "public"."user_monthly_visits_lite"."visit_ts")
),

v2_visits AS (
  -- Deuxième requête sur user_daily_visits_by_month_1y_v3
  SELECT
    DATE_TRUNC('month', "public"."user_daily_visits_by_month_1y_v3"."month") AS "month",
    COUNT(DISTINCT "public"."user_daily_visits_by_month_1y_v3"."user_id") AS "user_count_v2"
  FROM
    "public"."user_daily_visits_by_month_1y_v3"
  WHERE
    "public"."user_daily_visits_by_month_1y_v3"."month" >= DATE_TRUNC('month', NOW() + INTERVAL '-12 month')
    AND "public"."user_daily_visits_by_month_1y_v3"."month" < DATE_TRUNC('month', NOW())
    AND (
      "public"."user_daily_visits_by_month_1y_v3"."platform" <> 'Autre'
      OR "public"."user_daily_visits_by_month_1y_v3"."platform" IS NULL
    )
  GROUP BY
    DATE_TRUNC('month', "public"."user_daily_visits_by_month_1y_v3"."month")
)

-- Jointure des résultats des deux requêtes sur le mois et calcul de différence
SELECT 
  COALESCE(original_visits.month, v2_visits.month) AS month,  -- Garder le mois même s'il n'existe que dans une des tables
  COALESCE(original_visits.user_count_original, 0) AS user_count_original,  -- Utilisateurs distincts dans la première table
  COALESCE(v2_visits.user_count_v2, 0) AS user_count_v2,  -- Utilisateurs distincts dans la seconde table
  (COALESCE(v2_visits.user_count_v2, 0) - COALESCE(original_visits.user_count_original, 0)) AS user_count_difference  -- Calcul de la différence
FROM 
  original_visits
FULL OUTER JOIN v2_visits 
  ON original_visits.month = v2_visits.month  -- Jointure sur le mois
ORDER BY 
  COALESCE(original_visits.month, v2_visits.month) ASC;  -- Tri des résultats