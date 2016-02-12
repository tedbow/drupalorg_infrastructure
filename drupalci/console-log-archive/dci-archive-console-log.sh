#!/bin/bash

CREDS="${1}"
JOBNAME="${2}"

URL="https://dispatcher.drupalci.org"
S3BUCKET="dci-console-log"

JOBPATH="job/${JOBNAME}"
URI="$JOBPATH/api/json?tree=builds[id,timestamp]"
DATESTAMP="$(date +'%Y.%m.%d')"
idFILE="dci-archive-id-${DATESTAMP}.txt"
FOLDER="${DATESTAMP}"
COMPRESSEDFILE="${FOLDER}.tar.lrz"

# Get json from jenkins, decode it and put into temp file
curl --silent --globoff -u ${CREDS} "$URL/${URI}" | php ./dci-decode-json.php > ./${idFILE}

# Create a temporary folder for the consoletext to live
if [[ ! -d ./${FOLDER} ]]; then
  mkdir ./${FOLDER}
fi

# Get the various consoleText and save to file
for i in $(cat ./${idFILE}); do
  echo "Downloading consoleText of job #${i}"
  curl --silent ${URL}/${JOBPATH}/${i}/consoleText > ${FOLDER}/${i}-consoleText.txt;
done;

lrztar -o ./${COMPRESSEDFILE} ./${FOLDER}

aws s3 cp  ./${COMPRESSEDFILE} s3://${S3BUCKET}/${JOBPATH}/

# Verify compressed file is in S3 and then delete job builds
if [[ $(aws s3 ls s3://${S3BUCKET}/${JOBPATH}/${COMPRESSEDFILE}) ]]; then
  for i in $(cat ./${idFILE}); do
    echo "Deleting build #${i}"
    curl -u ${CREDS} -X POST ${URL}/${JOBPATH}/${i}/doDelete;
  done;
fi

echo "rm -rf ./${idFILE} ${FOLDER} ${COMPRESSEDFILE}"
rm -rf ./${idFILE} ${FOLDER} ${COMPRESSEDFILE}
