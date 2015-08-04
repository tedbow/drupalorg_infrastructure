#!/bin/env bash

# Drush commands for processing metrics collected and stored by Sampler API
# Add them of the form:
#   drush sampler-sample [module] [metric] --save

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Allow group-writable files.
umask g+w

# For easily executing Drush.
export TERM=dumb
drush="drush -r /var/www/drupal.org/htdocs -v -l drupal.org -y"

${drush} sampler-sample sampler nodes --save
${drush} sampler-sample sampler comments --save
${drush} sampler-sample sampler users --save
${drush} sampler-sample project_release new_releases --save
${drush} sampler-sample project_issue new_issues_comments_by_project --save
${drush} sampler-sample project_issue opened_vs_closed_by_category --object_batch_size=10000
${drush} sampler-sample project_issue reporters_participants_by_project --save
${drush} sampler-sample project_issue responses_by_project --object_batch_size=10000
