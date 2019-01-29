<?php

$checksum = hex2bin('0000000000000000000000000000000000000000');
foreach (file('php://stdin', FILE_IGNORE_NEW_LINES) as $line) {
  if (preg_match("#\srefs/original#", $line)) {
    continue;
  }
  $checksum ^= sha1($line, TRUE);
}
print $argv[1] . "\t" . bin2hex($checksum) . "\n";
