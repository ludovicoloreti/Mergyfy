<?php
$a = $_SERVER[REQUEST_URI];
$as = explode("&",$a);
$ass = explode("?", $as[0]);
unset($as[0]);
array_push($as, $ass[1]);
$asd = array();
foreach($as as $key => $value) {
  $temp = explode("=",$value);
  // $asdd->$temp[0] = $temp[1];
  // var_dump($asdd); echo "<br>";
  array_push($asd, $temp);
}
echo json_encode($asd);
?>
