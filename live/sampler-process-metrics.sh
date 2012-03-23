#!/bin/env bash

# Drush commands for processing metrics collected and stored by Sampler API
# Add them of the form:
#   time drush sampler-sample [module] [metric] --save

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Allow group-writable files.
umask g+w

# For easily executing Drush.
export TERM=dumb
drush="drush -r /var/www/drupal.org/htdocs -l drupal.org -y"

time ${drush} sampler-sample sampler nodes --save
time ${drush} sampler-sample sampler comments --save
time ${drush} sampler-sample sampler users --save
time ${drush} sampler-sample project_release new_releases --save
time ${drush} sampler-sample project_issue new_issues_comments_by_project --save
time ${drush} sampler-sample project_issue opened_vs_closed_by_category --save
time ${drush} sampler-sample project_issue reporters_participants_by_project --save
