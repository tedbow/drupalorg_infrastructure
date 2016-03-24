#!/usr/local/bin/bash

export CREDS="${1}"
jobname="${2}"
export URL="http://localhost:8080"
s3bucket="dci-console-log"

export JOBPATH="job/${jobname}"
uri="$JOBPATH/api/json?tree=allBuilds[id,timestamp]"
datestamp="$(date +'%Y.%m.%d.%H%M')"
idfile="dci-id-${jobname}_${datestamp}.txt"
export FOLDER="${jobname}_${datestamp}"
idarchive="${FOLDER}/archive-${idfile}"
compressedfile="${FOLDER}.tgz"
# Trying to use a variable in the date command wasn't wokring well
xdayepoch=$(date -v-90d +"%s")
xdayepochmili="$((${xdayepoch} * 1000))"
decodescript="/usr/local/drupal-infrastructure/drupalci/console-log-archive/dci-decode-json.php"

cd ${WORKSPACE}

# Get json from jenkins, decode it and put into temp file
echo "Getting the list of all builds for ${jobname}"
curl --silent --globoff -u ${CREDS} "$URL/${uri}" | php ${decodescript} > ./${idfile}

# Create a temporary folder for the consoletext to live
if [[ ! -d ./${FOLDER} ]]; then
  mkdir ./${FOLDER}
fi

# Get the various consoleText and save to file
echo "Parsing builds to archive"
cat ./${idfile} | while read i; do
  buildTIMESTAMP="$(echo ${i} | awk '{print $2}')"
  if [[ "${buildTIMESTAMP}" -lt "${xdayepochmili}" ]]; then
    buildID=$(echo ${i} | awk '{print $1}')
    echo "${buildID}" >> ./${idarchive}
  fi
done;

startID=$(tail -n 1 ./${idarchive})
endID=$(head -n 1 ./${idarchive})

echo "Downloading build consoleText for IDs from ${startID} to ${endID}"
cat ./${idarchive} | xargs -P 4 -I {} bash -c 'curl --silent ${URL}/${JOBPATH}/{}/consoleText > ${FOLDER}/{}-consoleText.txt'

echo "Compressing consoleText"
tar zcf ./${compressedfile} ./${FOLDER}

echo "Uploading ${compressedfile}"
aws s3 cp  ./${compressedfile} s3://${s3bucket}/${JOBPATH}/

# Verify compressed file is in S3 and then delete job builds
if [[ $(aws s3 ls s3://${s3bucket}/${JOBPATH}/${compressedfile}) ]]; then
  echo "Deleting build consoleText for IDs from ${startID} to ${endID}"
  cat ./${idarchive} | xargs -P 2 -I {} bash -c 'curl --silent -u ${CREDS} -X POST ${URL}/${JOBPATH}/{}/doDelete'
fi

echo "Total number of builds $(cat ./${idfile} | wc -l)"
echo "Number of builds that were archived $(cat ./${idarchive} | wc -l)"
du -sh *

echo "rm -rf ${idfile} ${FOLDER} ${compressedfile}"
rm -rf ${idfile} ${FOLDER} ${compressedfile}
