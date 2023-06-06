/* Refresh Materialized View (after data are inserted) */
REFRESH MATERIALIZED VIEW CONCURRENTLY user_monthly_visits;
REFRESH MATERIALIZED VIEW daily_unique_user_count;
REFRESH MATERIALIZED VIEW unique_user_daily_count_30d;
REFRESH MATERIALIZED VIEW month_unique_user_count;
