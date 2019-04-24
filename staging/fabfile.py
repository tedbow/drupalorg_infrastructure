from fabric.api import *

# Hosts for staging
env.hosts = ["btchstg1.drupal.bak", "wwwstg1.drupal.bak", "wwwstg2.drupal.bak"]

# Set clone path based on deploy.sh uri
clone_path = ("/var/www/%s/htdocs" % env.uri)

# Per site configurations
if env.uri == "staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/drupal.org-built.git"
    files_path = ("files")
elif env.uri == "api.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/api.drupal.org-built.git"
    files_path = ("sites/default/files")
elif env.uri == "assoc.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/assoc.drupal.org-built.git"
    files_path = ("files")
elif env.uri == "events.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/events.drupal.org-built.git"
    files_path = ("sites/default/files")
elif env.uri == "groups.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/groups.drupal.org-built.git"
    files_path = ("files")
elif env.uri == "jobs.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/jobs.drupal.org-built.git"
    files_path = ("sites/default/files")
elif env.uri == "localize.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/localize.drupal.org-built.git"
    files_path = ("sites/default/files")
elif env.uri == "security.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/security.drupal.org-built.git"
    files_path = ("sites/default/files")
else:
    quit(1)


@parallel
def deploy():
    with cd("%s" % clone_path):
        run("git fetch --prune")
        if env.branch:
            run("git fetch origin %s:%s" % (env.branch, env.branch))
            run("git checkout %s" % (env.branch))
            run("git branch --set-upstream-to=origin/%s %s" % (env.branch, env.branch))
        run("git pull")

@parallel
def clone():
    run("mkdir -p %s" % clone_path)
    run("chown bender:bender %s" % clone_path)
    run("git clone %s %s" % (repo_url,clone_path))

def symlink():
    if files_path:
        run("sudo /bin/ln -sfv /mnt/nfs/%s/files-tmp/ %s/../files-tmp" % (env.uri,clone_path))
        run("sudo /bin/ln -sfv /mnt/nfs/%s/htdocs/%s %s/%s" % (env.uri,files_path,clone_path,files_path))
        run("sudo /bin/ln -sfv /mnt/nfs/%s/htdocs/sites/default/settings.local.php %s/sites/default/settings.local.php" % (env.uri,clone_path))
        # CiviCRM on assoc also needs its files/settings symlinked
        if env.uri == "assoc.staging.devdrupal.org":
            run("sudo /bin/ln -sfv /mnt/nfs/%s/htdocs/sites/default/civicrm.settings.local.php %s/sites/default/civicrm.settings.local.php" % (env.uri,clone_path))
            run("sudo /bin/ln -sfv /mnt/nfs/%s/civicrm-files/ %s/../civicrm-files" % (env.uri,clone_path))
            run("sudo /bin/ln -sfv /mnt/nfs/%s/civicrm-sessions/ %s/../civicrm-sessions" % (env.uri,clone_path))
        # private-files dirs
        if env.uri == "jobs.staging.devdrupal.org":
            run("sudo /bin/ln -sfv /mnt/nfs/%s/files-private/ %s/../files-private" % (env.uri,clone_path))

