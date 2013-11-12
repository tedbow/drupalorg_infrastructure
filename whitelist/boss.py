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

# Undo the whitelist sanitization for these fields

whitelist.update(
    table="users",
    columns=[
        "pass",
        "data",
    ])

whitelist.update(
    table="comment",
    columns=[
        "hostname",
    ])

whitelist.update(
    table="role_activity",
    columns=[
        "ip",
    ])

whitelist.update(
    table="sshkey",
    columns=[
        "title",
    ])
