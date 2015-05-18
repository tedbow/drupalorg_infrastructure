USE drupalorg_staging1;
SELECT
  SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(vo.message, '#', -1), ' ', 1), ':', 1) AS `Issue nid`,
  FROM_UNIXTIME(vo.committer_date)                                                       AS `commit date`,
-- Issue age is how long it took for an issue to get resolved.
  (vo.committer_date - issue_node.created)                                               AS `Issue age`,
  FLOOR((vo.committer_date - issue_node.created) / (60 * 60 * 24 * 365))                 AS `Years`,
  FLOOR((vo.committer_date - issue_node.created) / (60 * 60 * 24 * 7)) MOD 52            AS `Weeks`,
  FLOOR((vo.committer_date - issue_node.created) / (60 * 60 * 24)) MOD 7                 AS `Days`,
  vo.revision,
  vo.message,
  issue_node.nid,
  issue_node.title,
  issue_node.uid,
  fdfic.field_issue_component_value,
  fdfip.field_issue_priority_value,
  fm.*,
  fm.uid,
  fm.filename
FROM versioncontrol_operations vo
  LEFT JOIN versioncontrol_operation_labels vol ON vol.vc_op_id = vo.vc_op_id
  LEFT JOIN versioncontrol_labels vl ON vl.label_id = vol.label_id
  LEFT JOIN versioncontrol_project_projects vpp ON vpp.repo_id = vo.repo_id
  LEFT JOIN node n ON n.nid = vpp.nid AND n.type = 'project_core'
-- This joins on an extracted #123456 pattern in the commit message.
  LEFT JOIN node issue_node ON issue_node.type = 'project_issue' AND issue_node.nid = SUBSTRING_INDEX(
      SUBSTRING_INDEX(SUBSTRING_INDEX(vo.message, '#', -1), ' ', 1), ':', 1)
  LEFT JOIN field_data_field_issue_component fdfic ON fdfic.entity_id = issue_node.nid
  LEFT JOIN field_data_field_issue_priority fdfip ON fdfip.entity_id = issue_node.nid
  LEFT JOIN field_data_field_issue_files fdfif ON fdfif.entity_id = issue_node.nid
  LEFT JOIN file_managed fm ON fm.fid = fdfif.field_issue_files_fid

-- Repo ID 2 is drupal core
WHERE vo.repo_id = 2
      -- vcs branch is 8.0.x
      AND vl.name = '8.0.x'
      -- The author date was determined from the commit for git merge-base for 8.0.x - ie. the first commit in d8 that wasnt in d7.
      AND vo.committer_date > 1301233724
      -- contains a pound sign
      AND vo.message LIKE '%#%'
      AND issue_node.nid IS NOT NULL
      AND (fm.filename LIKE '%patch%'
           OR fm.filename LIKE '%diff%')
      AND fm.filename NOT LIKE '%png'
      AND fm.filename NOT LIKE '%interdiff%'
      AND fm.filename NOT LIKE '%jpg'
ORDER BY vo.author_date DESC;
