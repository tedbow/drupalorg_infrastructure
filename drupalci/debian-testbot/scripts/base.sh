#!/bin/bash -eux

date
# Install curl first, because we need it for everything else.
apt-get update
apt-get -y upgrade
apt-get -y install curl

#add the dotdeb repos so we can install php7.0
(
cat << EOF
deb http://packages.dotdeb.org jessie all
deb-src http://packages.dotdeb.org jessie all
EOF
) >> /etc/apt/sources.list.d/dotdeb.list
curl -s https://www.dotdeb.org/dotdeb.gpg | apt-key add -


# Add sysdig sources to monitor the testbot workload
curl -s https://s3.amazonaws.com/download.draios.com/DRAIOS-GPG-KEY.public | apt-key add -
curl -s -o /etc/apt/sources.list.d/draios.list http://download.draios.com/stable/deb/draios.list
# LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php

apt-get update

# Packages.
apt-get -y install bsdtar \
                   dstat \
                   gawk \
                   git \
                   grep \
                   htop \
                   iotop \
                   linux-headers-$(uname -r) \
                   make \
                   mc \
                   mysql-client \
                   nmon \
                   ntp \
                   openjdk-7-jre \
                   php7.0 \
                   php7.0-bcmath \
                   php7.0-cli \
                   php7.0-curl \
                   php7.0-dev \
                   php7.0-mbstring \
                   php7.0-mysql \
                   php7.0-pgsql \
                   php7.0-sqlite3 \
                   php7.0-xdebug \
                   php7.0-xml \
                   php-pear \
                   python \
                   sqlite3 \
                   ssh \
                   sudo \
                   sysstat \
                   sysdig \
                   vim \
                   wget
apt-get clean
apt-get -y autoremove
# we want xdebug there, just disabled.
phpdismod xdebug

# Composer.

EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
then
    >&2 echo 'ERROR: Invalid installer signature'
    rm composer-setup.php
    exit 1
fi

php composer-setup.php --filename=composer --install-dir=/usr/local/bin --version=1.3.0-RC
RESULT=$?
rm composer-setup.php

chmod +x /usr/local/bin/composer && ln -s /usr/local/bin/composer /usr/bin/composer

sed -i 's/variables_order = \"GPCS\"/variables_order = \"EGPCS\"/g' /etc/php/7.0/cli/php.ini

(
cat << EOF
kernel.core_pattern = /var/lib/drupalci/coredumps/core.%e.%s.%t
kernel.core_uses_pid = 1
fs.suid_dumpable = 2
fs.aio-max-nr = 1048576

EOF
) >> /etc/sysctl.conf

(
cat << EOF
*               soft    core            unlimited
*               hard    core            unlimited
EOF
) >> /etc/security/limits.conf




# Tweak sshd to prevent DNS resolution (speed up logins)
# echo 'UseDNS no' >> /etc/ssh/sshd_config

# Remove 5s grub timeout to speed up booting
cat <<EOF > /etc/default/grub
# If you change this file, run 'update-grub' afterwards to update
# /boot/grub/grub.cfg.

GRUB_DEFAULT=0
GRUB_TIMEOUT=0
GRUB_DISTRIBUTOR=`lsb_release -i -s 2> /dev/null || echo Debian`
GRUB_CMDLINE_LINUX_DEFAULT="quiet"
GRUB_CMDLINE_LINUX="debian-installer=en_US"
EOF

update-grub
