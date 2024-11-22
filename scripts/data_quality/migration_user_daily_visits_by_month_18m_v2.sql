WITH original_visits AS (
  -- Première requête sur user_daily_visits_by_month_18m
  SELECT
    DATE_TRUNC('month', "public"."user_daily_visits_by_month_18m"."month") AS "month",
    COUNT(DISTINCT "public"."user_daily_visits_by_month_18m"."user_id") AS "user_count_original"
  FROM
    "public"."user_daily_visits_by_month_18m"
  WHERE
    "public"."user_daily_visits_by_month_18m"."month" >= DATE_TRUNC('month', NOW() + INTERVAL '-12 month')
    AND "public"."user_daily_visits_by_month_18m"."month" < DATE_TRUNC('month', NOW())
    AND (
      "public"."user_daily_visits_by_month_18m"."platform" <> 'Autre'
      OR "public"."user_daily_visits_by_month_18m"."platform" IS NULL
    )
  GROUP BY
    DATE_TRUNC('month', "public"."user_daily_visits_by_month_18m"."month")
),

v2_visits AS (
  -- Deuxième requête sur user_daily_visits_by_month_18m_v2
  SELECT
    DATE_TRUNC('month', "public"."user_daily_visits_by_month_18m_v2"."month") AS "month",
    COUNT(DISTINCT "public"."user_daily_visits_by_month_18m_v2"."user_id") AS "user_count_v2"
  FROM
    "public"."user_daily_visits_by_month_18m_v2"
  WHERE
    "public"."user_daily_visits_by_month_18m_v2"."month" >= DATE_TRUNC('month', NOW() + INTERVAL '-12 month')
    AND "public"."user_daily_visits_by_month_18m_v2"."month" < DATE_TRUNC('month', NOW())
    AND (
      "public"."user_daily_visits_by_month_18m_v2"."platform" <> 'Autre'
      OR "public"."user_daily_visits_by_month_18m_v2"."platform" IS NULL
    )
  GROUP BY
    DATE_TRUNC('month', "public"."user_daily_visits_by_month_18m_v2"."month")
)

-- Jointure des résultats des deux requêtes avec calcul de différence
SELECT 
  original_visits.month,
  COALESCE(original_visits.user_count_original, 0) AS user_count_original,   -- Résultats de la première requête
  COALESCE(v2_visits.user_count_v2, 0) AS user_count_v2,                      -- Résultats de la deuxième requête
  (COALESCE(original_visits.user_count_original, 0) - COALESCE(v2_visits.user_count_v2, 0)) AS user_count_difference  -- Calcul de la différence
FROM 
  original_visits
FULL OUTER JOIN v2_visits ON original_visits.month = v2_visits.month          -- Jointure sur "month"
ORDER BY 
  original_visits.month ASC;