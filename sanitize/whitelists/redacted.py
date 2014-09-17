from whitelists.drupalorg import whitelist

"""@redacted docstring
The skeleton dataset is the lightest weight of all images.

  * fully sanitized

It is suitable for work on:[TODO: verify]

  * the unbranded D.o theme
  * case studies
  * issue queue

It is NOT suitable for work on:[TODO: verify]

  * D.o brand elements
  * commit logs
  * git
  * packaging
  * solr
"""


whitelist.update(
    table="users",
    columns=[
        "_sanitize_timestamp:access",
    ])

whitelist.update(
    table="users_access",
    columns=[
        "_sanitize_timestamp:access",
    ])

cleanup = ""
