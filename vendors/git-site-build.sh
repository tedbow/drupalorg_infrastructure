###Call with sitename (which is also the git repo name, core version, and stg/prod
set -uex
export TERM=dumb
BUILDBASE='/var/git/builds'
branches=(stg prod) ## Warning, the will not add the branch to the git repo, please create the branch before running this
versions=(6 7 8)
if [ -z "$1" ]; then
  echo "Need site string"
  exit 1
fi
if [[ ! ${branches[*]} =~ "$3" ]]; then 
  echo "bad branch"
  exit 1
fi
if [[ ! ${versions[*]} =~ "$2" ]]; then
  echo "bad version"
  exit 1
fi

branch=${2}.x-${3}
BUILDPATH="${1}"
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

# Clone built repo.
/usr/bin/git clone -b ${branch} git@bitbucket.org:drupalorg-infrastructure/${BUILDPATH}.git ${MASTER}
cd ${MASTER}

# Make sure branch exists.
if [ "$(git rev-parse --abbrev-ref HEAD)" != "${branch}" ]; then
  git checkout -b "${branch}"
fi

LOG=`/usr/bin/git log -1 --oneline`
LOG=${LOG//[^a-zA-Z0-9_ ]/}  #check_plain the log entry.
echo ${LOG}
echo "We have a copy of the master repo, we are starting the build now"
/usr/bin/drush make ${BUILDPATH}.make ${BUILDDIR}
/usr/bin/git clone -b ${branch} git@bitbucket.org:drupalorg-infrastructure/${BUILDPATH}-built.git ${BUILDGIT} 
##This is hackish, however, we can either do an rm-rf or move the .git folder, in the end, it seems to be the same.
mv ${BUILDGIT}/.git ${BUILDDIR}
#We now move settings.php.  
cp ${MASTER}/settings.php ${BUILDDIR}/sites/default/
cp ${MASTER}/.gitignore ${BUILDDIR}/  #replace core's file

#now we force a git commit
cd ${BUILDDIR}
git add -A
git commit -a -m "${LOG}"
git status
git push --set-upstream origin ${branch}


###TODO: Clean up the 3 build dirs---or not?
