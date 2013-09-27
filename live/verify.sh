# Include common live script.
. live/common.sh 'verify'

cd ${webroot}
bzr log -r-1 -n0 > ${WORKSPACE}/version.txt
bzr status > ${WORKSPACE}/status.txt
bzr diff > ${WORKSPACE}/diff.txt

# Make sure Devel is not enabled.
if ${drush} pm-list --status=enabled --pipe | grep --quiet '^\(devel\)$'; then
  exit 1
fi

# Exit with error if there are changes.
exit $(cat ${WORKSPACE}/status.txt | wc -l)
