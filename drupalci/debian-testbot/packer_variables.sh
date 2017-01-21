# Debian Jessie ISO (sha512 checksum)
#export PACKER_DEBIAN_ISO_URL="$HOME/home/software_archive/linux_isos/debian/debian-8.2.0-amd64-netinst.iso"
export PACKER_DEBIAN_ISO_URL="http://cdimage.debian.org/debian-cd/8.7.1/amd64/iso-cd/debian-8.7.1-amd64-netinst.iso"
export PACKER_DEBIAN_ISO_SUM="534795785d2706e64e3a4dff9648fd0302a1272c668a99a81ba3a984695986ac814d8193c5335bd13dce0592fc470eebe9fc4a6c9991f87a6686329a667ac30d"

# User to be created
export PACKER_SSH_USER="testbot"
export PACKER_SSH_PASS="testbot"

# VirtualBox additions ISO (sha256 checksum)
export PACKER_VBOX_ISO_URL="/usr/share/virtualbox/VBoxGuestAdditions.iso"
export PACKER_VBOX_ISO_SUM="e5b425ec4f6a62523855c3cbd3975d17f962f27df093d403eab27c0e7f71464a"

# AWS credentials
# not declared here because they're sourced from AWS config files

