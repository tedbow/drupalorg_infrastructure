#/bin/bash
source /usr/local/drupal-infrastructure/dev/aws_common.sh

DATE=$(date +'%Y%m%d%H%M')
DESCRIPTOR="auto_devwww2_/dev"

# devwww2-root
create_ebs_snapshot 'vol-8bc83a6d' "${DATE}_${DESCRIPTOR}/sda1"

# devwww2-www
create_ebs_snapshot 'vol-2f36c4c9' "${DATE}_${DESCRIPTOR}/sdg"

# devwww2-dockerlvm 20160316
create_ebs_snapshot 'vol-cf09b976' "${DATE}_${DESCRIPTOR}/sdi"

# devwww2-legacy-mysql
create_ebs_snapshot 'vol-242efbc2' "${DATE}_${DESCRIPTOR}/sdj"

# devwww2-btrfs-media
create_ebs_snapshot 'vol-40f327a6' "${DATE}_${DESCRIPTOR}/sdk"

# devwww2 dumps
create_ebs_snapshot 'vol-2befd3cd' "${DATE}_${DESCRIPTOR}/sdl"
