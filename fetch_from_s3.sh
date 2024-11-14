#!/bin/bash

### Fetch the csv file of stats from S3 bucket.
echo "Start fetch_from_s3.sh"

# Get filename from argument
filename_without_extension=$1
day=$2
filename=${filename_without_extension}_${day}.csv
echo "file to download : $filename"

bucket="${S3_BUCKET_NAME}"
s3path="/${bucket}/${filename}"

# metadata
contentType="text/csv"
dateValue=`date -R`
signature_string="GET\n\n${contentType}\n${dateValue}\n${s3path}"

#prepare signature hash to be sent in Authorization header
signature_hash=`echo -en ${signature_string} | openssl sha1 -hmac ${S3_SECRET_ACCESS_KEY} -binary | base64`

destination="https://${bucket}.s3.gra.cloud.ovh.net/${filename}"
echo $destination

# actual curl command to do GET operation on s3
curl -k -X GET -o "${filename}"\
  -H "Date: ${dateValue}" \
  -H "Content-Type: ${contentType}" \
  -H "Authorization: AWS ${S3_ACCESS_KEY_ID}:${signature_hash}" \
  $destination

# Copy file to final place, ready to be inserted into DB
cp $filename ${filename_without_extension}.csv

numlines=`wc -l ${filename_without_extension}.csv`

echo "Done with fetch_from_s3 $filename_without_extension $day - number of lines $numlines"
