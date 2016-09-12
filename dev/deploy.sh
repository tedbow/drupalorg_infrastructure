#!/bin/bash
# Create a development environment for a given "name" on wwwdev1/dbdev1

# Include common dev script.
. dev/common.sh

# Usage: write_template "template" "path/to/destination"
function write_template {
  sed -e "s/DB_NAME/${db_name}/g;s/NAME/${name}/g;s/SITE/${site}/g;s/DB_PASS/${db_pass}/g" "dev/${1}" > "${2}"
}

# Fail early if comment is omitted.
[ -z "${COMMENT-}" ] && echo "Comment is required." && exit 1

# Handle drupal.org vs. sub-domains properly
if [ ${site} == "drupal" ]; then
  fqdn="drupal.org"
else
  # Strip any _ and following characters from ${site}, and add .drupal.org.
  # Such as 'qa_7' -> 'qa.drupal.org'
  fqdn="$(echo "${site}" | sed -e 's/_.*//').drupal.org"
fi

export TERM=dumb
drush="drush -r ${web_path}/htdocs -y"
declare -A db_names=( ["drupal"]="drupal" ["api"]="drupal_api" ["association"]="drupal_association" ["groups"]="drupal_groups" ["localize"]="drupal_localize" )
db_pass=$(pwgen -s 16 1)

[ -e "${web_path}" ] && echo "Project webroot already exists!" && exit 1

# Create the webroot and add comment file
mkdir "${web_path}"
mkdir -p "${web_path}/xhprof/htdocs"
sudo chown -R bender:developers "${web_path}"
echo "${COMMENT}" > "${web_path}/comment"

# Create the vhost config
write_template "vhost.conf.template" "${vhost_path}"

# Clone make file.
if [ "${site}" == "association" ]; then
  git clone ${branch/#/--branch } "git@bitbucket.org:drupalorg-infrastructure/assoc.drupal.org.git" "${web_path}/make"
  make_file="${web_path}/make/assoc.drupal.org.make"
else
  git clone ${branch/#/--branch } "git@bitbucket.org:drupalorg-infrastructure/${fqdn}.git" "${web_path}/make"
  make_file="${web_path}/make/${fqdn}.make"
fi

# Append dev-specific overrides.
if [ "${site}" != "groups" -a "${site}" != "qa" ]; then
  curl 'https://bitbucket.org/drupalorg-infrastructure/drupal.org-sites-common/raw/7.x/drupal.org-dev.make' >> "${make_file}"
fi

# Run drush make.
drush make --no-cache "${make_file}" "${web_path}/htdocs" --working-copy --no-gitinfofile --concurrency=4

if [ -f "${web_path}/htdocs/sites/all/themes/bluecheese/Gemfile" ]; then
  # Compile bluecheese Sass.
  pushd "${web_path}/htdocs/sites/all/themes/bluecheese"
  /opt/puppetlabs/puppet/bin/bundle install
  /opt/puppetlabs/puppet/bin/bundle exec compass compile
  popd
fi

# Copy static files.
[ -f "${web_path}/make/.gitignore" ] && cp "${web_path}/make/.gitignore" "${web_path}/htdocs/"  # Replace core's file
if [ -d "${web_path}/make/static-files" ]; then
  pushd "${web_path}/make/static-files"
  find . -type f | cpio -pdmuv "${web_path}/htdocs"
  popd
fi

# If Composer Manager module is present, run Composer.
if [ -d "${web_path}/htdocs/sites/default/composer" ]; then
  composer --working-dir="${web_path}/htdocs/sites/default/composer" install
fi

# Add settings.local.php
write_template "settings.local.php.template" "${web_path}/htdocs/sites/default/settings.local.php"

# Add .user.ini PHP settings
write_template "user.ini.template" "${web_path}/htdocs/.user.ini"
write_template "user.ini.template" "${web_path}/xhprof/htdocs/.user.ini"

# Strongarm the permissions
echo "Forcing proper permissions on ${web_path}"
sudo find "${web_path}" -type d -exec chmod g+rwx {} +
sudo find "${web_path}" -type f -exec chmod g+rw {} +
sudo chgrp -R developers "${web_path}"

# Add traces directory after global chown
mkdir -p "${web_path}/xhprof/traces"
sudo chown -R drupal_site:www-data "${web_path}/xhprof/traces"

# Add temporary files and devel mail directories after global chown.
mkdir -p "${web_path}/files-tmp"
sudo chown -R drupal_site:developers "${web_path}/files-tmp"
mkdir -p "${web_path}/devel-mail"
sudo chown -R drupal_site:developers "${web_path}/devel-mail"

# Configure the database and load the binary database snapshot
mysql -e "CREATE DATABASE ${db_name};"
mysql -e "GRANT ALL ON ${db_name}.* TO '${db_name}'@'wwwdev1.drupal.bak' IDENTIFIED BY '${db_pass}';"
ssh dbdev1.drupal.bak sudo /usr/local/drupal-infrastructure/dev/snapshot_to_dev.sh ${db_names[${site}]} ${db_name}

if [ "${site}" = "association" ]; then
  # CiviCRM is not on public dev sites.
  ${drush} pm-disable civicrm
fi

# Run any pending updates.
${drush} -v updatedb --interactive

# Disable modules that don't work well in development (yet)
${drush} pm-disable paranoia beanstalkd

# Link up the files directory
drupal_files="${web_path}/htdocs/$(${drush} status | sed -ne 's/^ *File directory path *: *\([^ ]*\).*$/\1/p')"
[ -d ${drupal_files} ] && rm -rf ${drupal_files}
ln -s /media/nfs/${fqdn} ${drupal_files}

# Sync xhprof webapp directory
rsync -av /usr/share/doc/php5-xhprof/ "${web_path}/xhprof/htdocs/"

# Reload apache with new vhost
restart_apache

# Get ready for development
${drush} vset cache 0
${drush} vset error_level 2
${drush} vdel preprocess_css
${drush} vdel preprocess_js
${drush} pm-enable devel
${drush} pm-enable views_ui
${drush} pm-enable imagecache_ui || true # May not exist on D6.
${drush} vset devel_xhprof_directory "/var/www/dev/${name}-${site}.dev.devdrupal.org/xhprof/htdocs"
${drush} vset devel_xhprof_url "https://xhprof-${name}-${site}.dev.devdrupal.org/xhprof_html"
${drush} vset mailchimp_api_key nope
${drush} vset mailchimp_api_classname MailChimpTest


# Set up for potential bakery testing
${drush} vdel bakery_slaves
if [ "${site}" == "drupal" ]; then
  # Drupal.org sites are masters
  ${drush} vset bakery_master "https://${name}-${site}.dev.devdrupal.org/"
  ${drush} vset bakery_key "$(pwgen -s 32 1)"

  # Clean up solr and create a read-only core
  ${drush} vset apachesolr_default_environment solr_0
  ${drush} solr-set-env-url --id="solr_0" http://solrdev1.drupal.bak:8983/solr/do-core1
  ${drush} solr-vset --id="solr_0" --yes apachesolr_read_only 1
  ${drush} ev "apachesolr_environment_delete(solr_0_0)"

else
  if [ "${bakery_master-}" ]; then
    # Hook up to a Drupal.org
    ${drush} vset bakery_master "https://${bakery_master}-drupal.dev.devdrupal.org/"
    drush_master="drush -r /var/www/dev/${bakery_master}-drupal.dev.devdrupal.org/htdocs -l ${bakery_master}-drupal.dev.devdrupal.org -y"
    ${drush} vset bakery_key $(${drush_master} vget bakery_key --exact --format=string)
    ${drush_master} bakery-add-slave "https://${name}-${site}.dev.devdrupal.org/"
  else
    # Don't bother with bakery
    ${drush} pm-disable bakery
  fi
fi

# Set up test user
${drush} upwd bacon --password=bacon || true

# Prime any big caches
curl --insecure --retry 3 --retry-delay 10 "https://drupal:drupal@${name}-${site}.dev.devdrupal.org" > /dev/null
