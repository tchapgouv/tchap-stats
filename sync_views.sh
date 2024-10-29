#!/bin/bash
# Command : 
# - ./sync_stats.sh 
# - ./sync_stats.sh 2022-08-10 (to execute the script with a different date)

# Note : DATABASE_URL is automatically created on scalingo machines.
# For testing :
# DATABASE_URL=${DATABASE_URL:-'postgresql://stats:stats@localhost:5432/stats'}
# echo $DATABASE_URL
echo "Sync_views.sh"
echo "Starting job. Should display 'Done' when done, if there were no errors."

echo "Recreate Materialized View : user_daily_visits_agg_30d "
time psql -d $DATABASE_URL -f scripts/user_daily_visits_agg_30d.sql

echo "Recreate Materialized View : user_daily_visits_agg_120d "
time psql -d $DATABASE_URL -f scripts/user_daily_visits_agg_120d.sql

echo "Filling table  : user_monthly_visits_lite"
time psql -d $DATABASE_URL -f scripts/user_monthly_visits_lite.sql

echo "Done !"

