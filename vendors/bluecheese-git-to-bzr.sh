# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Jenkins job tracks git@bitbucket.org:drupalorg-infrastructure/bluecheese-private.git
cd ${WORKSPACE}

# Cleanup, in case a previous build failed.
rm -rf archive.tar bzr-vendor

# Get the BZR copy of the theme.
bzr checkout --lightweight /bzr/bluecheese-7 bzr-vendor

# Import Git archive to BZR.
git archive origin/branded > archive.tar
bzr import archive.tar bzr-vendor
cd bzr-vendor
bzr commit -m "Import from Git."
cd ..

# Cleanup.
rm -rf archive.tar bzr-vendor
