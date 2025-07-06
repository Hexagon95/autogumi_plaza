<?php
class DatabaseManager{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------    
    private $pdoServer =   "79.139.58.246";
    private $pdoUser =     "app";
    private $pdoPassword = "Dh!Flmn2J6uJ";
    private $data;
    public function getData() {return $this->data;}
    public $conn;
    
    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct($queryString, $parameters = [], $pdoDatabase){        
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
            $sqlQuery->bindParam(':foglalas_id', $parameters['foglalas_id'], PDO::PARAM_INT);
            $sqlQuery->bindParam(':indoklas', $parameters['indoklas'], PDO::PARAM_STR);
			$sqlQuery->bindParam(':output', $this->data, PDO::PARAM_STR|PDO::PARAM_INPUT_OUTPUT, 4000);
            $sqlQuery->execute();
        }
        catch (\Throwable $th){
            $this->data = json_encode(array(['Execution failed' => $th->getMessage()]));
        }
    }
}