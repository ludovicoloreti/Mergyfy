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
        $operation->data = array_values((array) $operation->data); //convert data from object to array
        $analyse = $this->analyse($this->action, $operation->data);

        if($analyse && !$this->badRequest){
            $db = new Database();
            $db->callProcedure($this->action, $operation->data);
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
        if(count($result) == count($data)){

            //check the input type
            $i = 0;
            while($i<count($result) && !$this->badRequest){
                switch($result[$i]['DATA_TYPE']){
                    case 'decimal':
                        (is_numeric($data[$i]) && is_float($data[$i]))? null : $this->badRequest=true;
                        break;
                    case 'int':
                        (is_numeric($data[$i]) && is_int($data[$i])) ? null : $this->badRequest=true;
                        break;
                    case 'text':
                        (is_string($data[$i]) && $result[$i]['CHARACTER_MAXIMUM_LENGTH']>=strlen($data[$i]))? null : $this->badRequest = true;
                        break;
                    case 'timestamp':
                        (((string) (int) $data[$i] === $data[$i]) && ($data[$i] <= PHP_INT_MAX) && ($data[$i] >= ~PHP_INT_MAX))? null : $this->badRequest=true;
                        break;
                    case 'varchar':
                        (is_string($data[$i]) && $result[$i]['CHARACTER_MAXIMUM_LENGTH']>=strlen($data[$i]))? null : $this->badRequest = true;
                        break;
                    default:
                        $this->badRequest = true;
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