-- 12703 commits associated with an issue.
SELECT COUNT(*), SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(vo.message,'#',-1), ' ',1), ':',1) AS `issue_nid`, vo.*, n2.*
FROM versioncontrol_operations vo
  LEFT JOIN versioncontrol_operation_labels vol on vol.vc_op_id = vo.vc_op_id
  LEFT JOIN versioncontrol_labels vl on vl.label_id = vol.label_id
  LEFT JOIN versioncontrol_project_projects vpp on vpp.repo_id = vo.repo_id
  LEFT JOIN node n on n.nid = vpp.nid  and n.type = 'project_core'
  -- This joins on an extracted #123456 pattern in the commit message.
  LEFT JOIN node n2 on n2.type = 'project_issue' AND n2.nid = SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(vo.message,'#',-1), ' ',1), ':',1)
-- Repo ID 2 is drupal core
WHERE vo.repo_id = 2
      -- vcs branche is 8.0.x
      AND vl.name = '8.0.x'
      -- The author date was determined from the commit for git merge-base for 8.0.x - ie. the first commit in d8 that wasnt in d7.
      AND vo.committer_date > 1301233724
      -- contains a pound sign
      AND vo.message LIKE '%#%'
      AND n2.nid IS NOT NULL
ORDER BY vo.author_date DESC;
