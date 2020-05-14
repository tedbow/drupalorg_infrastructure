<?php

namespace InfoUpdater;

use Symfony\Component\Yaml\Yaml;

class UpdateStatusXmlChecker {

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
    $this->files = (new \SimpleXMLElement(file_get_contents($file)))->file;
  }

  public function runRector() {
    $rector_covered_messages = $this->getRectorCoveredMessages();
    foreach ($this->files as $file) {
      return (string) $file->name;
      foreach ($file->error as $error) {
        //throw new \Exception("Dfasd");
        $message = $file->attributes()['message'];
        return $message;
        print_r($message);
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
    //$deprecations_file = '/var/lib/drupalci/drupal-checkout/vendor/palantirnet/drupal-rector/deprecation-index.yml';
    $deprecations_file = '/var/lib/drupalci/workspace/infrastructure/stats/project_analysis/deprecation-index.yml';
    $deps = Yaml::parseFile($deprecations_file);
    foreach ($deps as $dep) {
      if (!empty($dep['PHPStan'])) {
        $phpstan_messages[] = $dep['PHPStan'];
      }
    }
    return $phpstan_messages;
  }
}
