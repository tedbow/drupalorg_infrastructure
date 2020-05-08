#!/bin/bash
{
  # Exit immediately on uninitialized variable or error, and print each command.
  set -uex -o noglob

  [ -d 'subtree-vaults-snapshot' ] || mkdir 'subtree-vaults-snapshot'
  find /var/lib/subtree-splits/subtree-vaults -mindepth 1 -maxdepth 1 -printf "%P\0" | xargs -0 --verbose -I{} tar czf 'subtree-vaults-snapshot/{}.tar.gz' --directory=/var/lib/subtree-splits/subtree-vaults {}
  rsync -a 'subtree-vaults-snapshot' btchstg1.drupal.bak:
}
