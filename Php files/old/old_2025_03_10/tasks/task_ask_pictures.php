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
        try{
            $this->request =            json_decode(file_get_contents('php://input'), true);
            //$this->request =            json_decode($_REQUEST['params'], true);
            $this->sqlCommand =         new SqlCommand();        
            $this->databaseManager =    new DatabaseManager(
                ($this->request['jelleg'] == 'Eseti')
                    ? $this->sqlCommand->select_MunkalapEsetiPozicioKepek()
                    : $this->sqlCommand->select_MunkalapSzezonalisPozicioKepek()
                ,
                [
                    'foglalas_id' =>    $this->request['foglalas_id'],
                    'pozicio' =>        $this->request['pozicio']
                ],
                $this->request['customer']
            );
            $this->result =             $this->databaseManager->getData();
        }
        catch (\Throwable $th) {
            $this->result = json_encode(array(['Php Error' => $th->getMessage()]));
        }
    }
}