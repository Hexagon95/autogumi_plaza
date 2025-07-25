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
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand =         new SqlCommand();
        $this->databaseManager =    new DatabaseManager(
            ($this->request['jelleg'] != 'Eseti')
                ? $this->sqlCommand->exec_tabletMunkalapMeghiusulas()
                : $this->sqlCommand->exec_tabletMunkalapEsetiMeghiusulas()
            ,
            [
                'foglalas_id' => $this->request['foglalas_id'],
                'indoklas' =>    $this->request['indoklas'],
                'user_id' =>     $this->request['user_id']
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
    }
}