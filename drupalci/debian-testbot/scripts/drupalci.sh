#!/bin/bash -eux

date

if [[ ! -d "/home/testbot" ]]; then
    /usr/sbin/groupadd testbot
    /usr/sbin/useradd -g testbot -p $(perl -e'print crypt("testbot", "testbot")') -m -s /bin/bash testbot
fi
usermod -a -G sudo testbot

# (setting permissions before moving file to sudoers.d)
echo '%testbot ALL=NOPASSWD:ALL' > /tmp/testbot
chmod 0440 /tmp/testbot
mv /tmp/testbot /etc/sudoers.d/


DIR="/opt/drupalci"
TESTRUNNER_DIR="${DIR}/testrunner"
DRUPAL_DIR="${DIR}/drupal-checkout"
COMPOSER_CACHE_DIR="${DIR}/composer-cache"
mkdir ${COMPOSER_CACHE_DIR}
composer config -g cache-dir ${COMPOSER_CACHE_DIR}
git clone --branch production http://git.drupal.org/project/drupalci_testbot.git ${TESTRUNNER_DIR}
composer install --prefer-dist --no-progress --working-dir ${TESTRUNNER_DIR}
chown -R testbot:testbot ${TESTRUNNER_DIR}

chmod 775 ${TESTRUNNER_DIR}/drupalci
ln -s ${TESTRUNNER_DIR}/drupalci /usr/local/bin/drupalci
mkdir -p /home/testbot/testrunner

# Lets prepopulate the composer cache
git clone http://git.drupal.org/project/drupal.git ${DRUPAL_DIR}
composer install --prefer-dist --no-progress --working-dir ${DRUPAL_DIR}
chown -R testbot:testbot ${COMPOSER_CACHE_DIR}

# install csslint and eslint on the host system
npm -g install csslint
npm -g install eslint

sed -i 's/; sys_temp_dir = "\/tmp"/sys_temp_dir = "\/var\/lib\/drupalci\/workspace\/"/g' /etc/php/7.1/cli/php.ini

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
rsync -a /opt/drupalci/drupal-checkout/ /var/lib/drupalci/drupal-checkout
chmod 777 /var/lib/drupalci/docker-tmp
chmod 777 /var/lib/drupalci/coredumps
chown -R testbot:testbot /var/lib/drupalci
chown -R testbot:testbot /home/testbot/.*
chown -R testbot:testbot /home/testbot
touch /home/testbot/.jenkins_ready

exit 0
EOF
) >> /etc/rc.local
