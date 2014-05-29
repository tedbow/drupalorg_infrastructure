# Include common live script.
. live/common.sh 'verify'

# Collect information.
cd ${webroot}
if [ -d .bzr ]; then
  export version=$(bzr revno)
  export version_available=$(bzr revno $(bzr info | sed -ne 's/\s*checkout of branch:\s*//p'))
  export repo_status=$(bzr status)
  export repo_diff=$(bzr diff)
else
  git fetch
  export version=$(git rev-parse --short HEAD)
  export version_available=$(git log "HEAD..origin/$(git rev-parse --abbrev-ref HEAD)" --oneline)
  export repo_status=$(git status --short)
  export repo_diff=$(git diff)
fi
cd ${WORKSPACE}
export projects=$(${drush} pm-list --status=enabled --pipe)
export features=$(
  # Machine names of enabled & overridden features. Machine-readable output
  # would be good.
  for feature in $(COLUMNS=1000 ${drush} features-list | sed -ne 's/\s*Enabled\s*Overridden\s*$//p' | sed -e 's/^.*\s\s//'); do
    echo "==== ${feature}"
    ${drush} features-diff "${feature}" | head -n 100
  done
)
export updates=$(${drush_no} --simulate --pipe pm-updatecode)

# Set up report area.
[ ! -d 'html' ] && git clone 'https://bitbucket.org/drupalorg-infrastructure/site-status-assets.git' 'html'
# Generate HTML report.
php /usr/local/drupal-infrastructure/live/verify-template.php > 'html/index.html'

# Exit with error if there are changes.
[ ! -n "${repo_status}" ]
