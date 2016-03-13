<?php
/**
* Created by IntelliJ IDEA.
* User: riccardosibani
* Date: 13/03/16
* Time: 10:23
*/

class Server {

  private $action = null;
  private $badRequest = false;
  private $sendingArray = array();
  /**
  *
  *  execute
  *
  *  In this function we link the frontend part with the database
  *  We have to check the input (count them and check if the type is ok
  *  with what the database needs).
  *
  *  Then run the query
  *
  * @param $model
  * @param $action
  * @param $data
  */
  public function execute($operation){

    if(isset($operation->action) && !is_null($operation->action) && !empty($operation->action)){
      $this->action = $operation->action;
    } else {
      echo '[{"error" : "Operation not declared properly"}]';
      $this->badRequest = true;
      die;
    }

    //Check param
    $analyse = $this->analyse($this->action, $operation->data);

    if($analyse && !$this->badRequest){
      $db = new Database();
      $sending = array_values((array) $operation->data);
      $db->callProcedure($this->action, $this->sendingArray);
      return $db->getResult();
    }

  }

  private function analyse($action, $data){
    // Get the params from the db and check the type
    $query = "SELECT * FROM INFORMATION_SCHEMA.PARAMETERS WHERE SPECIFIC_NAME=?";
    $db = new Database();
    $db->stndQuery($query, array($action));
    $result = $db->getResult();

    //check if the number of element is equal to the required elements
    if(count($result) == count((array)$data)){
      //check the input type
      $i = 0;
      while($i<count($result) && !$this->badRequest){

        $req_type = $result[$i]['PARAMETER_NAME'];
        if(isset($data->$req_type) && !is_null($data->$req_type)){
          //The data exist and has the right name
          //check the input type
          switch($result[$i]['DATA_TYPE']){
            case 'decimal':
            (is_numeric($data->$req_type) && is_float($data->$req_type))? null : $this->badRequest=true;
            break;
            case 'int':
            (is_numeric($data->$req_type) && is_int($data->$req_type)) ? null : $this->badRequest=true;
            break;
            case 'text':
            (is_string($data->$req_type) && $result[$i]['CHARACTER_MAXIMUM_LENGTH']>=strlen($data->$req_type))? null : $this->badRequest = true;
            break;
            case 'timestamp':
            (((string) (int) $data->$req_type === $data->$req_type) && ($data->$req_type <= PHP_INT_MAX) && ($data->$req_type >= ~PHP_INT_MAX))? null : $this->badRequest=true;
            break;
            case 'varchar':
            (is_string($data->$req_type) && $result[$i]['CHARACTER_MAXIMUM_LENGTH']>=strlen($data->$req_type))? null : $this->badRequest = true;
            break;
            case 'enum':
            (is_string($data->$req_type) && $result[$i]['CHARACTER_MAXIMUM_LENGTH']>=strlen($data->$req_type))? null : $this->badRequest = true;
            break;
            default:
            $this->badRequest = true;
          }
          if(!$this->badRequest){
            array_push($this->sendingArray, $data->$req_type);
          }
        } else {
          $badName = array_values((array) $data);
          $badName = $badName[$i];
          echo '[{"error" : "Bad Name <strong>'. $badName . '</strong>  "}]';
          $this->badRequest = true;
          return false;
        }


        $i++;
      }

      if($this->badRequest){
        echo '[{ "error" : "Wrong inputs"}]';
        return false;
      } else {
        return true;
      }
    } else {
      //inputs haven't been given properly
      echo '[{ "error" : "Wrong Number of Inputs}]';
      return false;
    }
  }
}
