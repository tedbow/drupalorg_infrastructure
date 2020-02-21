#!/bin/bash
# Exit immediately on uninitialized variable or error, and print each command.
set -uex -o noglob

# Root Authority: Begin to assemble into our intermediate.xpub
echo 'untrusted comment: verify with root.pub at https://drupal.org/keys/root.pub' > intermediate.xpub

# Root Authority: Append the signature to our intermediate.xpub file encoded in Base64. Format is Ed, the 8-byte “key number” matching the root key, then the signature from the HSM.
(echo -n "Ed$(curl --silent https://www.drupal.org/keys/root.pub | tail -n1 | base64 --decode | cut -b 3-10)"; base64 --decode < intermediate.xpub.signature.tmp) | base64 >> intermediate.xpub

# Root Authority: Append the expiration date, intermediate comment, and public key.
cat intermediate.tmp >> intermediate.xpub

# Network: Transfer intermediate.xpub from the Root Authority to the Signing Oracle. There are no sensitive aspects to this transfer. (The data here is intended for public distribution, and data manipulation in transit can only cause the system to fail, not be compromised.)
scp intermediate.xpub sign.drupal.bak:"intermediate-$(cat expiration.tmp).xpub"
