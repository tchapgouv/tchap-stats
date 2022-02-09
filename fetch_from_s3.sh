#!/bin/bash

# Fetch the csv file of stats from S3 bucket.

file_to_download=$1

filename=${file_to_download##*/}

bucket="tchap-stats-metabase"
s3path="/${bucket}/${file_to_download}"

# metadata
contentType="text/csv"
dateValue=`date -R`
signature_string="PUT\n\n${contentType}\n${dateValue}\n${s3path}"

# TODO get S3SECRET and S3ACCESS
#prepare signature hash to be sent in Authorization header
signature_hash=`echo -en ${signature_string} | openssl sha1 -hmac ${S3SECRET} -binary | base64`

destination="https://tchap-stats-metabase.s3.gra.cloud.ovh.net/${filename}"
echo $destination

# TODO use GET here
# actual curl command to do PUT operation on s3
curl -k -X PUT -T "${file_to_download}" \
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${S3ACCESS}:${signature_hash}" \
  $destination