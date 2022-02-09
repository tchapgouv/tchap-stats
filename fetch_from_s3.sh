#!/bin/bash

# Fetch the csv file of stats from S3 bucket.

file_to_download=$1
echo "file to download : $file_to_download"

filename=${file_to_download##*/}

bucket="tchap-stats-metabase"
s3path="/${bucket}/${file_to_download}"

# metadata
contentType="text/csv"
dateValue=`date -R`
signature_string="GET\n\n${contentType}\n${dateValue}\n${s3path}"

#prepare signature hash to be sent in Authorization header
signature_hash=`echo -en ${signature_string} | openssl sha1 -hmac ${S3_SECRET_ACCESS_KEY} -binary | base64`

destination="https://tchap-stats-metabase.s3.gra.cloud.ovh.net/${filename}"
echo $destination

# actual curl command to do GET operation on s3
curl -k -X GET -o "${file_to_download}"\
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${S3_ACCESS_KEY_ID}:${signature_hash}" \
  $destination
