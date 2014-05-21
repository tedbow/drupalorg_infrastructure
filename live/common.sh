# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Allow group-writable files.
umask g+w

# Get the uri and webroot by stripping the prefix and suffix from the job name.
uri=$(echo ${JOB_NAME} | sed -e "s/^${1}_//;s/--.*$//")
webroot="/var/www/${uri}/htdocs"

# For easily executing Drush.
export TERM=dumb
drush="drush -r ${webroot} -l ${uri} -y"
drush_no="drush -r ${webroot} -l ${uri} --no"
