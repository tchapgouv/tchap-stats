/* Refresh Materialized View (after data are inserted) */
/*
those view should be removed and not used anymore
*/
/*REFRESH MATERIALIZED VIEW CONCURRENTLY user_monthly_visits; /*deleted, DEPRECATED use instead : user_daily_visits_by_month_1y.sql */ 
/* REFRESH MATERIALIZED VIEW daily_unique_user_count; /*trop lourde ne fonctionne pas, deleted*/
/* REFRESH MATERIALIZED VIEW unique_user_daily_count_30d; /* depend de daily_unique_user_count, deleted*/