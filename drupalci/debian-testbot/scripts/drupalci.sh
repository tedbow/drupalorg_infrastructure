#!/bin/bash -eux

date

DIR="/opt/drupalci_testbot"
DRUPAL_DIR="/opt/drupal_checkout"
COMPOSER_CACHE_DIR="/opt/composer_cache"
mkdir ${COMPOSER_CACHE_DIR}
git clone --branch production http://git.drupal.org/project/drupalci_testbot.git ${DIR}
composer install --prefer-dist --no-progress --working-dir ${DIR}
chown -R admin:admin ${DRUPAL_DIR}

chmod 775 ${DIR}/drupalci
ln -s ${DIR}/drupalci /usr/local/bin/drupalci

if ! [ -h /opt/drupalci_testbot ];
  then
    ln -s /home/admin/drupalci_testbot /opt/drupalci_testbot
fi

# Lets prepopulate the composer cache
git clone http://git.drupal.org/project/drupal.git ${DRUPAL_DIR}
composer install --prefer-dist --no-progress --working-dir ${DRUPAL_DIR}
chown -R admin:admin ${COMPOSER_CACHE_DIR}

sed -i 's/; sys_temp_dir = "\/tmp"/sys_temp_dir = "\/var\/lib\/drupalci\/workspace\/"/g' /etc/php/7.0/cli/php.ini

# Everything we do to the tmpfs directory has to
# happen *after* the tmpfs is created and mounted at boot
# time.
sed --in-place -e 's/exit 0//' /etc/rc.local
(
cat << "EOF"
#Size the tmpfs volume based on the amount of available memory
MEMSIZE=`cat /proc/meminfo |grep MemTotal |awk '{printf "%d", $2*.70;}'`
mkdir -p /var/lib/drupalci
mount -t tmpfs -o size=${MEMSIZE}k tmpfs /var/lib/drupalci
mkdir /var/lib/drupalci/workspace
mkdir /var/lib/drupalci/coredumps
mkdir /var/lib/drupalci/docker-tmp
#Copy drupal core into tmpfs memory
mkdir /var/lib/drupalci/drupal-checkout
rsync -a /opt/drupal_checkout/ /var/lib/drupalci/drupal-checkout
chmod 777 /var/lib/drupalci/docker-tmp
chmod 777 /var/lib/drupalci/coredumps

exit 0
EOF
) >> /etc/rc.local
