CREATE MATERIALIZED VIEW IF NOT EXISTS draft_retention_12_months AS
SELECT
user_id,
SUM(CASE WHEN month >= date_trunc('month', now() - interval '12 month') AND month < date_trunc('month', now() - interval '11 month') THEN 1 ELSE 0 END) AS mois_minus_12,
SUM(CASE WHEN month >= date_trunc('month', now() - interval '11 month') AND month < date_trunc('month', now() - interval '10 month') THEN 1 ELSE 0 END) AS mois_minus_11,
SUM(CASE WHEN month >= date_trunc('month', now() - interval '10 month') AND month < date_trunc('month', now() - interval '9 month') THEN 1 ELSE 0 END) AS mois_minus_10,
SUM(CASE WHEN month >= date_trunc('month', now() - interval '9 month') AND month < date_trunc('month', now() - interval '8 month') THEN 1 ELSE 0 END) AS mois_minus_9,
SUM(CASE WHEN month >= date_trunc('month', now() - interval '8 month') AND month < date_trunc('month', now() - interval '7 month') THEN 1 ELSE 0 END) AS mois_minus_8,
SUM(CASE WHEN month >= date_trunc('month', now() - interval '7 month') AND month < date_trunc('month', now() - interval '6 month') THEN 1 ELSE 0 END) AS mois_minus_7,
SUM(CASE WHEN month >= date_trunc('month', now() - interval '6 month') AND month < date_trunc('month', now() - interval '5 month') THEN 1 ELSE 0 END) AS mois_minus_6,
SUM(CASE WHEN month >= date_trunc('month', now() - interval '5 month') AND month < date_trunc('month', now() - interval '4 month') THEN 1 ELSE 0 END) AS mois_minus_5,
SUM(CASE WHEN month >= date_trunc('month', now() - interval '4 month') AND month < date_trunc('month', now() - interval '3 month') THEN 1 ELSE 0 END) AS mois_minus_4,
SUM(CASE WHEN month >= date_trunc('month', now() - interval '3 month') AND month < date_trunc('month', now() - interval '2 month') THEN 1 ELSE 0 END) AS mois_minus_3,
SUM(CASE WHEN month >= date_trunc('month', now() - interval '2 month') AND month < date_trunc('month', now() - interval '1 month') THEN 1 ELSE 0 END) AS mois_minus_2,
SUM(CASE WHEN month >= date_trunc('month', now() - interval '1 month') AND month < date_trunc('month', now()) THEN 1 ELSE 0 END) AS mois_minus_1,
SUM(CASE WHEN month > date_trunc('month', now()) THEN 1 ELSE 0 END) AS mois_en_cours
FROM user_daily_visits_by_month_1y where "device_type" != 'Autre'
GROUP BY user_id


/* create a cohort view for the last 12 months */ 
CREATE MATERIALIZED VIEW IF NOT EXISTS draft_retention_12_months_binary AS
SELECT
user_id,
MAX(CASE WHEN month >= date_trunc('month', now() - interval '12 month') AND month < date_trunc('month', now() - interval '11 month') THEN 1 ELSE 0 END) *1000000000000+
MAX(CASE WHEN month >= date_trunc('month', now() - interval '11 month') AND month < date_trunc('month', now() - interval '10 month') THEN 1 ELSE 0 END) *100000000000+
MAX(CASE WHEN month >= date_trunc('month', now() - interval '10 month') AND month < date_trunc('month', now() - interval '9 month') THEN 1 ELSE 0 END) *10000000000+
MAX(CASE WHEN month >= date_trunc('month', now() - interval '9 month') AND month < date_trunc('month', now() - interval '8 month') THEN 1 ELSE 0 END) *1000000000+
MAX(CASE WHEN month >= date_trunc('month', now() - interval '8 month') AND month < date_trunc('month', now() - interval '7 month') THEN 1 ELSE 0 END) *100000000+
MAX(CASE WHEN month >= date_trunc('month', now() - interval '7 month') AND month < date_trunc('month', now() - interval '6 month') THEN 1 ELSE 0 END) *10000000+
MAX(CASE WHEN month >= date_trunc('month', now() - interval '6 month') AND month < date_trunc('month', now() - interval '5 month') THEN 1 ELSE 0 END) *1000000+
MAX(CASE WHEN month >= date_trunc('month', now() - interval '5 month') AND month < date_trunc('month', now() - interval '4 month') THEN 1 ELSE 0 END) *100000+
MAX(CASE WHEN month >= date_trunc('month', now() - interval '4 month') AND month < date_trunc('month', now() - interval '3 month') THEN 1 ELSE 0 END) *10000+
MAX(CASE WHEN month >= date_trunc('month', now() - interval '3 month') AND month < date_trunc('month', now() - interval '2 month') THEN 1 ELSE 0 END) *1000+
MAX(CASE WHEN month >= date_trunc('month', now() - interval '2 month') AND month < date_trunc('month', now() - interval '1 month') THEN 1 ELSE 0 END) *100+
MAX(CASE WHEN month >= date_trunc('month', now() - interval '1 month') AND month < date_trunc('month', now()) THEN 1 ELSE 0 END)*10+
MAX(CASE WHEN month > date_trunc('month', now()) THEN 1 ELSE 0 END)*1 AS cohort_binary
FROM user_daily_visits_by_month_1y where "device_type" != 'Autre'
GROUP BY user_id


/* exemple of results */ 
\x00007a01d6c74adbf2e5ca29843989ff9db2e0a73e63fcbf7b1057c19a714336	0	1	0	0	0	0	0	0	0	0	0	0	0
\x000082d929c3757acb5142326a3558c40689d93cb7a6bbbf161635a7090a4645	3	3	3	3	2	3	4	5	5	4	4	3	0
\x000084413b7a923f9606ece64a0e07aaa7c1aaff282ec13fc065d7a38df81bc2	1	1	1	1	1	1	1	1	1	1	1	1	0
\x00009f48ad9c7a906134650a617638629a526263327ed4a735fb1821fbdec872	1	0	0	0	0	0	0	0	0	0	1	1	0
\x0000f4b623e5f3c2aafc31af42ae164ad001a1726a40c6cef11e8216b1b4a1f6	1	1	0	1	1	1	0	0	0	0	0	0	0
\x000128205982b6513ce1d03406aaa99842e04951e40d90ea877996ec1305b6b8	1	1	1	1	1	1	1	1	1	1	1	1	0
\x00014d25ed800e6442139b1eb64a49027809d9e17ebacc58385c47f9ae945472	0	0	0	0	0	0	0	0	0	3	1	1	0
\x0001ca173770bc21113c2d5da44ca40b083d8236009a74bcccdf63ccaeaef6a4	1	0	1	0	0	1	1	1	0	1	0	0	0
\x0001d2fbfe9f040569eb5dcdae28f84bcfc64872bdc198cde86afd6b565d81ec	1	1	1	1	2	2	3	2	3	2	1	2	0
\x00023c77c7fb87d986a3936dcce9b96e8ac34b1640f718e4c6b59c3b52b416ec	2	1	1	1	0	0	0	0	0	0	0	0	0
\x0002430b02502a4d0f72370892507cebcb5eda2d1ec0336e68d2b9701a8461ea	0	1	0	0	0	1	0	0	1	0	0	0	0
\x00024b85baa0809093fcab22437d78f20164357816c5ca2ca6d6a01d72732a2e	2	2	1	1	1	2	2	3	3	2	2	2	0

/* create a cohort view for the last 12 months */ 
CREATE MATERIALIZED VIEW IF NOT EXISTS draft_retention_12_months_binary AS
SELECT
user_id,
(CASE WHEN month >= date_trunc('month', now() - interval '12 month') AND month < date_trunc('month', now() - interval '11 month') THEN 1 ELSE 0 END) *1000000000000+
(CASE WHEN month >= date_trunc('month', now() - interval '11 month') AND month < date_trunc('month', now() - interval '10 month') THEN 1 ELSE 0 END) *100000000000+
(CASE WHEN month >= date_trunc('month', now() - interval '10 month') AND month < date_trunc('month', now() - interval '9 month') THEN 1 ELSE 0 END) *10000000000+
(CASE WHEN month >= date_trunc('month', now() - interval '9 month') AND month < date_trunc('month', now() - interval '8 month') THEN 1 ELSE 0 END) *1000000000+
(CASE WHEN month >= date_trunc('month', now() - interval '8 month') AND month < date_trunc('month', now() - interval '7 month') THEN 1 ELSE 0 END) *100000000+
(CASE WHEN month >= date_trunc('month', now() - interval '7 month') AND month < date_trunc('month', now() - interval '6 month') THEN 1 ELSE 0 END) *10000000+
(CASE WHEN month >= date_trunc('month', now() - interval '6 month') AND month < date_trunc('month', now() - interval '5 month') THEN 1 ELSE 0 END) *1000000+
(CASE WHEN month >= date_trunc('month', now() - interval '5 month') AND month < date_trunc('month', now() - interval '4 month') THEN 1 ELSE 0 END) *100000+
(CASE WHEN month >= date_trunc('month', now() - interval '4 month') AND month < date_trunc('month', now() - interval '3 month') THEN 1 ELSE 0 END) *10000+
(CASE WHEN month >= date_trunc('month', now() - interval '3 month') AND month < date_trunc('month', now() - interval '2 month') THEN 1 ELSE 0 END) *1000+
(CASE WHEN month >= date_trunc('month', now() - interval '2 month') AND month < date_trunc('month', now() - interval '1 month') THEN 1 ELSE 0 END) *100+
(CASE WHEN month >= date_trunc('month', now() - interval '1 month') AND month < date_trunc('month', now()) THEN 1 ELSE 0 END)*10+
(CASE WHEN month > date_trunc('month', now()) THEN 1 ELSE 0 END)*1 AS cohort_binary
FROM user_daily_visits_by_month_1y where "device_type" != 'Autre'
GROUP BY user_id

/* exemple of results */ 
userId, retention(monthly_activity)
\x00007a01d6c74adbf2e5ca29843989ff9db2e0a73e63fcbf7b1057c19a714336,100000000000
\x000082d929c3757acb5142326a3558c40689d93cb7a6bbbf161635a7090a4645,1111111111110
\x000084413b7a923f9606ece64a0e07aaa7c1aaff282ec13fc065d7a38df81bc2,1111111111110
\x00009f48ad9c7a906134650a617638629a526263327ed4a735fb1821fbdec872,1000000000110
\x0000f4b623e5f3c2aafc31af42ae164ad001a1726a40c6cef11e8216b1b4a1f6,1101110000000