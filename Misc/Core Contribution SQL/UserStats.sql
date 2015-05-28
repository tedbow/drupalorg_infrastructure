-- Shows Comments on d8 core + patches on d8 core per user
SELECT u.name AS `username`,
  comment_data.commenteruid,
       CONCAT('https://drupal.org/user/', comment_data.commenteruid) AS `Core Issue Contributor`,
  comment_data.`Comment Count`,
  patch_data.`Number of Patches Submitted`
FROM
  (SELECT COUNT(*) as `Comment Count`, cdata.commenteruid
   FROM (
          SELECT
            MIN(nr.vid),
            c.uid AS `commenteruid`
          FROM node_revision nr
            LEFT JOIN node n ON n.nid = nr.nid
            LEFT JOIN field_revision_field_project frfp ON frfp.revision_id = nr.vid
            LEFT JOIN field_revision_field_issue_version frfiv ON frfiv.revision_id = nr.vid
            LEFT JOIN comment c ON c.nid = n.nid AND c.created >= nr.timestamp
          WHERE n.type = 'project_issue'
                AND frfp.field_project_target_id = 3060
                AND frfiv.field_issue_version_value LIKE '8.%'
                AND c.uid IS NOT NULL
          GROUP BY c.cid, c.uid
          ORDER BY n.nid ASC
        ) as cdata
   GROUP BY cdata.commenteruid) as comment_data
  LEFT JOIN (
              SELECT
                COUNT(fm.fid)                                                                        AS `Number of Patches Submitted`,
                u.uid
              FROM field_data_field_issue_changes fdfic
                LEFT JOIN field_revision_field_issue_version frfiv ON frfiv.revision_id = fdfic.field_issue_changes_vid
                LEFT JOIN field_revision_field_project frfp ON frfp.revision_id = fdfic.field_issue_changes_vid
                LEFT JOIN file_managed fm ON fm.fid =
                                             SUBSTRING_INDEX(
                                                 SUBSTRING_INDEX(
                                                     SUBSTRING_INDEX(fdfic.field_issue_changes_new_value, 'fid"',
                                                                     -1),
                                                     '";s:', 1),
                                                 '"', -1)
                LEFT JOIN comment c ON c.cid = fdfic.entity_id
                LEFT JOIN users u ON u.uid = fm.uid
              WHERE frfp.field_project_target_id = 3060
                    AND fdfic.field_issue_changes_field_name = 'field_issue_files'
                    AND frfiv.field_issue_version_value LIKE '8.%'
                    AND (fm.filename LIKE '%patch%'
                         OR fm.filename LIKE '%diff%')
                    AND fm.filename NOT LIKE '%png'
                    AND fm.filename NOT LIKE '%interdiff%'
                    AND fm.filename NOT LIKE '%zip%'
                    AND fm.filename NOT LIKE '%jpg'
                    AND fm.timestamp != 0
                    AND SUBSTRING(fdfic.field_issue_changes_old_value, 1,5) != SUBSTRING(fdfic.field_issue_changes_new_value,1,5)
              GROUP BY u.uid) patch_data ON patch_data.uid = comment_data.commenteruid
  LEFT JOIN users u on u.uid = comment_data.commenteruid;
