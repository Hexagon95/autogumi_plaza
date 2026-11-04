<?php
class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------    
    private $sqlCommand;
    private $sqlQuery;
    private $databaseManager;
    private $request;

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){        
        $this->_inizialite();        
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->sqlCommand =         new SqlCommand();
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->exec_bizonylatAlairasFelvitele(),
            [
                'parameters' => json_encode([
                    'id' =>         $this->request['bizonylat_id'],
                    'alairo' =>     $this->request['alairo'],
                    'alairas' =>    $this->request['alairas'],
                ])
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
    }
}
