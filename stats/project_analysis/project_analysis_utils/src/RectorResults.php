<?php

namespace InfoUpdater;

/**
 * Utility Class to check XML files produced by rector.
 */
class RectorResults {

  /**
   * @param $project_version
   *
   * @return bool
   */
  public static function errorInTest($project_version) {
    if (!file_exists("/var/lib/drupalci/workspace/phpstan-results/$project_version.rector_stderr")) {
      return FALSE;
    }
    $lines = file("/var/lib/drupalci/workspace/phpstan-results/$project_version.rector_out");
    $line = $lines[count($lines)-1];
    return stripos($line, '/tests/') !== FALSE;
  }
}
