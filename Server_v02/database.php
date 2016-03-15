<?php

class Database extends PDO{

    private $host ="mysql:host=localhost;dbname=merge";
    private $user = "root";
    private $pass = "root";
    private $dbHandle = null;
    private $results = null;
    private $errors = null;

    private $conn = null;
    private $stmt = null;
    //Make connection
    public function __construct(){
        //it shoud verify the configuration file and choose the user
        //for the moment we use che constructor as connect
        return $this->getConnection();
    }

    private function getConnection(){

        $this->conn = new PDO($this->host, $this->user, $this->pass);

        try{
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        }catch (PDOException $e){
            die($e->getMessage());
        }

        return $this->conn;
    }


    public function stndQuery($query, $parameters){
        $this->stmt = $this->conn->prepare($query);

        foreach($parameters as $key=>&$value){
            $this->stmt->bindParam($key+1, $value);
        }

        if($this->stmt){
            try {
                $this->stmt->execute();
            }catch(error $e){

                echo $e;
            }
            return true;
        } else{
            return $this->conn->getErrors();
        }
    }

    /*
     *
     */
    public function callProcedure( $functionName, $parameters ){
        $sql = "call " . $functionName."( ";
        for( $i = 0; $i < count($parameters); $i++ ) {
            if($i < count($parameters)-1){
                $sql .= "?,";
            }else {
                $sql .= "?";
            }
        }
        $sql .= " )";

        $this->stmt = $this->conn->prepare( $sql );

        foreach ($parameters as $key => &$value) {  //pass $value as a reference to the array item
            $this->stmt->bindParam($key+1, $value);  // bind the variable to the statement
        }

        if($this->stmt){
            try{
                $this->stmt->execute();
            } catch(Exception $pdo){
                $this->errors = $pdo;
            }

            return true;
        } else {
            return $this->conn->getErrors();
        }
    }

    public function getResult() {
        return is_null($this->errors)? $this->stmt->fetchAll(PDO::FETCH_ASSOC) : $this->errors;

    }

    //Display error
    public function getErrors(){

        $this->conn->errorInfo();
    }

    //Closes the database connection when object is destroyed
    public function __destruct()
    {
        $this->conn = null;
    }
}