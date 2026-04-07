#!/bin/bash
# Command : 
# - ./sync_stats.sh 
# - ./sync_stats.sh 2022-08-10 (to execute the script with a different date)


if [ -f .env ]; then
  source .env
fi

# Note : DATABASE_URL is automatically created on scalingo machines.
# For testing :
# DATABASE_URL=${DATABASE_URL:-'postgresql://stats:stats@localhost:5432/stats'}
# echo $DATABASE_URL
echo "Sync_views.sh"
echo "Starting job. Should display 'Done' when done, if there were no errors."


echo "Recreate Materialized View : user_daily_visits_by_month_1y_v3.sql "
time psql -d $DATABASE_URL -f scripts/user_daily_visits_by_month_1y_v3.sql

#echo "Refresh Materialized View"
#time psql -d $DATABASE_URL -f scripts/refresh_materialized_view.sql

echo "Done !"

