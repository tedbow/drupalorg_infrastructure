<?php

namespace InfoUpdater;

use Composer\Semver\Semver;
use Symfony\Component\Yaml\Exception\ParseException;
use Symfony\Component\Yaml\Yaml;

class InfoUpdater extends ResultProcessorBase {

  private const KEY = 'core_version_requirement';
  public static function updateInfo($file, string $project_version) {
    $minimum_core_minor = NULL;
    if (file_exists(self::getUpgradeStatusXML($project_version, 'post'))) {
      $minimum_core_minor = static::getMinimumCore8Minoe($project_version);
    }

    $contents = file_get_contents($file);
    $info = Yaml::parse($contents);
    $has_core_version_requirement = FALSE;
    $update_info = FALSE;
    if (!isset($info[static::KEY])) {
      if ($minimum_core_minor === 8) {
        $value = '^8.8 || ^9';
      }
      elseif ($minimum_core_minor === 7) {
        $value = '^8.7.7 || ^9';
      }
      else {
        $value = '^8 || ^9';
      }
      $update_info = TRUE;
    }
    else {
      if ($minimum_core_minor === 8) {
        if (strpos($info[static::KEY], '8.8') === FALSE) {
          // If 8.8 is not in core_version_requirement it is likely specifying
          // lower compatibility
          $info[static::KEY] = '^8.8 || ^9';
        }
      }
      elseif ($minimum_core_minor === 7) {
        if (strpos($info[static::KEY], '8.8') === FALSE && strpos($info[static::KEY], '8.7') === FALSE) {
          // If no version 8.8 or 8.7 then we need to set a version
          $info[static::KEY] = '^8.7.7 || ^9';
        }
      }
      else {
        // It is not possible to specify minor compatibility below 8.7.7
        $info[static::KEY] = '^8 || ^9';
      }
    }
    if ($update_info) {
      // First try to update by string to avoid unrelated changes
      $new_lines = [];
      $added_line = FALSE;
      foreach(preg_split("/((\r?\n)|(\r\n?))/", $contents) as $line){
        $key = explode(':', $line)[0];
        $trimmed_key = trim($key);
        if ($trimmed_key !== static::KEY) {
          $new_lines[] = $line;
        }
        elseif ($has_core_version_requirement) {
          // Update the existing line.
          $new_lines[] = static::KEY . ': ' . $info[static::KEY];
        }
        if ($trimmed_key === 'core' && !$has_core_version_requirement) {
          $added_line = TRUE;
          $new_lines[] = static::KEY . ': ' . $info[static::KEY];
        }
      }
      if (!$added_line && !$has_core_version_requirement) {
        $new_lines[] = static::KEY . ': ' . $info[static::KEY];
      }
      $new_file_contents = implode("\n", $new_lines);
      try {
        Yaml::parse($new_file_contents);
        return file_put_contents($file, $new_file_contents) !== FALSE;
      }
      catch (ParseException $exception) {
        // IF the new file contents didn't parse then dump the info.
        // This is will mean more lines will change.
        $yml = Yaml::dump($info);
        return file_put_contents($file, $yml) !== FALSE;
      }
    }
    return FALSE;

  }

  private static function getMinimumCore8Minoe(string $project_version) {
    $pre_messages = self::getMessages($project_version, 'pre');
    $post_messages = self::getMessages($project_version, 'post');
    $minors = range(8, 0);
    foreach ($minors as $minor) {
      $deprecation_version = "drupal:8.$minor.0";
      if (strpos($pre_messages, $deprecation_version) !== FALSE && strpos($post_messages, $deprecation_version) === FALSE) {
        return $minor;
      }
    }
    return $minor;
  }

  /**
   * @param string $project_version
   *
   * @return string[]
   *
   * @throws \Exception
   */
  private static function getMessages(string $project_version, $pre_or_post): string {
    $pre = new UpdateStatusXmlChecker(self::getUpgradeStatusXML($project_version, $pre_or_post));
    return implode(' -- ', $pre->getMessages('error'))
      . ' -- '
      . implode(' -- ', $pre->getMessages('warning'));
  }

  /**
   * @param string $project_version
   * @param $pre_or_post
   *
   * @return string
   * @throws \Exception
   */
  private static function getUpgradeStatusXML(string $project_version, $pre_or_post): string {
    return static::getResultsDir() . "/$project_version.upgrade_status.{$pre_or_post}_rector.xml";
}
}
