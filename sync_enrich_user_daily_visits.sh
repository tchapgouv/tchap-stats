#!/bin/bash

echo "sync_enrich_data.sh"
echo "Starting job. Should display 'Done' when done, if there were no errors."

#time psql -d $DATABASE_URL -v -f scripts/enrich_user_daily_visits_batch.sql -> TODO: does not launch script

# only for local dev
if [ -f .env ]; then
  source .env
fi

# Lancer session interactive de psql et exécuter le script
psql -d $DATABASE_URL <<EOF
\i scripts/enrich_user_daily_visits_batch.sql
EOF

# time psql -d $DATABASE_URL -v -f scripts/enrich_user_daily_visits_batch_date.sql

psql -d $DATABASE_URL <<EOF
\i scripts/enrich_user_daily_visits_batch_date.sql
EOF



echo "Done !"

