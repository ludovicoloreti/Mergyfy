<?php

class Server{

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
    public function execute($model, $action, $data){
        $param = json_decode($data);

        $sending = new JsonUtilities();
        $sending = $sending->fromJsonToArray($param);

        //check parameters (count them and analyse)
        $analyse = $this->analyse($action, $sending);

        if($analyse){
            $db = new Database();
            $db->callProcedure($action, $sending);
            echo json_encode($db->getResult());
        }
    }

    public function analyse($action, $sending){

        $query = "SELECT * FROM INFORMATION_SCHEMA.PARAMETERS WHERE SPECIFIC_NAME=?";

        $db = new Database();
        $db->stndQuery($query, array($action));
        $result = $db->getResult();

        //Check if the number of elements is equal to the required elements
        if(count($result) == count($sending)){
            //number of input and required parameters corresponds
            //check the inputs
            $goodInput = true;
            $i=0;
            while($i<count($result) && $goodInput){
                switch($result[$i]['DATA_TYPE']){
                    case 'varchar':
                        (is_string($sending[$i]) && $result[$i]['CHARACTER_MAXIMUM_LENGTH']>=strlen($sending[$i]))? null : $goodInput=false;
                        break;
                    case 'int':
                        (is_int($sending[$i]))? null : $goodInput=false;
                        break;
                    case 'timestamp':
                        (is_float($sending[$i] || is_int($sending[$i])))? null : $goodInput=false;
                        break;
                    case 'text':
                        (is_string($sending[$i]) && $result[$i]['CHARACTER_MAXIMUM_LENGTH']>=strlen($sending[$i]))? null : $goodInput=false;
                        break;
                        //DATE?
                    case 'decimal':
                        (is_float($sending[$i]) || is_int($sending[$i]))? null : $goodInput=false;
                        break;
                    default:
                        $goodInput = false;
                }
                $i++;
            }

            if($goodInput){
                //continue
                return true;
            } else {
                //Wrong params
                echo "[{'error': 'Wrong inputs'}]";
                return false;
            }
        }else{
            //inputs haven't been given properly
            echo "[{'error': 'Wrong number of inputs'}]";
            return false;
        }
    }
}