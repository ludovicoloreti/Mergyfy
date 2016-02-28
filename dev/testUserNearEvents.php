<?php
include_once "../Server/Objects/event.php";
include_once "../Server/database.php";
include_once "../Server/Functions/jsonUtilities.php";

$data = "{
    \"model\": \"event\",
    \"action\": \"userNearEvents\",
    \"param\": {
        \"id\": \"1\",
        \"distance\": 50
    }
}";

$event = new Event();
$event->userNearEvents($data);

