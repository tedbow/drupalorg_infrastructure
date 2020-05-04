#!/bin/bash
# Exit immediately on uninitialized variable or error, and print each command.
set -uex -o noglob

VALID_DAYS=90

# Root Authority: Generate the new expiration date. The date command takes different offset arguments on Linux/MacOS.
(date -u --date=+${VALID_DAYS}days +%Y-%m-%d 2> /dev/null || date -u -v +${VALID_DAYS}d +%Y-%m-%d) > expiration.tmp

# Signing Oracle: Generate the new intermediate keypair with Signify: 
ssh sign.drupal.bak "signify-openbsd -G -n -p intermediate-$(cat expiration.tmp).pub -s intermediate-$(cat expiration.tmp).sec -c 'Intermediate generated $(date -u)'"

# Network: Copy intermediate<date>.pub from the Signing Oracle to the Root Authority. The integrity -- but not secrecy -- of this transfer is critical.
scp sign.drupal.bak:"intermediate-$(cat expiration.tmp).pub" .

# Root Authority: Prepare the data to be signed.
cat expiration.tmp "intermediate-$(cat expiration.tmp).pub" > intermediate.tmp
