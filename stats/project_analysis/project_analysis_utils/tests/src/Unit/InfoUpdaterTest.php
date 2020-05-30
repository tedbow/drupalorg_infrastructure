<?php

namespace InfoUpdater\Tests\Unit;

use InfoUpdater\InfoUpdater;
use InfoUpdater\Tests\TestBase;
use PHPUnit\Framework\TestCase;
use Symfony\Component\Yaml\Yaml;

/**
 * @coversDefaultClass \InfoUpdater\InfoUpdater
 */
class InfoUpdaterTest extends TestBase {


  /**
   * @covers ::updateInfo
   *
   * @dataProvider providerUpdateInfoNew
   */
  public function testUpdateInfoNew($file, $project_version, $expected) {
    $temp_file = $this->createTempFixtureFile($file);
    $pre_yml = Yaml::parseFile($temp_file);
    if ($file === 'no_core_version_requirement.info.yml') {
      $this->assertFalse(isset($pre_yml['core_version_requirement']));
    }
    InfoUpdater::updateInfo($temp_file, $project_version);
    $post_yml = Yaml::parseFile($temp_file);
    $this->assertSame($expected, $post_yml['core_version_requirement']);
    // The yml should be the same except for 'core_version_requirement'.
    unset($post_yml['core_version_requirement']);
    if ($file === 'no_core_version_requirement.info.yml') {
      $this->assertSame($pre_yml, $post_yml);
    }
    unlink($temp_file);
  }

  public function providerUpdateInfoNew() {
    return [
      '^8' => [
        'no_core_version_requirement.info.yml',
        'environment_indicator.3.x-dev',
        '^8 || ^9',
      ],
      '^8 existing 8.7' => [
        'set_87.info.yml',
        'environment_indicator.3.x-dev',
        '^8.7 || ^9',
      ],
      // @todo Add duplicates of all cases for existing
      // Remove 8.8 but not 8.7
      '^8.8' => [
        'no_core_version_requirement.info.yml',
        'twitter_embed_field.1.x-dev',
        '^8.8 || ^9',
      ],
      // Remove 8.8 but not 8.7
      '8.8 and 8.7' => [
        'no_core_version_requirement.info.yml',
        'widget_engine.1.x-dev',
        '^8.8 || ^9',
      ],
      '8.7.7' => [
        'no_core_version_requirement.info.yml',
        'texbar.1.x-dev',
        '^8.7.7 || ^9',
      ],
    ];
  }

  /**
   * @param $file
   *
   * @return string
   */
  protected function createTempFixtureFile($file): string {
    $fixture_file = static::FIXTURE_DIR . "/$file";
    $temp_file = sys_get_temp_dir() . "/$file";
    if (file_exists($temp_file)) {
      unlink($temp_file);
    }
    copy($fixture_file, $temp_file);
    return $temp_file;
  }



}
class TestInfoUpdater extends InfoUpdater {
  //protected static RESULT_DIR
}
