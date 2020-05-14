<?php

namespace InfoUpdater;

use Composer\Semver\Semver;
use Symfony\Component\Yaml\Yaml;

class InfoUpdater {
  public static function updateInfo($file) {
    $info = Yaml::parseFile($file);
    $update_info = FALSE;
    if (!isset($info['core_version_requirement'])) {
      $info['core_version_requirement'] = '^8 || ^9';
      $update_info = TRUE;
    }
    else {
      if (!Semver::satisfies('9.0.0', $info['core_version_requirement'])) {
        $info['core_version_requirement'] .= ' || ^9';
        $update_info = TRUE;
      }
    }
    if ($update_info) {
      $yml = Yaml::dump($info);
      return file_put_contents($file, $yml) !== FALSE;
    }
    return FALSE;

  }
}
