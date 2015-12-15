<?php
$aliases['dev'] = array(
  'remote-user' => 'bdduser',
  'remote-host' => 'devwww2.drupalsystems.org',
  'os' => 'Linux',
);
$aliases['integration'] = array(
  'remote-user' => 'bdduser',
  'remote-host' => 'integration1.drupalsystems.org',
  'os' => 'Linux',
);
$aliases['staging'] = array(
  'remote-user' => 'bdduser',
  'remote-host' => 'stagingwww1.drupalsystems.org',
  'os' => 'Linux',
);
$aliases['|NAME|-|SITE|'] = array(
  'parent' => '@|SERVER|',
  'uri' => '|URI|',
  'root' => '|ROOT|',
);
?>
