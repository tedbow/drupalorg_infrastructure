<?php

$searches = array(
  // 'search keys' => array(
  //   'result id' => 'flair',
  // ),
  // Flairs:
  // '✓' Great result
  // '~' Okay result
  // '!' Bad result
  'coding standards' => array(
    'sh0zn1/node/318' => '✓', // Documentation
    'sh0zn1/node/2465321' => '~', // Project
  ),
  'installation guide' => array(
    'sh0zn1/node/251019' => '✓', // Documentation
  ),
  'glossary' => array(
    'sh0zn1/node/937' => '✓', // Documentation
  ),
  'rules' => array(
    'sh0zn1/node/190124' => '✓', // Module
    'sh0zn1/node/298476' => '✓', // Documentation
  ),
  'draggableviews' => array(
    'sh0zn1/node/283087' => '✓', // Module
    'sh0zn1/node/283498' => '✓', // Documentation
  ),
  'zen' => array(
    'sh0zn1/node/88566' => '✓', // Theme
    'sh0zn1/node/193318' => '✓', // Documentation
    'sh0zn1/node/1072403' => '!', // Unsupported
    'sh0zn1/node/485812' => '!', // Unsupported
  ),
  'views' => array(
    'sh0zn1/node/1912118' => '✓', // Documentation
    'sh0zn1/node/38878' => '✓', // Module
    'sh0zn1/node/785504' => '!', // Placeholder
  ),
  'apachesolr' => array(
    'sh0zn1/node/204268' => '✓', // Module
  ),
  'apache solr' => array(
    'sh0zn1/node/204268' => '✓', // Module
  ),
  'media' => array(
    'sh0zn1/node/19304' => '✓', // Module
    'sh0zn1/node/2358115' => '✓', // Resource guide
  ),
  'redirect' => array(
    'sh0zn1/node/3287' => '✓', // Module
    'sh0zn1/node/80382' => '✓', // Module
  ),
  'xml sitemap' => array(
    'sh0zn1/node/190839' => '✓', // Module
  ),
  'ctools' => array(
    'sh0zn1/node/343333' => '✓', // Module
    'sh0zn1/node/2179357' => '!', // Sandbox
  ),
  'core' => array(
    'sh0zn1/node/3060' => '✓', // Drupal core
  ),
  'drupal core' => array(
    'sh0zn1/node/3060' => '✓', // Drupal core
  ),
  'drupal' => array(
    'sh0zn1/node/3060' => '✓', // Drupal core
  ),
  'tag1' => array(
    'sh0zn1/node/1762646' => '✓', // Organization
  ),
  'mediacurrent' => array(
    'sh0zn1/node/1125004' => '✓', // Organization
  ),
  'acquia' => array(
    'sh0zn1/node/1204416' => '✓', // Organization
  ),
  'drupal geeks' => array(
    'sh0zn1/node/2013897' => '✓', // Organization
  ),
);

$environments = drush_get_arguments();
array_shift($environments);
array_shift($environments);
$stdout = fopen('php://stdout', 'w');
foreach ($searches as $keys => $notes) {
  drupal_static_reset();
  $output = array();
  $search_page = apachesolr_search_page_load('core_search');
  $search_page['settings']['apachesolr_search_per_page'] = 100;
  $conditions = apachesolr_search_conditions_default($search_page);

  $search_page['env_id'] = array_shift($environments);
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
  $search_page['env_id'] = array_shift($environments);
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
