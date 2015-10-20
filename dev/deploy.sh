# Create a development environment for a given "name" on devwww2

# Include common dev script.
. dev/common.sh

# Usage: write_template "template" "path/to/destination"
function write_template {
  sed -e "s/DB_NAME/${site}/g;s/NAME/${name}/g;s/DB_USER/${db_user}/g;s/SITE/${site}/g;s/DB_PASS/${db_pass}/g;s/DB_PORT/${CONTAINERPORT}/g" "dev/${1}" > "${2}"
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

snapshot="${site}_database_snapshot.dev-current.sql.bz2"

export TERM=dumb
drush="drush6 -r ${web_path}/htdocs -y"
db_user="root"
db_pass="drupal"

[ -e "${web_path}" ] && echo "Project webroot already exists!" && exit 1

# Create the webroot and add comment file
mkdir "${web_path}"
mkdir -p "${web_path}/xhprof/htdocs"
chown -R bender:developers "${web_path}"
echo "${COMMENT}" > "${web_path}/comment"

# Set port number
CONTAINERPORT=$((3300 + ${BUILD_NUMBER}))

# @TODO: Verify port is available
#nc -z localhost ${CONTAINERPORT}

# Create the vhost config
write_template "vhost.conf.template" "${vhost_path}"

# Clone make file.
if [ "${site}" == "association" ]; then
  git clone "git@bitbucket.org:drupalorg-infrastructure/assoc.drupal.org.git" "${web_path}/make"
  make_file="${web_path}/make/assoc.drupal.org.make"
else
  git clone "git@bitbucket.org:drupalorg-infrastructure/${fqdn}.git" "${web_path}/make"
  make_file="${web_path}/make/${fqdn}.make"
fi

# Append dev-specific overrides.
if [ "${site}" != "groups" -a "${site}" != "qa" ]; then
  curl 'https://bitbucket.org/drupalorg-infrastructure/drupal.org-sites-common/raw/7.x/drupal.org-dev.make' >> "${make_file}"
fi

# Run drush make.
drush6 make --no-cache "${make_file}" "${web_path}/htdocs" --working-copy --no-gitinfofile

if [ -f "${web_path}/htdocs/sites/all/themes/bluecheese/Gemfile" ]; then
  # Compile bluecheese Sass.
  pushd "${web_path}/htdocs/sites/all/themes/bluecheese"
  bundle install
  bundle exec compass compile
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
find "${web_path}" -type d -exec chmod g+rwx {} +
find "${web_path}" -type f -exec chmod g+rw {} +
chgrp -R developers "${web_path}"

# Add traces directory after global chown
mkdir -p "${web_path}/xhprof/traces"
sudo chown -R apache:apache "${web_path}/xhprof/traces"

# Add temporary files and devel mail directories after global chown.
mkdir -p "${web_path}/files-tmp"
sudo chown -R apache:developers "${web_path}/files-tmp"
mkdir -p "${web_path}/devel-mail"
sudo chown -R apache:developers "${web_path}/devel-mail"

# Start docker container
echo "  Starting new Mariadb container"
CONTAINERID=$(docker run --name=${container_name} -d -v /usr/local/drupal-infrastructure/dev/mysql.d:/etc/mysql/conf.d -p ${CONTAINERPORT}:3306 devwww/${site}:latest)
# Give mysql some time to load
echo "  Letting MYSQL spin up"
sleep 60
# Verfiy that the port is active
nc -z localhost ${CONTAINERPORT} || sleep 10
nc -z localhost ${CONTAINERPORT} || sleep 10

if [ "${site}" = "association" ]; then
  # CiviCRM is not on public dev sites.
  ${drush} pm-disable civicrm
fi

# Run any pending updates.
${drush} -v updatedb --interactive

# Disable modules that don't work well in development (yet)
${drush} pm-disable paranoia
${drush} pm-disable beanstalkd

# Link up the files directory
drupal_files="${web_path}/htdocs/$(${drush} status | sed -ne 's/^ *File directory path *: *\([^ ]*\).*$/\1/p')"
[ -d ${drupal_files} ] && rm -rf ${drupal_files}
ln -s /media/nfs/${fqdn} ${drupal_files}

# Sync xhprof webapp directory
rsync -av /usr/share/xhprof/ "${web_path}/xhprof/htdocs/"

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

# Set up for potential bakery testing
${drush} vdel bakery_slaves
if [ "${site}" == "drupal" ]; then
  # Drupal.org sites are masters
  ${drush} vset bakery_master "https://${name}-${site}.dev.devdrupal.org/"
  ${drush} vset bakery_key "$(pwgen -s 32 1)"

  # Clean up solr and create a read-only core
  ${drush} vset apachesolr_default_environment solr_0_1
  ${drush} solr-set-env-url --id="solr_0_1" http://devsolr1.drupal.aws:8114/solr/do-core1
  ${drush} solr-vset --id="solr_0_1" --yes apachesolr_read_only 1
  ${drush} ev "apachesolr_environment_delete(solr_0)"
  ${drush} ev "apachesolr_environment_delete(solr_0_0)"

else
  if [ "${bakery_master-}" ]; then
    # Hook up to a Drupal.org
    ${drush} vset bakery_master "https://${bakery_master}-drupal.dev.devdrupal.org/"
    drush_master="drush6 -r /var/www/dev/${bakery_master}-drupal.dev.devdrupal.org/htdocs -l ${bakery_master}-drupal.dev.devdrupal.org -y"
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
