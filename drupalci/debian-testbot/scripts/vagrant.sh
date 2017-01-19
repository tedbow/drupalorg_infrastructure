#!/bin/bash -eux


echo "Timestamp the box..."
date '+%F %T' > /etc/issue.vagrant


echo "Fix 'stdin: is not a tty' non-fatal error message..."
sed -i '/tty/!s/mesg n/tty -s \&\& mesg n/' /root/.profile

echo "Fix 'dpkg-preconfigure: unable to re-open stdin: No such file or directory' non-fatal error message in apt..."
echo -e '\nexport DEBIAN_FRONTEND=noninteractive' >> /root/.profile
echo -e '\nexport DEBIAN_FRONTEND=noninteractive' >> /home/admin/.profile



echo "Install the insecure vagrant SSH keys..."
mkdir /home/admin/.ssh
chmod 0700 /home/admin/.ssh
curl -Lo /home/admin/.ssh/authorized_keys 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub'
chmod 0600 /home/admin/.ssh/authorized_keys
chown -R admin:admin /home/admin/.ssh


echo "Install NFS..."
# (in case it's used over VirtualBox folders; uses around 23 MB)
apt-get -y install nfs-common

