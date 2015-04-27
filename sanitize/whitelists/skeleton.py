from whitelists.drupalorg import whitelist

"""@skeleton docstring
The skeleton dataset is the lightest weight of all images.

  * fully sanitized
  * heavily trimmed

It is suitable for work on:

  * the unbranded D.o theme
  * case studies
  * issue queue

It is NOT suitable for work on:

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

cleanup = ""
#cleanup += """
#  -- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
#  DELETE f FROM field_data_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
#  DELETE f FROM field_revision_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
#  DELETE f FROM field_data_comment_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
#  DELETE f FROM field_revision_comment_body AS f INNER JOIN node n ON (f.entity_id = n.nid AND f.entity_type = 'node' AND n.status <> 1);
#
#  -- Get rid of unpublished/blocked nodes, users, comments and related data in other tables.
#  DELETE FROM node WHERE status <> 1;
#  DELETE FROM comment WHERE status <> 1;
#  DELETE node FROM node LEFT JOIN users ON node.uid = users.uid WHERE users.uid IS NULL;
#  DELETE node_revision FROM node_revision LEFT JOIN node ON node.nid = node_revision.nid WHERE node.nid IS NULL;
#  DELETE comment FROM comment LEFT JOIN node ON node.nid = comment.nid WHERE node.nid IS NULL;
#  DELETE comment FROM comment LEFT JOIN users ON comment.uid = users.uid WHERE users.uid IS NULL;
#  DELETE comment FROM comment LEFT JOIN comment c2 ON comment.pid = c2.cid WHERE c2.cid IS NULL AND comment.pid <> 0;
#  DELETE files FROM files LEFT JOIN users ON files.uid = users.uid WHERE users.uid IS NULL;
#  DELETE file_managed FROM file_managed LEFT JOIN users ON file_managed.uid = users.uid WHERE users.uid IS NULL;
#  DELETE image FROM image LEFT JOIN node ON image.nid = node.nid WHERE node.nid IS NULL;
#""".split(';')
