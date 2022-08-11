#!/bin/bash
# Command : 
# - ./cron 
# - ./cron 2022-08-10 (to execute the script with a different date)

# Note : DATABASE_URL is automatically created on scalingo machines.
# For testing :
# DATABASE_URL=${DATABASE_URL:-'postgresql://stats:stats@localhost:5432/stats'}
# echo $DATABASE_URL
echo "Starting job. Should display 'Done' when done, if there were no errors."

extract_date=$1 # date format ie. 2022-08-10
if [ -z "$extract_date" ]
then
      extract_date=`date +'%Y-%m-%d'`
fi

echo $extract_date

time ./fetch_from_s3.sh subscriptions_aggregate $extract_date
time ./fetch_from_s3.sh events_aggregate $extract_date
time ./fetch_from_s3.sh user_daily_visits $extract_date

## Set up DB
psql -d $DATABASE_URL -f scripts/tables.sql

#### Now insert into DB
time psql -d $DATABASE_URL -f scripts/insert_subscriptions_data.sql
time psql -d $DATABASE_URL -f scripts/insert_events_data.sql
time psql -d $DATABASE_URL -f scripts/insert_user_daily_visits_data.sql

echo "Done !"

