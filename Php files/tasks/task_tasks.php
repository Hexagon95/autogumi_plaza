<?php
class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $sqlCommand;
    private $databaseManager;
    private $request;
    private $result;
        public function getResult(){return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){       
        $this->_inizialite();
        $this->_checkResult();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand =         new SqlCommand();
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->select_tabletNapiMunkalapok(),
            ['eszkoz_id' => $this->request['eszkoz_id'], 'datum' => $this->request['datum']],
            $this->request['customer']
        );
    }

    private function _checkResult(){
        if($this->databaseManager->getData()[0]['b'] == null){
            $this->result = array([
                'error' =>  "Nincs feladat az adott napra!",
                'json' =>   ""
            ]);
        }
        else{
            $this->result = array([
                'error' =>  "",
                'json' =>   $this->databaseManager->getData()[0]['b']
            ]);
        }
    }
}