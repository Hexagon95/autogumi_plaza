<?php
header('Content-Type: application/json; charset=utf-8');
include 'database_manager.php';
class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------    
    private $databaseManager;
    private $request;
    private $result;
        public function getResult(){return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){        
        $this->_inizialite();        
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
     private function _inizialite(){
        try{
            $this->request =            json_decode(file_get_contents('php://input'), true);
            $this->databaseManager =    new DatabaseManager(
                $this->request['input'],
                ['parameter' =>  $this->request['parameter']],
                $this->request['customer']
            );
            $this->result = $this->databaseManager->getData();
            echo $this->result;
        }
        catch(\Throwable $th){
            echo $th->getMessage();
        }
    }
}

new Task();