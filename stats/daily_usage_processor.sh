#/bin/bash
set -eux

# Takes in one argument, the data to process and should be in YYYY-MM-DD format.
FILEDATE=$1
cd /data/stats/updatestats

aws s3 cp s3://drupal-fastly-log/updates/ . --recursive --exclude "*" --include "${FILEDATE}*"
# Concatenate the files together. Not a useless use of cat.
cat ${FILEDATE}* > ${FILEDATE}.fastly.gz
# Unzip them for processing
gunzip ${FILEDATE}.fastly.gz
# get rid of the separate files
rm -f ${FILEDATE}T*
# Run the awk script on them to create the daily count files.
{ time /usr/local/drupal-infrastructure/stats/fastlyusagestatparser.awk ${FILEDATE}.fastly ; } 2>&1
