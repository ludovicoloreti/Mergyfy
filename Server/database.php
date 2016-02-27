<?php

require_once "config/database.config.php";

class Database extends PDO{

    private $host ="mysql:host=localhost;dbname=merge";
    private $user = "root";
    private $pass = "root";
    private $dbHandle = null;
    private $results = null;

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
            } catch(Error $e){
                echo $e;
            }

            return true;
        } else {
            return $this->conn->getErrors();
        }
    }

    public function getResult() {
        return $this->stmt->fetchAll(PDO::FETCH_ASSOC);

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