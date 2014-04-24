# Include common staging script.
. staging/common.sh 'verify'

cd ${webroot}
if [ -d .bzr ]
 bzr log -r-1 -n0 > ${WORKSPACE}/version.txt
 bzr status > ${WORKSPACE}/status.txt
 bzr diff > ${WORKSPACE}/diff.txt
else 
 git log --name-status HEAD^..HEAD > ${WORKSPACE}/version.txt
 git status > ${WORKSPACE}/status.txt
 git diff  > ${WORKSPACE}/diff.txt
fi

# Make sure the site is up.
test_site

# Exit with error if there are changes.
exit $(cat ${WORKSPACE}/status.txt | wc -l)
