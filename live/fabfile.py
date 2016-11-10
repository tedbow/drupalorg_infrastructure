from fabric.api import *

# Hosts for production
env.hosts = ["jenkins1.drupal.org","www1.drupal.org","www2.drupal.org","www6.drupal.org","www7.drupal.org"]

# Set clone path based on deploy.sh uri
clone_path = ("/var/www/%s/htdocs" % env.uri)

# Per site configurations
if env.uri == "drupal.org":
    # www also gets deployed to git servers
    env.hosts.extend(["git1.drupal.org", "git2.drupal.org"])
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
        run("sudo /bin/ln -sfv /mnt/nfs/%s/files-tmp %s/../files-tmp" % (env.uri,clone_path))
        run("sudo /bin/ln -sfv /mnt/nfs/%s/htdocs/%s %s/%s" % (env.uri,files_path,clone_path,files_path))
        run("sudo /bin/ln -sfv /mnt/nfs/%s/htdocs/sites/default/settings.local.php %s/sites/default/settings.local.php" % (env.uri,clone_path))
        # CiviCRM on assoc also needs its files/settings symlinked
        if env.uri == "association.drupal.org":
            run("sudo /bin/ln -sfv /mnt/nfs/%s/htdocs/sites/default/civicrm.settings.local.php %s/sites/default/civicrm.settings.local.php" % (env.uri,clone_path))
            run("sudo /bin/ln -sfv /mnt/nfs/%s/civicrm-files %s/../civicrm-files" % (env.uri,clone_path))
            run("sudo /bin/ln -sfv /mnt/nfs/%s/civicrm-sessions %s/../civicrm-sessions" % (env.uri,clone_path))
        # private-files dirs
        if env.uri == "jobs.drupal.org":
            run("sudo /bin/ln -sfv /mnt/nfs/%s/files-private %s/../files-private" % (env.uri,clone_path))
        if env.uri == "security.drupal.org":
            run("sudo /bin/ln -sfv /mnt/nfs/%s/files %s/../files" % (env.uri,clone_path))

def symlinkstatic():
    run("sudo /bin/ln -sfv /mnt/nfs/amsterdam2014.drupal.org /var/www/amsterdam2014.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/austin2014.drupal.org /var/www/austin2014.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/drupalcamp.org /var/www/drupalcamp.org")
    run("sudo /bin/ln -sfv /mnt/nfs/barcelona2007.drupalcon.org /var/www/barcelona2007.drupalcon.org")
    run("sudo /bin/ln -sfv /mnt/nfs/boston2008.drupalcon.org /var/www/boston2008.drupalcon.org")
    run("sudo /bin/ln -sfv /mnt/nfs/chicago2011.drupal.org /var/www/chicago2011.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/cph2010.drupal.org /var/www/cph2010.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/dc2009.drupalcon.org /var/www/dc2009.drupalcon.org")
    run("sudo /bin/ln -sfv /mnt/nfs/denver2012.drupal.org /var/www/denver2012.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/latinamerica2015.drupal.org /var/www/latinamerica2015.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/london2011.drupal.org /var/www/london2011.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/munich2012.drupal.org /var/www/munich2012.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/paris2009.drupalcon.org /var/www/paris2009.drupalcon.org")
    run("sudo /bin/ln -sfv /mnt/nfs/portland2013.drupal.org /var/www/portland2013.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/prague2013.drupal.org /var/www/prague2013.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/sf2010.drupal.org /var/www/sf2010.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/saopaulo2012.drupal.org /var/www/saopaulo2012.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/sydney2013.drupal.org /var/www/sydney2013.drupal.org")
    run("sudo /bin/ln -sfv /mnt/nfs/szeged2008.drupalcon.org /var/www/szeged2008.drupalcon.org")
    run("sudo /bin/ln -sfv /mnt/nfs/qa.drupal.org /var/www/qa.drupal.org")
