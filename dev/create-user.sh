#!/bin/bash
# Create a local, non-LDAP user for dev-only use.

# Exit immediately on uninitialized variable or error, and print each command.
set -uex

sudo /usr/sbin/useradd --create-home --gid users --groups developers --shell /bin/bash "${username}"
sudo mkdir "/home/${username}/.ssh"
sudo bash -c "echo \"${sshkey}\" >> /home/${username}/.ssh/authorized_keys"
sudo chown -R "${username}:users" "/home/${username}/.ssh"
