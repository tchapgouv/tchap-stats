WITH results_12m AS (
  SELECT
    "public"."user_daily_visits_by_month_1y"."device_type" AS "device_type",
    COUNT(DISTINCT "public"."user_daily_visits_by_month_1y"."device_id") AS "count_12m"
  FROM
    "public"."user_daily_visits_by_month_1y"
  WHERE
    "public"."user_daily_visits_by_month_1y"."month" >= DATE_TRUNC('month', (NOW() + INTERVAL '-1 month'))
    AND "public"."user_daily_visits_by_month_1y"."month" < DATE_TRUNC('month', NOW())
  GROUP BY
    "public"."user_daily_visits_by_month_1y"."device_type"
),

results_v2 AS (
  SELECT
    "public"."user_daily_visits_by_month_1y_v2"."device_type" AS "device_type",
    COUNT(DISTINCT "public"."user_daily_visits_by_month_1y_v2"."device_id") AS "count_v2"
  FROM
    "public"."user_daily_visits_by_month_1y_v2"
  WHERE
    "public"."user_daily_visits_by_month_1y_v2"."month" >= DATE_TRUNC('month', (NOW() + INTERVAL '-1 month'))
    AND "public"."user_daily_visits_by_month_1y_v2"."month" < DATE_TRUNC('month', NOW())
  GROUP BY
    "public"."user_daily_visits_by_month_1y_v2"."device_type"
)

-- Comparer les résultats des deux requêtes avec une jointure sur "device_type"
SELECT 
  COALESCE(r12m."device_type", rV2."device_type") AS "device_type",  -- Garder le device_type, même s’il est null dans l’une des tables
  COALESCE(r12m."count_12m", 0) AS "count_12m",                      -- Nombre de devices dans la première table (12 mois)
  COALESCE(rV2."count_v2", 0) AS "count_v2",                         -- Nombre de devices dans la deuxième table (version V2)
  (COALESCE(rV2."count_v2", 0) - COALESCE(r12m."count_12m", 0)) AS "Ecart"  -- Calcul de la différence
FROM 
  results_12m r12m
FULL OUTER JOIN results_v2 rV2 ON r12m."device_type" = rV2."device_type"
ORDER BY 
  (COALESCE(rV2."count_v2", 0) - COALESCE(r12m."count_12m", 0)) DESC;