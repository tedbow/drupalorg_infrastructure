<?php

$environments = array('solr_5', 'solr_5_0');
$searches = array(
  // 'search keys' => array(
  //   'result id' => 'flair',
  // ),
  // Flairs:
  // '✓' Great result
  // '~' Okay result
  // '!' Bad result
  'coding standards' => array(
    'e7ikco/node/318' => '✓', // Documentation
    'e7ikco/node/2465321' => '~', // Project
  ),
  'installation guide' => array(
    'e7ikco/node/251019' => '✓', // Documentation
  ),
  'glossary' => array(
    'e7ikco/node/937' => '✓', // Documentation
  ),
  'rules' => array(
    'e7ikco/node/190124' => '✓', // Module
    'e7ikco/node/298476' => '✓', // Documentation
  ),
  'draggableviews' => array(
    'e7ikco/node/283087' => '✓', // Module
    'e7ikco/node/283498' => '✓', // Documentation
  ),
  'zen' => array(
    'e7ikco/node/88566' => '✓', // Theme
    'e7ikco/node/193318' => '✓', // Documentation
    'e7ikco/node/1072403' => '!', // Unsupported
    'e7ikco/node/485812' => '!', // Unsupported
  ),
  'views' => array(
    'e7ikco/node/1912118' => '✓', // Documentation
    'e7ikco/node/38878' => '✓', // Module
    'e7ikco/node/785504' => '!', // Placeholder
  ),
  'apachesolr' => array(
    'e7ikco/node/204268' => '✓', // Module
  ),
  'apache solr' => array(
    'e7ikco/node/204268' => '✓', // Module
  ),
  'media' => array(
    'e7ikco/node/19304' => '✓', // Module
    'e7ikco/node/2358115' => '✓', // Resource guide
  ),
  'redirect' => array(
    'e7ikco/node/3287' => '✓', // Module
    'e7ikco/node/80382' => '✓', // Module
  ),
  'xml sitemap' => array(
    'e7ikco/node/190839' => '✓', // Module
  ),
  'ctools' => array(
    'e7ikco/node/343333' => '✓', // Module
    'e7ikco/node/2179357' => '!', // Sandbox
  ),
  'core' => array(
    'e7ikco/node/3060' => '✓', // Drupal core
  ),
  'drupal core' => array(
    'e7ikco/node/3060' => '✓', // Drupal core
  ),
  'drupal' => array(
    'e7ikco/node/3060' => '✓', // Drupal core
  ),
  'tag1' => array(
    'e7ikco/node/1762646' => '✓', // Organization
  ),
  'mediacurrent' => array(
    'e7ikco/node/1125004' => '✓', // Organization
  ),
  'acquia' => array(
    'e7ikco/node/1204416' => '✓', // Organization
  ),
  'drupal geeks' => array(
    'e7ikco/node/2013897' => '✓', // Organization
  ),
);

$stdout = fopen('php://stdout', 'w');
foreach ($searches as $keys => $notes) {
  drupal_static_reset();
  $output = array();
  $search_page = apachesolr_search_page_load('core_search');
  $search_page['settings']['apachesolr_search_per_page'] = 100;
  $conditions = apachesolr_search_conditions_default($search_page);

  foreach (apachesolr_search_search_results($keys, $conditions, $search_page) as $n => $result) {
    $output[$result['fields']['id']] = array(
      '' => isset($notes[$result['fields']['id']]) ? $notes[$result['fields']['id']] : '',
      'title' => $result['title'],
      'bundle' => $result['bundle'],
      'link' => $result['link'],
      'score' => $result['score'],
      'score_old' => NULL,
      'score_delta' => NULL,
      'rank' => $n + 1,
      'rank_old' => NULL,
      'rank_delta' => NULL,
    );
  }

  // Swap environment.
  $search_page['env_id'] = ($search_page['env_id'] === $environments[0]) ? $environments[1] : $environments[0];

  foreach (apachesolr_search_search_results($keys, $conditions, $search_page) as $n => $result) {
    if (isset($output[$result['fields']['id']])) {
      $output[$result['fields']['id']]['score_old'] = $result['score'];
      $output[$result['fields']['id']]['score_delta'] = number_format($output[$result['fields']['id']]['score'] - $result['score'], 7);
      $output[$result['fields']['id']]['rank_old'] = $n + 1;
      $output[$result['fields']['id']]['rank_delta'] = $output[$result['fields']['id']]['rank'] - ($n + 1);
    }
  }

  if (!isset($header_shown)) {
    $row = reset($output);
    fputcsv($stdout, array_keys($row));
    $header_shown = TRUE;
  }

  fputcsv($stdout, array(
    '→',
    $keys,
    NULL,
    url('search/site/' . $keys, array('absolute' => TRUE)),
  ));
  foreach ($output as $row) {
    fputcsv($stdout, $row);
  }
  print "\n";
}
