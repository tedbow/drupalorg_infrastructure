"""@boss docstring

The boss dataset is intended to provide the fullest possible dataset outside of stage/prod.

It is:

 * fully santized

It is suitable for testing of:

 * all parts of Drupal.org
 * if running repo sync, note that currently that existing commit attribution links
   will break because the user's sanitized e-mail address will be used for the re-sync
   and will not match the e-mail address used in the Git repository.
"""

# Add back the data for these, which we're now removing in whitelist

  UPDATE users SET data = '', pass = 'nope'; #reset passwords and remove some profile data TODO: Is this valid for D7?
  UPDATE comment SET hostname = "127.0.0.1";
  UPDATE role_activity SET ip = "127.0.0.1";
  UPDATE sshkey SET title = "nobody@nomail.invalid";
