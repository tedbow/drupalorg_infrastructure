#/bin/bash
source /usr/local/drupal-infrastructure/dev/aws_common.sh

DATE=$(date +'%Y%m%d%H%M')
DESCRIPTOR="auto_devwww2_/dev"

# devwww2-root
create_ebs_snapshot -d "${DATE}_${DESCRIPTOR}/sda1" 'vol-8bc83a6d'

# devwww2-www
create_ebs_snapshot -d "${DATE}_${DESCRIPTOR}/sdg" 'vol-2f36c4c9'

# devwww2-dockerlvm 20160316
create_ebs_snapshot -d "${DATE}_${DESCRIPTOR}/sdi" 'vol-cf09b976'

# devwww2-legacy-mysql
create_ebs_snapshot -d "${DATE}_${DESCRIPTOR}/sdj" 'vol-242efbc2'

# devwww2-btrfs-media
create_ebs_snapshot -d "${DATE}_${DESCRIPTOR}/sdk" 'vol-40f327a6'

# devwww2 dumps
create_ebs_snapshot -d "${DATE}_${DESCRIPTOR}/sdl" 'vol-2befd3cd'
