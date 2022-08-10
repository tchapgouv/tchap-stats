#!/bin/bash

# Note : DATABASE_URL is automatically created on scalingo machines.
# For testing :
# DATABASE_URL=${DATABASE_URL:-'postgresql://stats:stats@localhost:5432/stats'}
# echo $DATABASE_URL
echo "Starting job. Should display 'Done' when done, if there were no errors."

today=`date +'%Y-%m-%d'`
echo $today

time ./fetch_from_s3.sh subscriptions_aggregate $today
time ./fetch_from_s3.sh events_aggregate $today
time ./fetch_from_s3.sh user_daily_visits $today

## Set up DB
psql -d $DATABASE_URL -f scripts/tables.sql

#### Now insert into DB
time psql -d $DATABASE_URL -f scripts/insert_subscriptions_data.sql
time psql -d $DATABASE_URL -f scripts/insert_events_data.sql
time psql -d $DATABASE_URL -f scripts/insert_user_daily_visits_data.sql

echo "Done !"

