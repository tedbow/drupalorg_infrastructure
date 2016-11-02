from fabric.api import *

# Hosts for staging
env.hosts = ["btchstg1", "wwwstg1", "wwwstg2", "gitstg1", "gitstg2"]

# Set clone path based on deploy.sh uri
clone_path = ("/var/www/%s/htdocs" % env.uri)

# Per site configurations
if env.uri == "staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/drupal.org-built.git"
    files_src = ("%s/files" % clone_path)
    files_dst = ("/mnt/nfs/staging.devdrupal.org/htdocs/files")
elif env.uri == "api.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/api.drupal.org-built.git"
elif env.uri == "assoc.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/assoc.drupal.org-built.git"
elif env.uri == "events.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/events.drupal.org-built.git"
elif env.uri == "groups.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/groups.drupal.org-built.git"
elif env.uri == "jobs.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/jobs.drupal.org-built.git"
elif env.uri == "localize.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/localize.drupal.org-built.git"
elif env.uri == "security.staging.devdrupal.org":
    repo_url = "git@bitbucket.org:drupalorg-infrastructure/security.drupal.org-built.git"
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

