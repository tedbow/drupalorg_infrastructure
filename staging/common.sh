# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Allow group-writable files.
umask g+w

# Get the domain name by stripping the prefix from the job name.
domain=$(echo ${JOB_NAME} | sed -e "s/^${1}_//")

# For easily executing Drush.
export TERM=dumb
drush="drush -r /var/www/${domain}/htdocs -l ${domain} -y"
