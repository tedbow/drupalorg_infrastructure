#!/usr/local/bin/bash

export CREDS="${1}"
export JOBNAME="${2}"
#export URL="http://dispatcher-origin.drupalci.aws:8080"
export URL="http://staging-dispatcher-origin.drupalci.aws:8080"
export S3BUCKET="dci-console-log"

export JOBPATH="job/${JOBNAME}"
export URI="$JOBPATH/api/json?tree=allBuilds[id,timestamp]"
export DATESTAMP="$(date +'%Y.%m.%d.%H%M')"
export idFILE="dci-id-${DATESTAMP}.txt"
export FOLDER="${DATESTAMP}"
export idARCHIVE="${FOLDER}/archive-${idFILE}"
export COMPRESSEDFILE="${FOLDER}.tgz"
# Trying to use a variable in the date command wasn't wokring well
export XDAYEPOCH=$(date -v-90d +"%s")
export XDAYEPOCHMILI="$((${XDAYEPOCH} * 1000))"
export DECODESCRIPT="/usr/local/drupal-infrastructure/drupalci/console-log-archive/dci-decode-json.php"

cd ${WORKSPACE}

# Get json from jenkins, decode it and put into temp file
echo "Getting the list of all builds for ${JOBNAME}"
curl --silent --globoff -u ${CREDS} "$URL/${URI}" | php ${DECODESCRIPT} > ./${idFILE}

# Create a temporary folder for the consoletext to live
if [[ ! -d ./${FOLDER} ]]; then
  mkdir ./${FOLDER}
fi

# Get the various consoleText and save to file
echo "Parsing builds to archive"
cat ./${idFILE} | while read i; do
  buildTIMESTAMP="$(echo ${i} | awk '{print $2}')"
  if [[ "${buildTIMESTAMP}" -lt "${XDAYEPOCHMILI}" ]]; then
    buildID=$(echo ${i} | awk '{print $1}')
    echo "${buildID}" >> ./${idARCHIVE}
  fi
done;

startID=$(tail -n 1 ./${idARCHIVE})
endID=$(head -n 1 ./${idARCHIVE})

echo "Downloading build consoleText for IDs from ${startID} to ${endID}"
cat ./${idARCHIVE} | xargs -P 4 -I {} bash -c 'curl --silent ${URL}/${JOBPATH}/{}/consoleText > ${FOLDER}/{}-consoleText.txt'

echo "Compressing consoleText"
tar zcf ./${COMPRESSEDFILE} ./${FOLDER}

echo "Uploading ${COMPRESSEDFILE}"
aws s3 cp  ./${COMPRESSEDFILE} s3://${S3BUCKET}/${JOBPATH}/

# Verify compressed file is in S3 and then delete job builds
if [[ $(aws s3 ls s3://${S3BUCKET}/${JOBPATH}/${COMPRESSEDFILE}) ]]; then
  echo "Deleting build consoleText for IDs from ${startID} to ${endID}"
  cat ./${idARCHIVE} | xargs -P 2 -I {} bash -c 'curl  -u ${CREDS} -X POST ${URL}/${JOBPATH}/{}/doDelete'
fi

echo "Total number of builds $(cat ./${idFILE} | wc -l)"
echo "Number of builds that were archived $(cat ./${idARCHIVE} | wc -l)"
du -sh *

echo "rm -rf ${idFILE} ${FOLDER} ${COMPRESSEDFILE}"
rm -rf ${idFILE} ${FOLDER} ${COMPRESSEDFILE}
