# Include common staging script.
. staging/common.sh 'verify'

cd /var/www/${domain}/htdocs
bzr log -r-1 -n0 > ${WORKSPACE}/version.txt
bzr status > ${WORKSPACE}/status.txt
bzr diff > ${WORKSPACE}/diff.txt

# Exit with error if there are changes.
exit $(cat ${WORKSPACE}/status.txt | wc -l)
