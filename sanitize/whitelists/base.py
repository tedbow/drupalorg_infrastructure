#!/bin/env python

import whitelistclass

whitelist = whitelistclass.Whitelist()

whitelist.add(
    table="actions",
    columns=[
        "aid",
        "type",
        "callback",
        "parameters",
        "label",
    ])

whitelist.add(
    table="authmap",
    columns=[
        # http://drupalcode.org/project/infrastructure.git/blob/HEAD:/snapshot/common.staging.sql#l3
        "aid",
        "uid",
        "_sanitize_email:authname",
        "module",
    ])

whitelist.add(
    table="bakery_user",
    columns=[
        "uid",
        "slave",
        "slave_uid",
    ])

whitelist.add(
    table="_nodata:batch",
    columns=[
        "bid",
        "token",
        "timestamp",
        "batch",
    ])

whitelist.add(
    table="block",
    columns=[
        "module",
        "delta",
        "status",
        "weight",
        "region",
        "custom",
        "visibility",
        "pages",
        "theme",
        "title",
        "bid",
        "cache",
    ])

whitelist.add(
    table="block_custom",
    columns=[
        "bid",
        "body",
        "info",
        "format",
    ])

whitelist.add(
    table="block_node_type",
    columns=[
        "module",
        "delta",
        "type",
    ])

whitelist.add(
    table="block_role",
    columns=[
        "module",
        "delta",
        "rid",
    ])

whitelist.add(
    table="_nodata:blocked_ips",
    columns=[
        "iid",
        "ip",
    ])

whitelist.add(
    table="book",
    columns=[
        "mlid",
        "nid",
        "bid",
    ])

whitelist.add(
    table="bueditor_buttons",
    columns=[
        "bid",
        "eid",
        "title",
        "content",
        "icon",
        "accesskey",
        "weight",
    ])

whitelist.add(
    table="bueditor_editors",
    columns=[
        "eid",
        "name",
        "pages",
        "excludes",
        "iconpath",
        "librarypath",
        "spriteon",
        "spritename",
    ])

whitelist.add(
    table="_nodata:cache",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_block",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_bootstrap",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_field",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_filter",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_form",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_image",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_menu",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_page",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_path",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_token",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_update",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_views",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="_nodata:cache_views_data",
    columns=[
        "cid",
        "data",
        "expire",
        "created",
        "serialized",
    ])

whitelist.add(
    table="comment",
    columns=[
        "cid",
        "pid",
        "nid",
        "uid",
        "subject",
        "_sanitize_ip:hostname",
        "changed",
        "status",
        "thread",
        "name",
        # http://drupalcode.org/project/infrastructure.git/blob/HEAD:/snapshot/drupal.staging.sql#l1
        "_sanitize_email:mail",
        "homepage",
        "language",
        "created",
    ])

whitelist.add(
    table="_nodata:comment_alter_taxonomy",
    columns=[
        "nid",
        "cid",
        "tid",
    ])

whitelist.add(
    table="_nodata:comment_upload",
    columns=[
        "fid",
        "nid",
        "cid",
        "description",
        "list",
        "weight",
        "legacy_fid",
    ])

whitelist.add(
    table="contact",
    columns=[
        "category",
        "recipients",
        "reply",
        "cid",
        "weight",
        "selected",
    ])

whitelist.add(
    table="ctools_css_cache",
    columns=[
        "cid",
        "filename",
        "css",
        "filter",
    ])

whitelist.add(
    table="ctools_object_cache",
    columns=[
        "sid",
        "name",
        "obj",
        "updated",
        "data",
    ])

whitelist.add(
    table="date_format_locale",
    columns=[
        "format",
        "type",
        "language",
    ])

whitelist.add(
    table="date_format_type",
    columns=[
        "type",
        "title",
        "locked",
    ])

whitelist.add(
    table="date_formats",
    columns=[
        "dfid",
        "format",
        "type",
        "locked",
    ])

whitelist.add(
    table="field_config",
    columns=[
        "id",
        "field_name",
        "type",
        "module",
        "active",
        "storage_type",
        "storage_module",
        "storage_active",
        "locked",
        "data",
        "cardinality",
        "translatable",
        "deleted",
    ])

whitelist.add(
    table="field_config_instance",
    columns=[
        "id",
        "field_id",
        "field_name",
        "entity_type",
        "bundle",
        "data",
        "deleted",
    ])

whitelist.add(
    table="field_data_body",
    columns=[
        "entity_type",
        "bundle",
        "deleted",
        "entity_id",
        "revision_id",
        "language",
        "delta",
        "body_value",
        "body_summary",
        "body_format",
    ])

whitelist.add(
    table="field_data_comment_body",
    columns=[
        "entity_type",
        "bundle",
        "deleted",
        "entity_id",
        "revision_id",
        "language",
        "delta",
        "comment_body_value",
        "comment_body_format",
    ])

whitelist.add(
    table="field_group",
    columns=[
        "id",
        "identifier",
        "group_name",
        "entity_type",
        "bundle",
        "mode",
        "parent_name",
        "data",
    ])

whitelist.add(
    table="field_revision_body",
    columns=[
        "entity_type",
        "bundle",
        "deleted",
        "entity_id",
        "revision_id",
        "language",
        "delta",
        "body_value",
        "body_summary",
        "body_format",
    ])

whitelist.add(
    table="file_managed",
    columns=[
        "fid",
        "uid",
        "filename",
        "uri",
        "filemime",
        "filesize",
        "status",
        "timestamp",
    ])

whitelist.add(
    table="file_usage",
    columns=[
        "fid",
        "module",
        "type",
        "id",
        "count",
    ])

whitelist.add(
    table="filter",
    columns=[
        "format",
        "module",
        "name",
        "weight",
        "status",
        "settings",
    ])

whitelist.add(
    table="filter_format",
    columns=[
        "format",
        "name",
        "cache",
        "status",
        "weight",
    ])

whitelist.add(
    table="_nodata:flood",
    columns=[
        "event",
        "identifier",
        "timestamp",
        "fid",
        "expiration",
    ])

whitelist.add(
    table="_nodata:forum2_index",
    columns=[
        "nid",
        "title",
        "tid",
        "sticky",
        "created",
        "last_comment_timestamp",
        "comment_count",
    ])

whitelist.add(
    table="history",
    columns=[
        "uid",
        "nid",
        "timestamp",
    ])

whitelist.add(
    table="image_effects",
    columns=[
        "ieid",
        "isid",
        "weight",
        "name",
        "data",
    ])

whitelist.add(
    table="image_styles",
    columns=[
        "isid",
        "name",
        "label",
    ])

whitelist.add(
    table="menu_custom",
    columns=[
        "menu_name",
        "title",
        "description",
    ])

whitelist.add(
    table="menu_links",
    columns=[
        "menu_name",
        "mlid",
        "plid",
        "link_path",
        "router_path",
        "link_title",
        "options",
        "module",
        "hidden",
        "external",
        "has_children",
        "expanded",
        "weight",
        "depth",
        "customized",
        "p1",
        "p2",
        "p3",
        "p4",
        "p5",
        "p6",
        "p7",
        "p8",
        "p9",
        "updated",
    ])

whitelist.add(
    table="menu_router",
    columns=[
        "path",
        "load_functions",
        "to_arg_functions",
        "access_callback",
        "access_arguments",
        "page_callback",
        "page_arguments",
        "fit",
        "number_parts",
        "tab_parent",
        "tab_root",
        "title",
        "title_callback",
        "title_arguments",
        "type",
        "description",
        "position",
        "weight",
        "include_file",
        "delivery_callback",
        "context",
        "theme_callback",
        "theme_arguments",
    ])

whitelist.add(
    table="_nodata:mv_drupalorg_node_by_term",
    columns=[
        "entity_type",
        "entity_id",
        "term_tid",
        "node_sticky",
        "last_node_activity",
        "node_created",
        "node_title",
    ])

whitelist.add(
    table="_nodata:mv_drupalorg_node_by_vocabulary",
    columns=[
        "entity_type",
        "entity_id",
        "term_vid",
        "node_nid",
        "node_last_comment_timestamp",
        "node_title",
        "node_comment_count",
    ])

whitelist.add(
    table="node",
    columns=[
        "nid",
        "type",
        "title",
        "uid",
        "status",
        "created",
        "comment",
        "promote",
        "changed",
        "sticky",
        "vid",
        "language",
        "tnid",
        "translate",
    ])

whitelist.add(
    table="node_access",
    columns=[
        "nid",
        "gid",
        "realm",
        "grant_view",
        "grant_update",
        "grant_delete",
    ])

whitelist.add(
    table="node_comment_statistics",
    columns=[
        "nid",
        "last_comment_timestamp",
        "last_comment_name",
        "last_comment_uid",
        "comment_count",
        "cid",
    ])

whitelist.add(
    table="node_revision",
    columns=[
        "nid",
        "vid",
        "uid",
        "title",
        "timestamp",
        "log",
        "status",
        "comment",
        "promote",
        "sticky",
    ])

whitelist.add(
    table="node_type",
    columns=[
        "type",
        "name",
        "base",
        "description",
        "help",
        "has_title",
        "title_label",
        "custom",
        "modified",
        "locked",
        "orig_type",
        "module",
        "disabled",
    ])

whitelist.add(
    table="_nodata:project_issue_comments",
    columns=[
        "nid",
        "cid",
        "rid",
        "component",
        "category",
        "priority",
        "assigned",
        "sid",
        "pid",
        "title",
        "timestamp",
        "comment_number",
    ])

whitelist.add(
    table="_nodata:project_issue_projects",
    columns=[
        "nid",
        "issues",
        "components",
        "help",
        "mail_digest",
        "mail_copy",
        "mail_copy_filter",
        "mail_copy_filter_state",
        "mail_reminder",
        "default_component",
    ])

whitelist.add(
    table="_nodata:project_issues",
    columns=[
        "nid",
        "pid",
        "category",
        "component",
        "priority",
        "rid",
        "assigned",
        "sid",
        "original_issue_data",
        "last_comment_id",
        "db_lock",
        "priority_weight",
    ])

whitelist.add(
    table="_nodata:projects",
    columns=[
        "pid",
        "name",
        "versions",
        "developers",
        "areas",
        "mail",
        "version_default",
    ])

whitelist.add(
    table="queue",
    columns=[
        "item_id",
        "name",
        "data",
        "expire",
        "created",
    ])

whitelist.add(
    table="redirect",
    columns=[
        "rid",
        "hash",
        "type",
        "uid",
        "source",
        "source_options",
        "redirect",
        "redirect_options",
        "language",
        "status_code",
        "count",
        "access",
    ])

whitelist.add(
    table="registry",
    columns=[
        "name",
        "type",
        "filename",
        "module",
        "weight",
    ])

whitelist.add(
    table="registry_file",
    columns=[
        "filename",
        "hash",
    ])

whitelist.add(
    table="role",
    columns=[
        "rid",
        "name",
        "weight",
    ])

whitelist.add(
    table="role_permission",
    columns=[
        "rid",
        "permission",
        "module",
    ])

whitelist.add(
    table="_nodata:search_dataset",
    columns=[
        "sid",
        "type",
        "data",
        "reindex",
    ])

whitelist.add(
    table="_nodata:search_index",
    columns=[
        "word",
        "sid",
        "type",
        "score",
    ])

whitelist.add(
    table="_nodata:search_node_links",
    columns=[
        "sid",
        "type",
        "nid",
        "caption",
    ])

whitelist.add(
    table="_nodata:search_total",
    columns=[
        "word",
        "count",
    ])

whitelist.add(
    table="_nodata:semaphore",
    columns=[
        "name",
        "value",
        "expire",
    ])

whitelist.add(
    table="sequences",
    columns=[
        "value",
    ])

whitelist.add(
    table="_nodata:sessions",
    columns=[
        "uid",
        "sid",
        "hostname",
        "timestamp",
        "cache",
        "session",
        "ssid",
    ])

whitelist.add(
    table="system",
    columns=[
        "filename",
        "name",
        "type",
        "status",
        "bootstrap",
        "weight",
        "schema_version",
        "info",
        "owner",
    ])

whitelist.add(
    table="taxonomy_index",
    columns=[
        "nid",
        "tid",
        "sticky",
        "created",
    ])

whitelist.add(
    table="taxonomy_term_data",
    columns=[
        "tid",
        "vid",
        "name",
        "description",
        "weight",
        "format",
    ])

whitelist.add(
    table="taxonomy_term_hierarchy",
    columns=[
        "tid",
        "parent",
    ])

whitelist.add(
    table="taxonomy_vocabulary",
    columns=[
        "vid",
        "name",
        "description",
        "hierarchy",
        "weight",
        "module",
        "machine_name",
    ])

whitelist.add(
    table="_nodata:tracker2_node",
    columns=[
        "nid",
        "published",
        "changed",
    ])

whitelist.add(
    table="_nodata:tracker2_user",
    columns=[
        "nid",
        "published",
        "uid",
        "changed",
    ])

whitelist.add(
    table="tracker_node",
    columns=[
        "nid",
        "published",
        "changed",
    ])

whitelist.add(
    table="tracker_user",
    columns=[
        "nid",
        "uid",
        "published",
        "changed",
    ])

whitelist.add(
    table="url_alias",
    columns=[
        "pid",
        "source",
        "alias",
        "language",
    ])

whitelist.add(
    table="users",
    columns=[
        "uid",
        "name",
        "_sanitize_text:pass",
        # UPDATE users SET mail = concat(name, '@sanitized.invalid');
        # http://drupalcode.org/project/infrastructure.git/blob/HEAD:/snapshot/common.staging.sql#l1
        "_sanitize_email:mail",
        "theme",
        "signature",
        "status",
        "timezone",
        "language",
        # UPDATE users SET init = if(init LIKE 'drupal.org/user/%/edit', concat('staging.dev', init), mail);
        # http://drupalcode.org/project/infrastructure.git/blob/HEAD:/snapshot/common.staging.sql#l2
        "_sanitize_email:init",
        "_sanitize_blank:data",
        "created",
        "login",
        "signature_format",
        "access",
        "picture",
    ])

whitelist.add(
    table="users_roles",
    columns=[
        "uid",
        "rid",
    ])

# DELETE FROM variable WHERE name LIKE '%key%'; http://drupalcode.org/project/infrastructure.git/blob/HEAD:/snapshot/common.raw.sql#l3
whitelist.add(
    table="_trimkeys:variable",
    columns=[
        "name",
        "value",
    ])

whitelist.add(
    table="views_display",
    columns=[
        "vid",
        "id",
        "display_title",
        "display_plugin",
        "position",
        "display_options",
    ])

whitelist.add(
    table="views_view",
    columns=[
        "vid",
        "name",
        "description",
        "tag",
        "base_table",
        "core",
        "human_name",
    ])

whitelist.add(
    table="_nodata:watchdog",
    columns=[
        "wid",
        "uid",
        "type",
        "message",
        "location",
        "hostname",
        "timestamp",
        "link",
        "severity",
        "referer",
        "variables",
        "machinename",
    ])


if __name__ == "__main__":
    print(whitelist.tabledata)
