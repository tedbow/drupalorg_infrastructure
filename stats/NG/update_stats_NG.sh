#!/bin/bash
set -e

# First argument is the complete path to the file you wish to process, eg. /data/logs/fastly/updates-syslogs/2018.11.30.fastly
LOGFILEPATH=$1
LOGFILENAME=`basename ${LOGFILEPATH}`
LOGFILENAME=${LOGFILENAME%.gz}
echo "Processing ${LOGFILEPATH}"

pigz -d ${LOGFILEPATH}
rm -rf /data/stats/updatestats/splits/${LOGFILENAME}
mkdir -p /data/stats/updatestats/splits/${LOGFILENAME}
mkdir -p /data/stats/updatestats/splits/${LOGFILENAME}/sites
mkdir -p /data/stats/updatestats/splits/${LOGFILENAME}/hosts

# Split the file up into ip/sitekey smaller files.
parallel --pipepart -a ${LOGFILEPATH%.gz} /usr/local/drupal-infrastructure/stats/NG/logmauler.awk -v LOGFILENAME=${LOGFILENAME} -v SLOT={%}

echo "Concatenating ${LOGFILENAME}"
# re-concatenate the SLOTS back together.
cd /data/stats/updatestats/splits/${LOGFILENAME}/sites
for i in `ls`;do echo ${i#*:};done |sort -u |xargs -P 72 -I {} bash -c 'cat *:{} >> {}; rm *:{}'
cd /data/stats/updatestats/splits/${LOGFILENAME}/hosts
for i in `ls`;do echo ${i#*:};done |sort -u |xargs -P 72 -I {} bash -c 'cat *:{} >> {}; rm *:{}'


# Clean up any mess from a previous run
TABLES=( host host_site module project php site drupal );
for TABLENAME in "${TABLES[@]}"
do
  rm -rf /data/stats/updatestats/sitemodel/processing/${TABLENAME}/*+${LOGFILENAME}.${TABLENAME}_table
  mkdir -p /data/stats/updatestats/sitemodel/processing/${TABLENAME}
  mkdir -p /data/stats/updatestats/sitemodel/master/${TABLENAME}
done
echo "Procesing ${LOGFILENAME}"
# Generate the model tables from todays data
find /data/stats/updatestats/splits/${LOGFILENAME}/hosts -type f -print0 | xargs -0 -P 72 -I {} /usr/local/drupal-infrastructure/stats/NG/hostprocessor.awk {}
find /data/stats/updatestats/splits/${LOGFILENAME}/sites -type f -print0 | xargs -0 -P 72 -I {} /usr/local/drupal-infrastructure/stats/NG/siteprocessor.awk {}
cd /data/stats/updatestats
rm -rf /data/stats/updatestats/splits/${LOGFILENAME}/hosts
rm -rf /data/stats/updatestats/splits/${LOGFILENAME}/sites

echo "Merging ${LOGFILENAME}"
# Combine this files model data with the existing model files.
for TABLENAME in "${TABLES[@]}"
do
  find /data/stats/updatestats/sitemodel/processing/${TABLENAME} -name "*+${LOGFILENAME}.${TABLENAME}_table" -print0 | xargs -0 -P 72 -I {} /usr/local/drupal-infrastructure/stats/NG/${TABLENAME}_merger.awk {}
  rm -rf /data/stats/updatestats/sitemodel/processing/${TABLENAME}/*+${LOGFILENAME}.${TABLENAME}_table
done

# Concatenate the results together
#for TABLENAME in "${TABLES[@]}"
#do
#  find /data/stats/updatestats/sitemodel/processing/${TABLENAME}/ -name "*+${LOGFILENAME}.${TABLENAME}_table" -print0 | xargs -0 cat -- >> /data/stats/updatestats/sitemodel/processing/${TABLENAME}/${LOGFILENAME}.${TABLENAME}_table
#  rm -rf /data/stats/updatestats/sitemodel/processing/${TABLENAME}/*+${LOGFILENAME}.${TABLENAME}_table
#done

# Sync files to btch
# Gather the project/nid machine name mappings from somewhere/somehow.
# Merge project/nid data with project data table
# mysql load data into the stats tables.

echo "Compressing ${LOGFILEPATH%.gz}"
pigz ${LOGFILEPATH%.gz}
