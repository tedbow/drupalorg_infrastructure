from fabric.api import *

# Hosts for production
env.hosts = ["jenkins1.drupal.org"]

# Set clone path based on deploy.sh uri
clone_path = ("/var/www/%s/htdocs" % env.uri)

# Per site configurations
if env.uri == "drupal.org":
    # www also gets deployed to git servers
    #env.hosts.extend(["git1.drupal.bak", "git2.drupal.bak"])
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/drupal.org-built.git"
    files_path = ("files")
elif env.uri == "api.drupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/api.drupal.org-built.git"
    files_path = ("sites/default/files")
elif env.uri == "association.drupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/assoc.drupal.org-built.git"
    files_path = ("files")
elif env.uri == "events.drupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/events.drupal.org-built.git"
    files_path = ("sites/default/files")
elif env.uri == "groups.drupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/groups.drupal.org-built.git"
    files_path = ("files")
elif env.uri == "jobs.drupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/jobs.drupal.org-built.git"
    files_path = ("sites/default/files")
elif env.uri == "localize.drupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/localize.drupal.org-built.git"
    files_path = ("sites/default/files")
elif env.uri == "security.drupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/security.drupal.org-built.git"
    files_path = ("sites/default/files")
elif env.uri == "updates.drupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/updates.drupal.org.git"
elif env.uri == "ftp.drupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/ftp.drupal.org.git"
else:
    quit(1)


@parallel
def deploy():
    with cd("%s" % clone_path):
        run("git pull")
        #run("sudo /usr/sbin/service php5-fpm reload")

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
        if env.uri == "assoc.drupal.org":
            run("sudo /bin/ln -sfv /mnt/nfs/%s/htdocs/sites/default/civicrm.settings.local.php %s/sites/default/civicrm.settings.local.php" % (env.uri,clone_path))
            run("sudo /bin/ln -sfv /mnt/nfs/%s/civicrm-files/ %s/../civicrm-files" % (env.uri,clone_path))

