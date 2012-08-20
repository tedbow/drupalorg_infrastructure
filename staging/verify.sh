# Include common staging script.
. staging/common.sh 'verify'

cd ${webroot}
bzr log -r-1 -n0 > ${WORKSPACE}/version.txt
bzr status > ${WORKSPACE}/status.txt
bzr diff > ${WORKSPACE}/diff.txt

# Make sure the site is up
wget -O /dev/null "http://${uri}" --user=drupal --password=drupal

# Exit with error if there are changes.
exit $(cat ${WORKSPACE}/status.txt | wc -l)
