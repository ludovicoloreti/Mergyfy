<?php

require_once "config/database.config.php";

class Database extends PDO{
    private $conn = null;
    private $stmt = null;
    //Make connection
    public function __construct(){
        //it shoud verify the configuration file and choose the user
        //for the moment we use che constructor as connect
        return $this->getConnection();
    }

    private function getConnection(){

        $this->conn = new PDO(DB_HOST, DB_USER, DB_PASSWORD);

        try{
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        }catch (PDOException $e){
            die($e->getMessage());
        }

        return $this->conn;
    }

    /*
     *
     */
    public function callProcedure( $functionName, $parameters ){
        $sql = "call " . $functionName."( ";
        for( $i = 0; $i < count($parameters); $i++ ) {
            if($i < count($parameters)-1){
                $sql .= "?";
            }else {
                $sql .= "?,";
            }
        }
        $sql .= " )";
        $this->stmt = $this->conn->prepare( $sql );

        for( $i = 0; $i < count($parameters); $i++ ) {
            $this->stmt->bindParam($i, $parameters[$i]);
        }

        if($this->stmt){
            $this->stmt->execute();
            return true;
        } else {
            return $this->conn->getErrors();
        }
    }

    public function getResult() {
        $this->stmt->fetchAll(PDO::FETCH_ASSOC);

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