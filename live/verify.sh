# Include common live script.
. live/common.sh 'verify'

cd ${webroot}
bzr log -r-1 -n0 > ${WORKSPACE}/version.txt
bzr status > ${WORKSPACE}/status.txt
bzr diff > ${WORKSPACE}/diff.txt

# Exit with error if there are changes.
exit $(cat ${WORKSPACE}/status.txt | wc -l)
