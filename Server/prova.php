<?php
$a = $_SERVER[REQUEST_URI];
$as = explode("&",$a);
$asd = array();
foreach($as as $key => $value) {
  $temp = explode("=",$value);
  array_push($asd, $temp[1]);
}
foreach($asd as $k => $v) {
  echo $v; // NOME DELLE action
}
?>
