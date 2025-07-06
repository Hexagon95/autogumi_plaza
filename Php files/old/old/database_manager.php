<?php
class DatabaseManager{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------    
    private $pdoServer =   "localhost";
    //private $pdoDatabase = "mosaic_test";
    private $pdoUser =     "app";
    private $pdoPassword = "Dh!Flmn2J6uJ";
    private $conn;
    private $data;
        public function getData(){return $this->data;
    }
    
    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct($queryString, $parameters = [], $pdoDatabase = "mosaic"){
        $this->_connect($pdoDatabase);
        $this->_executeQuery($queryString, $parameters);
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _connect($pdoDatabase){
        try {            
            $this->conn = new PDO("sqlsrv:Server=$this->pdoServer;Database=$pdoDatabase;", $this->pdoUser, $this->pdoPassword);
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        }
        catch (\Throwable $th) {            
            echo json_encode(array(['Connection failed' => $th->getMessage()]));
        }
    }

    private function _executeQuery($queryString, $parameters){
        try {           
            $sqlQuery = $this->conn->prepare($queryString);
            $sqlQuery->execute($parameters);
            try {
                $sqlQuery->setFetchMode(PDO::FETCH_ASSOC);
                $this->data = $sqlQuery->fetchAll();
            }
            catch (\Throwable $th) {}
        }
        catch (\Throwable $th) {
            $this->data = json_encode(array(['Execution failed' => $th->getMessage()]));
        }
    }
}