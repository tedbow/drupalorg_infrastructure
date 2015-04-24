# Include common integration script.
. integration/common.sh 'verify'

cd ${webroot}
git log --name-status HEAD^..HEAD > ${WORKSPACE}/version.txt
git status > ${WORKSPACE}/status.txt
git diff  > ${WORKSPACE}/diff.txt

# Make sure the site is up.
test_site

# Exit with error if there are changes.
exit $(cat ${WORKSPACE}/diff.txt | wc -l)
