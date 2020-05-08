#!/bin/bash
{
  # Exit immediately on uninitialized variable or error, and print each command.
  set -uex -o noglob

  find ~/subtree-vaults-snapshot -mindepth 1 -print0 | xargs -0 --verbose -I{} sh -c 'rm -r /var/lib/subtree-splits/subtree-vaults/$(basename --suffix .tar.gz {}) && tar xf {} --preserve-permissions --directory=/var/lib/subtree-splits/subtree-vaults'
}
