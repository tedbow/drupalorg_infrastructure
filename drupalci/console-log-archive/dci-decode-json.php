<?php
// A php scritp to decode the json encoded data from
// .../api/json?tree=builds[id,timestamp]

// Set how long ago to look
$x = 90;
$f = fgets(STDIN);
$decoded_json = json_decode($f, TRUE);

//x_days_ago in milliseconds
$x_days_ago = ( time() - ( $x * 24 * 60 * 60) ) * 1000;

foreach($decoded_json["builds"] as $zKEY=>$zVALUE){
  if ($zVALUE["timestamp"] < $x_days_ago){
    print $zVALUE["id"] . "\n";
  }
}

?>
