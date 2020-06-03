<?php

namespace InfoUpdater;

/**
 * Class GitHelper
 *
 * @package InfoUpdater
 */
class GitHelper {

  public function shellExecSplit($string) {
    $output = shell_exec($string);
    $output = preg_split('/\n+/', trim($output));
    $output = array_map(function ($line) {
      return trim($line);
    }, $output);

    return array_filter($output);

  }

  /**
   * Restores any file that only has change not made by rector.
   *
   * Currently this method just looks for files where all the changes lines only
   * contain spaces, { or }. Rector has a bug where it changes some lines
   * that aren't related to any rules.
   * https://github.com/rectorphp/rector/issues/3375
   *
   * @param string $dir
   *   The working directory to use.
   *
   * @throws \Exception
   */
  public function restoreNonRectorChanges($dir) {
    if (!chdir($dir)) {
      return;
    }
    $files = $this->shellExecSplit('git diff --name-only');
    // Match any line that starts with + or - and has no other characters
    // except space, * , / or {
    $pattern = '/^[\+\-].*[^\/* {}].*/';
    $use_replacements = [];
    foreach ($files as $file) {
      $diff = $this->shellExecSplit("git diff $file");
      $diff = array_splice($diff, 5);

      $rector_change = FALSE;
      $skip_lines = [];
      foreach ($diff as $index => $diff_line) {
        if (in_array($index, $skip_lines)) {
          continue;
        }
        if (strpos($diff_line, "+use ") === 0) {
          $imported_class = str_replace(['+use ', ';'], ['', ''], $diff_line);
          $parts = explode('\\', $imported_class);
          $use_replacements[] = [
            'full' => "\\$imported_class",
            'short' => array_pop($parts),
          ];
          continue;
        }
        if (preg_match($pattern, $diff_line)) {
          if (strpos($diff_line, '-') === 0 && isset($diff[$index + 1]) && strpos($diff[$index + 1] , '+') === 0) {
            $remove_line = str_replace('- ', '', $diff_line);
            $add_line = str_replace('+ ', '', $diff[$index + 1]);
            foreach ($use_replacements as $use_replacement) {
              if (str_replace($use_replacement['full'], $use_replacement['short'], $remove_line) === $add_line) {
                // The add an remove lines are exactly the same except or the FQCN.
                $skip_lines[] = $index + 1;
                continue 2;
              }
            }
          }
          $rector_change = TRUE;
          break;
        }
      }
      if (!$rector_change) {
        system("git checkout -- $file", $ret);
        if ($ret !== 0) {
          throw new \Exception("Cannot checkout: $file");
        }
      }
    }
  }
}
