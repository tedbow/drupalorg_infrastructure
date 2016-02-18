<?php
// A php scritp to decode the json encoded data from
// .../api/json?tree=allBuilds[id,timestamp]

$f = fgets(STDIN);
$decoded_json = json_decode($f, TRUE);

foreach($decoded_json["allBuilds"] as $zKEY=>$zVALUE){
  print $zVALUE["id"] . " " . $zVALUE["timestamp"] . "\n";
}

?>
