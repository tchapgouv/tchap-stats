#!/bin/bash

echo "sync_check_data_user_daily_visits"

echo "Check data quality : user daily visits vs user daily visits by month"
time psql -d $DATABASE_URL -f scripts/data_quality/check_coherence_udv_b_m.sql

echo "Check data quality : user daily visits vs user daily visits lite"
time psql -d $DATABASE_URL -f scripts/data_quality/check_coherence_user_monthly_visits_lite.sql
