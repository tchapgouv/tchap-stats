#!/bin/bash
# Command : 
# - ./sync_stats.sh 
# - ./sync_stats.sh 2022-08-10 (to execute the script with a different date)

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

# Set up DB - create table and index
psql -d $DATABASE_URL -f scripts/tables.sql

# Retrieve and insert data

## USER DAILY VISITS
echo "Fetch S3 user_daily_visits $extract_date"
time ./fetch_from_s3.sh user_daily_visits $extract_date
echo "Insert User Daily Visits"
time psql -d $DATABASE_URL -f scripts/insert_user_daily_visits_data.sql
time ./sync_enrich_user_daily_visits.sh
time ./sync_large_views_user_daily_visits.sh
time ./sync_views_user_daily_visits.sh

## SUBSCRIPTIONS
echo "Fetch S3 subscriptions_aggregate"
time ./fetch_from_s3.sh subscriptions_aggregate $extract_date
echo "Insert Subscriptions"
time psql -d $DATABASE_URL -f scripts/insert_subscriptions_data.sql

## EVENTS
#echo "Fetch S3 events_aggregate"
# time ./fetch_from_s3.sh events_aggregate $extract_date
echo "Fetch S3 events_roomv9_aggregate"
time ./fetch_from_s3.sh events_roomv9_aggregate $extract_date
echo "Insert Events roomv9"
time psql -d $DATABASE_URL -f scripts/insert_events_roomv9_data.sql

## PUSHERS
echo "Fetch S3 pushers $extract_date"
time ./fetch_from_s3.sh pushers $extract_date
echo "Insert Pushers"
time psql -d $DATABASE_URL -f scripts/insert_pushers_data.sql


## ACCOUNT DATA
echo "Fetch S3 account_data $extract_date"
time ./fetch_from_s3.sh account_data $extract_date
echo "Insert Account Data"
time psql -d $DATABASE_URL -f scripts/insert_account_data_data.sql

## CRISP
echo "Fetch S3 crisp_conversation_segments $extract_date"
time ./fetch_from_s3.sh crisp_conversation_segments $extract_date
echo "Insert crisp conversations segments"
time psql -d $DATABASE_URL -f scripts/insert_crisp_conversation_segments.sql

echo "Done !"

