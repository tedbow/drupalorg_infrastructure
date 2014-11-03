# Create a local, non-LDAP user for dev-only use.

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

sudo /usr/sbin/useradd -m -g users -G developers "${username}"
sudo mkdir "/home/${username}/.ssh"
sudo bash -c "echo \"${sshkey}\" >> /home/${username}/.ssh/authorized_keys"
sudo chown "${username}:users" "/home/${username}/.ssh/authorized_keys"
