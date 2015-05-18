SELECT
  u.name,
  u.uid,
  CONCAT('https://drupal.org/user/', u.uid)                                            AS `Patch Submitter`,
  AVG(COALESCE(GREATEST(((SELECT c2.created
                          FROM comment c2
                          WHERE c2.thread > c.thread AND c2.nid = c.nid AND c2.uid != c.uid AND c2.uid != 180064
                          ORDER BY c2.thread ASC
                          LIMIT 1) - c.created), 0), unix_timestamp() - fm.timestamp)) AS `Patch Response Time`,
  COUNT(fm.fid)                                                                        AS `Number of Patches Submitted`
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
GROUP BY u.uid;
