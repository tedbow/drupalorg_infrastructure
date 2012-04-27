# Exit immediately on uninitialized variable or error, and print each command.
set -uex

rm -rf ${site}
bzr co /srv/bzr/${site}
cd ${site}
bzr missing --theirs /srv/bzr/${theme} || bzr merge /srv/bzr/${theme}
bzr commit -m "Automated merge from ${theme}"
