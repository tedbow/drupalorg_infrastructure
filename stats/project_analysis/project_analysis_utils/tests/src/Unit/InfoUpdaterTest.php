<?php

namespace InfoUpdater\Tests\Unit;

use InfoUpdater\InfoUpdater;
use InfoUpdater\Tests\Core\InfoParserDynamic;
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
  public function testUpdateInfoNew($file, $project_version, $expected, $expected_remove_core) {
    $temp_file = $this->createTempFixtureFile($file);
    $pre_yml = Yaml::parseFile($temp_file);
    if ($file === 'no_core_version_requirement.info.yml') {
      $this->assertFalse(isset($pre_yml['core_version_requirement']));
    }
    InfoUpdater::updateInfo($temp_file, $project_version);
    $post_yml = Yaml::parseFile($temp_file);
    $this->assertSame($expected, $post_yml['core_version_requirement']);

    // The created info file should be able to be parsed by the core parser.
    $core_parser = new InfoParserDynamic();
    $core_info = $core_parser->parse($temp_file);
    $this->assertSame($post_yml, $core_info);


    if ($expected_remove_core) {
      unset($pre_yml['core']);
    }
    $pre_yml['core_version_requirement'] = $expected;
    $pre_yml = asort($pre_yml);
    $post_yml = asort($post_yml);
    $this->assertSame($post_yml, $post_yml);

    unlink($temp_file);
  }

  public function providerUpdateInfoNew() {
    return [
      '^8' => [
        'no_core_version_requirement.info.yml',
        'environment_indicator.3.x-dev',
        '^8 || ^9',
        FALSE,
      ],
      '^8 existing' => [
        'core_version_requirement.info.yml',
        'environment_indicator.3.x-dev',
        '^8 || ^9',
        FALSE,
      ],
      '^8 existing 8.7' => [
        'set_879.info.yml',
        'environment_indicator.3.x-dev',
        '^8.7.9 || ^9',
        FALSE,
      ],
      '^8 existing 8.8.3' => [
        'set_883.info.yml',
        'environment_indicator.3.x-dev',
        '^8.8.3 || ^9',
        FALSE,
      ],
      // @todo Add duplicates of all cases for existing
      // Remove 8.8 but not 8.7
      '^8.8' => [
        'no_core_version_requirement.info.yml',
        'twitter_embed_field.1.x-dev',
        '^8.8 || ^9',
        TRUE,
      ],
      '^8.8 existing ^8' => [
        'core_version_requirement.info.yml',
        'twitter_embed_field.1.x-dev',
        '^8.8 || ^9',
        TRUE,
      ],
      '^8.8 existing 8.7' => [
        'set_879.info.yml',
        'twitter_embed_field.1.x-dev',
        '^8.8 || ^9',
        FALSE,
      ],
      '^8.8 existing 8.8.3' => [
        'set_883.info.yml',
        'twitter_embed_field.1.x-dev',
        '^8.8.3 || ^9',
        FALSE,
      ],
      // Remove 8.8 but not 8.7
      '8.8 and 8.7' => [
        'no_core_version_requirement.info.yml',
        'widget_engine.1.x-dev',
        '^8.8 || ^9',
        TRUE,
      ],
      '8.7.7' => [
        'no_core_version_requirement.info.yml',
        'texbar.1.x-dev',
        '^8.7.7 || ^9',
        TRUE,
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
