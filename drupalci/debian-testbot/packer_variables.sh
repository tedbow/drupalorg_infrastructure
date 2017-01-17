# Debian Jessie ISO (sha512 checksum)
#export PACKER_DEBIAN_ISO_URL="$HOME/home/software_archive/linux_isos/debian/debian-8.2.0-amd64-netinst.iso"
export PACKER_DEBIAN_ISO_URL="http://cdimage.debian.org/debian-cd/8.7.0/amd64/iso-cd/debian-8.7.0-amd64-netinst.iso"
export PACKER_DEBIAN_ISO_SUM="892e5b64f81a637101404fb6e2caa44b497cf98e4d6cdab71dfec440c56d8544972ba17bc0ad1cef93b8b6eed1e41b8c9c771d09b0738b27514ff63f6dc2f51c"

# User to be created
export PACKER_SSH_USER="vagrant"
export PACKER_SSH_PASS="vagrant"

# VirtualBox additions ISO (sha256 checksum)
export PACKER_VBOX_ISO_URL="/usr/share/virtualbox/VBoxGuestAdditions.iso"
export PACKER_VBOX_ISO_SUM="e5b425ec4f6a62523855c3cbd3975d17f962f27df093d403eab27c0e7f71464a"

# AWS credentials
# not declared here because they're sourced from AWS config files

