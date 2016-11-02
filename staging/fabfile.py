from fabric.api import *

# Hosts for staging
env.hosts = ["btchstg1", "wwwstg1", "wwwstg2", "gitstg1", "gitstg2"]

# Per site configurations
if env.site == "drupal":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/drupal.org-built.git"
    clone_path = "/var/www/staging.devdrupal.org/htdocs"
elif env.site == "api":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/api.drupal.org-built.git"
    clone_path = "/var/www/api.staging.devdrupal.org/htdocs"
elif env.site == "assoc":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/assoc.drupal.org-built.git"
    clone_path = "/var/www/assoc.staging.devdrupal.org/htdocs"
elif env.site == "events":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/events.drupal.org-built.git"
    clone_path = "/var/www/events.staging.devdrupal.org/htdocs"
elif env.site == "groups":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/groups.drupal.org-built.git"
    clone_path = "/var/www/groups.staging.devdrupal.org/htdocs"
elif env.site == "jobs":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/jobs.drupal.org-built.git"
    clone_path = "/var/www/jobs.staging.devdrupal.org/htdocs"
elif env.site == "localize":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/localize.drupal.org-built.git"
    clone_path = "/var/www/localize.staging.devdrupal.org/htdocs"
elif env.site == "security":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/security.drupal.org-built.git"
    clone_path = "/var/www/security.staging.devdrupal.org/htdocs"
else:
    sys.exit(1)


@parallel
def deploy():
    with cd("%s" % clone_path):
        run("git pull")
        run("sudo service php5-fpm reload")

@parallel
def clone():
    run("mkdir -p %s" % clone_path)
    run("git clone %s %s" % (repo_url,clone_path))

