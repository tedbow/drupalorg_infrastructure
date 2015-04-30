# Create a development environment for a given "name" on devwww/devdb

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

if [ "${site}" = "localize_7" ]; then
  snapshot="localize_database_snapshot.dev-current.sql.bz2"
  git_options="--branch 7.x-prod"
else
  snapshot="${site}_database_snapshot.dev-current.sql.bz2"
fi

export TERM=dumb
drush="drush6 -r ${web_path}/htdocs -y"
db_pass=$(pwgen -s 16 1)

[ -e "${web_path}" ] && echo "Project webroot already exists!" && exit 1

# Create the webroot and add comment file
mkdir "${web_path}"
mkdir -p "${web_path}/xhprof/htdocs"
chown -R bender:developers "${web_path}"
echo "${COMMENT}" > "${web_path}/comment"

# Create the vhost config
write_template "vhost.conf.template" "${vhost_path}"

# Configure the database
mysql -e "CREATE DATABASE ${db_name};"
mysql -e "GRANT ALL ON ${db_name}.* TO '${db_name}'@'devwww1.drupal.aws' IDENTIFIED BY '${db_pass}';"

# Clone make file.
if [ "${site}" == "association" ]; then
  git clone "git@bitbucket.org:drupalorg-infrastructure/assoc.drupal.org.git" "${web_path}/make"
  make_file="${web_path}/make/assoc.drupal.org.make"
else
  git clone ${git_options-} "git@bitbucket.org:drupalorg-infrastructure/${fqdn}.git" "${web_path}/make"
  make_file="${web_path}/make/${fqdn}.make"
fi

# Append dev-specific overrides.
if [ "${site}" != "groups" -a "${site}" != "qa" -a "${site}" != "localize" ]; then
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
[ -f "${web_path}/make/settings.php" ] && cp "${web_path}/make/settings.php" "${web_path}/htdocs/sites/default/"
[ -f "${web_path}/make/.gitignore" ] && cp "${web_path}/make/.gitignore" "${web_path}/htdocs/"  # Replace core's file
if [ -d "${web_path}/make/static-files" ]; then
  pushd "${web_path}/make/static-files"
  find . -type f | cpio -pdmuv "${web_path}/htdocs"
  popd
fi

# If Symfony module is present, run Composer.
if [ -d "${web_path}/htdocs/sites/all/modules/symfony" ]; then
  pushd "${web_path}/htdocs/sites/all/modules/symfony"
  # We do want to check composer.lock and vendors in.
  rm -v ".gitignore"
  # static-files/sites/all/modules/symfony/composer.lock is copied over by the
  # previous step.
  composer install
  popd
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

# Add temporary files directory after global chown
mkdir -p "${web_path}/files-tmp"
sudo chown -R apache:developers "${web_path}/files-tmp"

# Import database
rsync -v --copy-links --password-file ~/util.rsync.pass "rsync://devmysql@dbutil.drupal.org/mysql-dev/${snapshot}" "${WORKSPACE}"
bunzip2 < "${WORKSPACE}/${snapshot}" | mysql "${db_name}"
${drush} sql-cli <<END
  -- InnoDB handles the url alias table much faster.
  ALTER TABLE url_alias ENGINE InnoDB;
END

if [ "${site}" = "association" ]; then
  # CiviCRM is not on public dev sites.
  ${drush} pm-disable civicrm
elif [ "${site}" = "localize_7" ]; then
  . staging/localize_7.sh
  localize_7_pre_update
fi

# Run any pending updates.
${drush} -v updatedb --interactive

if [ "${site}" = "localize_7" ]; then
  localize_7_post_update
fi

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
${drush} pm-enable imagecache_ui
${drush} vset devel_xhprof_directory "/var/www/dev/${name}-${site}.redesign.devdrupal.org/xhprof/htdocs"
${drush} vset devel_xhprof_url "https://xhprof-${name}-${site}.redesign.devdrupal.org/xhprof_html"

# Set up for potential bakery testing
${drush} vdel bakery_slaves
if [ "${site}" == "drupal" ]; then
  # Drupal.org sites are masters
  ${drush} vset bakery_master "https://${name}-${site}.redesign.devdrupal.org/"
  ${drush} vset bakery_key "$(pwgen -s 32 1)"
else
  if [ "${bakery_master-}" ]; then
    # Hook up to a Drupal.org
    ${drush} vset bakery_master "https://${bakery_master}-drupal.redesign.devdrupal.org/"
    drush_master="drush6 -r /var/www/dev/${bakery_master}-drupal.redesign.devdrupal.org/htdocs -l ${bakery_master}-drupal.redesign.devdrupal.org -y"
    ${drush} vset bakery_key $(${drush_master} vget bakery_key --exact --format=string)
    ${drush_master} bakery-add-slave "https://${name}-${site}.redesign.devdrupal.org/"
  else
    # Don't bother with bakery
    ${drush} pm-disable bakery
  fi
fi

# Set up test user
${drush} upwd bacon --password=bacon || true

# Prime any big caches
wget --no-check-certificate -O /dev/null https://${name}-${site}.redesign.devdrupal.org --user=drupal --password=drupal
