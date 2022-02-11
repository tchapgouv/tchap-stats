#!/bin/bash

DATABASE_URL=${DATABASE_URL:-'postgresql://stats:stats@localhost:5432/stats'}

/bin/bash fetch_from_s3.sh

echo $DATABASE_URL
## Set up DB
psql -d $DATABASE_URL -f tables.sql

#### Now insert into DB

# Note : DATABASE_URL is automatically created on scalingo machines.
psql -d $DATABASE_URL --set=filepath="/app/$filename" -f insert_data.sql 
# other syntax ? -v filepath="/app/$filename"

echo "Done !"
