<?php

namespace InfoUpdater;

use Symfony\Component\Yaml\Yaml;

class InfoUpdater {
  public static function updateInfo($file) {
    $info = Yaml::parseFile($file);
    if (!isset($info['core_version_requirement'])) {
      $info['core_version_requirement'] = '^8 || ^9';
      $yml = Yaml::dump($info);
      file_put_contents($file, $yml);
      return TRUE;
    }
    return FALSE;

  }
}
