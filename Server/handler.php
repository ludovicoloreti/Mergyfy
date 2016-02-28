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
include_once "Functions/jsonUtilities.php";
foreach (glob("Objects/*.php") as $filename)
{
    include_once $filename;
}

if(isset($test) && $test){
    //prepare the parameters in advance
    echo "---- DEV MODE ----<br><br><br><br>";
    $action = $action;
    $model = $model;
    $data = $data;
} else{
    $dataJson = file_get_contents("php://input");
    $action = $_REQUEST['action'];
    $model = $_REQUEST['model'];
}


if ((isset($data)) || (!empty($data)) || (!is_null($data))) {
	// POST
    $post = new Server();
    $post->execute($model, $action, $data);
} else {
	// GET
	$mdl = new $model();
	$mdl->$action();
}
?>