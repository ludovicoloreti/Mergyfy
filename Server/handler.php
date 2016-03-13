<?php
if (isset($_SERVER['HTTP_ORIGIN'])) {
  header("Access-Control-Allow-Origin: {$_SERVER['HTTP_ORIGIN']}");
  header('Access-Control-Allow-Credentials: true');
  header('Access-Control-Max-Age: 86400');    // cache for 1 day
}

// Access-Control headers are received during OPTIONS requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {

  if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_METHOD']))
  header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

  if (isset($_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']))
  header("Access-Control-Allow-Headers:
  {$_SERVER['HTTP_ACCESS_CONTROL_REQUEST_HEADERS']}");

  exit(0);
}

include_once "database.php";
include_once "server.php";
include_once "Functions/jsonUtilities.php";
foreach (glob("Objects/*.php") as $filename)
{
  include_once $filename;
}

if(isset($test) && $test){
  //prepare the parameters in advance
  // echo "---- DEV MODE ----<br><br><br><br>";
  $action = $action;
  $model = $model;
  $data = $data;
} else{

  switch ($_SERVER['REQUEST_METHOD']){
    case 'POST':
      $data = file_get_contents("php://input");
      break;
    case 'GET':
      $request = $_SERVER[REQUEST_URI];
      $action = explode("&",$a);
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


  }
/*
  $data = file_get_contents("php://input");
  $action = $_REQUEST['action'];
  $model = $_REQUEST['model'];*/
}


if ((isset($data)) || (!empty($data)) || (!is_null($data))) {
  // POST
  // var_dump($data);
  $post = new Server();
  $post->execute($model, $action, $data);

} else {
  // GET
  $mdl = new $model();
  $mdl->$action();
}
?>
