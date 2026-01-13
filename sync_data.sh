#!/bin/bash
# Command : 

# - ./a.sh [date] [pipeline1,pipeline2,...]
# - ./sync_data.sh 2022-08-10 (for date with no specific pipelines)
# - ./sync_data.sh 2022-08-10 user_daily_visits,subscriptions (for specific pipelines)

# Note : DATABASE_URL is automatically created on scalingo machines.
# For testing :
# DATABASE_URL=${DATABASE_URL:-'postgresql://stats:stats@localhost:5432/stats'}
# echo $DATABASE_URL
echo "Starting job. Should display 'Done' when done, if there were no errors."

# only for local dev
if [ -f .env ]; then
  source .env
fi

extract_date=$1 # date format ie. 2022-08-10
if [ -z "$extract_date" ]
then
    ##extract_date=`date +'%Y-%m-%d'`
    #use yersterday date to be sure that the data has arrived from the preivous pipeline
    extract_date=$(date -d '1 day ago' +'%Y-%m-%d')    
fi

echo "Extract date : $extract_date"

selected_pipelines=$2

if [ -z "$selected_pipelines" ]; then
    selected_pipelines="*"
fi

echo "Selected pipeline : $selected_pipelines"

echo "Connecting to Database : $DATABASE_URL"

# Set up DB - create table and index
psql -d $DATABASE_URL -f scripts/tables.sql

user_daily_visits_pipeline() {
    echo "======== STARTING user_daily_visits PIPELINE AT $(date) ========"
    echo "Fetch S3 user_daily_visits $extract_date"
    time ./fetch_from_s3.sh user_daily_visits $extract_date
    echo "Insert User Daily Visits"
    time psql -d $DATABASE_URL -f scripts/insert_user_daily_visits_data.sql
    time ./sync_enrich_user_daily_visits.sh
    time ./sync_views_user_daily_visits.sh
    time ./sync_large_views_user_daily_visits.sh
    time ./sync_check_data_user_daily_visits.sh
    echo "======== FINISHED user_daily_visits PIPELINE AT $(date) ========"
}

subscriptions_pipeline() {
    echo "======== STARTING subscriptions PIPELINE AT $(date) ========"
    echo "Fetch S3 subscriptions_aggregate"
    time ./fetch_from_s3.sh subscriptions_aggregate $extract_date
    echo "Insert Subscriptions"
    time psql -d $DATABASE_URL -f scripts/insert_subscriptions_data.sql
    echo "======== FINISHED subscriptions PIPELINE AT $(date) ========"
}

events_pipeline() {
    echo "======== STARTING events PIPELINE AT $(date) ========"
    echo "Fetch S3 events_roomv9_aggregate"
    time ./fetch_from_s3.sh events_roomv9_aggregate $extract_date
    echo "Insert Events roomv9"
    time psql -d $DATABASE_URL -f scripts/insert_events_roomv9_data.sql
    echo "======== FINISHED events PIPELINE AT $(date) ========"
}

pushers_pipeline() {
    echo "======== STARTING pushers PIPELINE AT $(date) ========"
    echo "Fetch S3 pushers $extract_date"
    time ./fetch_from_s3.sh pushers $extract_date
    echo "Insert Pushers"
    time psql -d $DATABASE_URL -f scripts/insert_pushers_data.sql
    echo "======== FINISHED pushers PIPELINE AT $(date) ========"
}

account_data_pipeline() {
    echo "======== STARTING account_data PIPELINE AT $(date) ========"
    echo "Fetch S3 account_data $extract_date"
    time ./fetch_from_s3.sh account_data $extract_date
    echo "Insert Account Data"
    time psql -d $DATABASE_URL -f scripts/insert_account_data_data.sql
    echo "======== FINISHED account_data PIPELINE AT $(date) ========"
}

sso_pipeline() {
    echo "======== STARTING sso PIPELINE AT $(date) ========"
    echo "Fetch S3 sso $extract_date"
    time ./fetch_from_s3.sh sso $extract_date
    echo "Insert SSO Data"
    time psql -d $DATABASE_URL -f scripts/insert_sso_data.sql
    echo "======== FINISHED sso PIPELINE AT $(date) ========"
}

crisp_pipeline() {
    echo "======== STARTING crisp PIPELINE AT $(date) ========"
    echo "Fetch S3 crisp_conversation_segments $extract_date"
    time ./fetch_from_s3.sh crisp_conversation_segments $extract_date
    echo "Insert crisp conversations segments"
    time psql -d $DATABASE_URL -f scripts/insert_crisp_conversation_segments.sql
    echo "======== FINISHED crisp PIPELINE AT $(date) ========"
}

execute_pipeline() {
    pipeline=$1
    if [[ "$selected_pipelines" == "*" || "$selected_pipelines" == *"$pipeline"* ]]; then
        echo "Executing $pipeline pipeline..."
        $pipeline"_pipeline"
    else
        echo "Skipping $pipeline pipeline..."
    fi
}

psql -d $DATABASE_URL -f scripts/tables.sql

execute_pipeline "user_daily_visits"
execute_pipeline "subscriptions"
execute_pipeline "events"
#execute_pipeline "pushers" deactivate pushers because it takes 40Go and it is not really used
execute_pipeline "account_data"
execute_pipeline "sso"
execute_pipeline "crisp"

echo "======== JOB COMPLETED AT $(date) ========"