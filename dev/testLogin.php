<?php
include_once "../Server/Objects/user.php";
include_once "../Server/database.php";

$data = "{
	\"model\": \"user\",
	\"action\": \"login\",
	\"param\": {
		\"mail\": \"riccardo.sibani@gmail.com\",
		\"password\": \"udajzoial2345rsfdk\"
	}
}";

$usr = new User();

$usr->login($data);

