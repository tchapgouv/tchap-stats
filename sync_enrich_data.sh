#!/bin/bash

echo "sync_enrich_data.sh"
echo "Starting job. Should display 'Done' when done, if there were no errors."

time psql -d $DATABASE_URL -v -f scripts/enrich_user_daily_visits_batch.sql

echo "Done !"

