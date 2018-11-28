#!/bin/bash

set -uex
export TERM=dumb
BUILDBASE='/var/git/builds'
if [ -z "${site}" ]; then
  echo "Need site string"
  exit 1
fi

if echo ${GIT_BRANCH} | grep -v -q '^origin/'; then
  # Upstream Jenkins jobs that poll multiple repos have “origin{1,2,…}”. Assume
  # branch names are not synced up. (They are not for jobs.)
  GIT_BRANCH="origin/7.x-prod"
fi

branch="$(echo "${GIT_BRANCH}" | sed -e 's#^origin/##')"

BUILDPATH="${site}"
#Lets do some check_plain's for bash
BUILDPATH=${BUILDPATH//[^a-zA-Z0-9_ \.]/}
MASTER="${BUILDBASE}/${BUILDPATH}"
BUILDDIR="${BUILDBASE}/${BUILDPATH}-tmp"
BUILDGIT="${BUILDBASE}/${BUILDPATH}-build"

echo "Starting build for ${BUILDPATH} ${branch}"
echo "Removing old files"
/bin/rm -rf ${MASTER}
/bin/rm -rf ${BUILDDIR}
/bin/rm -rf ${BUILDGIT}

# Clone make repo.
/usr/bin/git clone -b ${branch} git@bitbucket.org:drupalorg-infrastructure/${BUILDPATH}.git ${MASTER}
cd ${MASTER}

LOG=`/usr/bin/git log -1 --oneline`
LOG=${LOG//[^a-zA-Z0-9_ ]/}  #check_plain the log entry.
echo ${LOG}

# Build the site.
echo "We have a copy of the master repo, we are starting the build now"
drush make -v --no-cache --cache-duration-releasexml=300 --concurrency=6 ${BUILDPATH}.make ${BUILDDIR}

# Use good judgement.
/bin/rm -r "${BUILDDIR}/modules/php"
find "${BUILDDIR}" -name 'ds_format' -print0 | xargs -0 -r  /bin/rm -rv

# Clone built repo and make sure branch exists.
/usr/bin/git clone git@bitbucket.org:drupalorg-infrastructure/${BUILDPATH}-built.git ${BUILDGIT}
cd ${BUILDGIT}
if ! git checkout ${branch}; then
  git checkout -b "${branch}"
fi
cd ..

##This is hackish, however, we can either do an rm-rf or move the .git folder, in the end, it seems to be the same.
mv ${BUILDGIT}/.git ${BUILDDIR}

# Copy static files.
[ -f "${MASTER}/.gitignore" ] && cp "${MASTER}/.gitignore" "${BUILDDIR}/"  # Replace core's file
if [ -d "${MASTER}/static-files" ]; then
  pushd "${MASTER}/static-files"
  find . -type f | cpio -pdmuv "${BUILDDIR}"
  popd
fi

# If Composer Manager module is present, run Composer.
if [ -d "${BUILDDIR}/sites/default/composer" ]; then
  composer --working-dir="${BUILDDIR}/sites/default/composer" --no-dev install
fi

# Remove extra .git directories, so everything is checked in.
find * -name '.git' -type d -print0 | xargs -0 rm -v -r

#now we force a git commit
cd ${BUILDDIR}
git add -A
git commit -a -m "${LOG}"
git status
git push --set-upstream origin ${branch}

# If there is a deploy branch, merge to it.
if git branch --list --remotes | grep -q 'origin/deploy'; then
  git checkout deploy
  git merge "${branch}"
  git push origin deploy
fi

# Clean up the build dirs.
rm -rf ${MASTER}
rm -rf ${BUILDDIR}
rm -rf ${BUILDGIT}
