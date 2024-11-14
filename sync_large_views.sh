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

# not used, 6,6Go of data, deleted
# echo "Recreate Materialized View :  "
# time psql -d $DATABASE_URL -f scripts/user_daily_visits_auser_daily_visits_agg_1ygg_1y.sql

echo "Recreate Materialized View : user_daily_visits_by_month_1y.sql "
time psql -d $DATABASE_URL -f scripts/user_daily_visits_by_month_1y.sql

# deactivate because it is too big : https://github.com/tchapgouv/tchap-stats/issues/73
#echo "Recreate Materialized View : user_daily_visits_by_month_18m"
#time psql -d $DATABASE_URL -f scripts/user_daily_visits_by_month_18m.sql

#echo "Refresh Materialized View"
#time psql -d $DATABASE_URL -f scripts/refresh_materialized_view.sql

echo "Done !"

