# Include common live script.
. live/common.sh 'verify'

# Collect information.
cd ${webroot}
export version=$(bzr revno)
export version_available=$(bzr revno $(bzr info | sed -ne 's/\s*checkout of branch:\s*//p'))
export repo_status=$(bzr status)
export repo_diff=$(bzr diff)
cd ${WORKSPACE}
export projects=$(${drush} pm-list --status=enabled --pipe)

# Set up report area.
[ ! -d 'html' ] && git clone 'https://bitbucket.org/drupalorg-infrastructure/site-status-assets.git' 'html'
# Generate HTML report.
php /usr/local/drupal-infrastructure/live/verify-template.php > 'html/index.html'

# Exit with error if there are changes.
[ ! -n "${repo_status}" ]
