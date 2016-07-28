# Exit immediately on uninitialized variable or error, and print each command.
set -uex

# Jenkins job tracks http://git.drupal.org/project/bluecheese.git
cd /var/git/bluecheese

# Make sure remote exists and is updated.
git remote show private || git remote add private ssh://git@bitbucket.org/drupalorg-infrastructure/bluecheese-private.git
git fetch private

# Reset Git repo.
git reset --hard HEAD

# Mirror changes.
git checkout 7.x-2.x
git pull
git push private 7.x-2.x

# Merge changes.
git checkout branded-2.x
git pull
git merge 7.x-2.x

# Compile CSS.
bundle exec compass compile
if [ -n "$(git status --short css)" ]; then
  git add -A css
  git commit -m 'compass compile'
fi

# Push to remote.
git push private branded-2.x
