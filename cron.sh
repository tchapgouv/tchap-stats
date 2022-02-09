#!/bin/bash

/bin/bash fetch_from_s3.sh

## Set up DB
psql -d $DATABASE_URL -f tables.sql
psql -d $DATABASE_URL -f functions.sql

#### Now insert into DB

# Note : DATABASE_URL is automatically created on scalingo machines.
psql -d $DATABASE_URL --set=filepath="/app/$filename" -f insert_data.sql 
# other syntax ? -v filepath="/app/$filename"

echo "Done !"
