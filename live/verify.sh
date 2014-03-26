# Include common live script.
. live/common.sh 'verify'

# Collect information.
cd ${webroot}
export version=$(bzr revno)
export version_available=$(bzr revno $(bzr info | sed -ne 's/\s*checkout of branch:\s*//p'))
bzr log -r-1 -n0 > ${WORKSPACE}/version.txt
bzr status > ${WORKSPACE}/status.txt
bzr diff > ${WORKSPACE}/diff.txt

# Set up report area.
cd ${WORKSPACE}
[ ! -d 'html' ] && git clone 'https://bitbucket.org/drupalorg-infrastructure/site-status-assets.git' 'html'
# Generate HTML report.
php /usr/local/drupal-infrastructure/live/verify-template.php > 'html/index.html'

# Make sure Devel is not enabled.
if ${drush} pm-list --status=enabled --pipe | grep --quiet '^\(devel\)$'; then
  exit 1
fi

# Exit with error if there are changes.
exit $(cat ${WORKSPACE}/status.txt | wc -l)
