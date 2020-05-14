<?php

namespace InfoUpdater;

use Symfony\Component\Yaml\Yaml;

class UpdateStatusXmlChecker {

  protected const DEPRECATIONS_FILE = '/var/lib/drupalci/workspace/infrastructure/stats/project_analysis/deprecation-index.yml';

  /**
   * @var string
   */
  protected $file;

  /**
   * @var \SimpleXMLElement
   */
  protected $xml;

  /**
   * @var \SimpleXMLElement
   */
  protected $files;


  /**
   * UpdateStatusXmlChecker constructor.
   */
  public function __construct($file) {
    $this->file = $file;
  }

  public function runRector() {
    try {
      $contents = file_get_contents($this->file);
      if (strpos($contents, '<checkstyle>') === FALSE) {
        return  FALSE;
      }
      $this->files = (new \SimpleXMLElement(file_get_contents($this->file)))->file;
    }
    catch (\Exception $exception) {
      return FALSE;
    }
    $rector_covered_messages = $this->getRectorCoveredMessages();
    foreach ($this->files as $file) {
      foreach ($file->error as $error) {
        $message = (string) $error->attributes()['message'];
        if (in_array($message, $rector_covered_messages)) {
          return TRUE;
        }
      }
    }
    return FALSE;
  }

  private function isPhpfile(\SimpleXMLElement $file) {
    $parts = explode('.', (string) $file->attributes()->name);
    //print_r($parts);
    $ext = array_pop($parts);
    return !in_array($ext, ['yml', 'twig']);
  }

  private function getRectorCoveredMessages() {
    static $phpstan_messages = [];
    if (empty($phpstan_messages)) {
      $deprecations_file = static::DEPRECATIONS_FILE;
      $deps = Yaml::parseFile($deprecations_file);
      foreach ($deps as $dep) {
        if (!empty($dep['PHPStan'])) {
          $phpstan_messages[] = $dep['PHPStan'];
        }
      }
    }
    return $phpstan_messages;
  }
}
