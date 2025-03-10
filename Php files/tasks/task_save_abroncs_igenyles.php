<?php
class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------    
    private $sqlCommand;
    private $sqlQuery;
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
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand =         new SqlCommand();
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->exec_tabletAbroncsigenylesFelvitele(),
            [
                'parameter' =>  $this->request['parameter'],
                'user_id' =>    $this->request['user_id'],
                'lezart' =>     $this->request['lezart']
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
    }
}
