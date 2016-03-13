<?php
/**
 * Created by IntelliJ IDEA.
 * User: riccardosibani
 * Date: 13/03/16
 * Time: 10:44
 */

$test = true;
$input = "[
  {
    \"action\" : \"login\",
    \"data\" : {
      \"mail\": \"mail@mail.com\",
      \"password\": \"HASHEDPASS\",
      \"lat\": 44.12345,
      \"lng\": 11.98765
    }
  },
  {
    \"action\" : \"getPlace\",
    \"data\": {
      \"id\": 1
    }
  }
]";

include_once "../Server_v02/handler.php";
