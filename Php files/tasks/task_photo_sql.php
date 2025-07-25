<?php
class Task {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------    
    private $sqlCommand;
    private $sqlQuery;
    private $databaseManager;
    private $request;
    private $BizonylatDokumentumParams;
    private $Customer;
    private $result;
        public function getResult(){return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct($BizonylatDokumentumParams, $Customer){
        $this->BizonylatDokumentumParams = $BizonylatDokumentumParams;
        $this->Customer = $Customer;
        $this->_inizialite();        
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite() {
        $this->request = json_encode($this->BizonylatDokumentumParams, JSON_PRETTY_PRINT);
        $this->sqlCommand = new SqlCommand();

        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->exec_bizonylatKepFelvitele(),
            [
                'parameter' => $this->request,   // JSON string
                'user_id'   => $this->BizonylatDokumentumParams['user_id'] ?? 0
            ],
            $this->Customer
        );
        $this->result = $this->databaseManager->getData();
    }
}

class Task2 {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $sqlCommand;
    private $sqlQuery;
    private $databaseManager;
    private $request;
    private $ParentID;
    private $Customer;
    private $result;
    public function getResult(){return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct($ParentID, $Customer){
        $this->ParentID = $ParentID;
        $this->Customer = $Customer;
        $this->_inizialite();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite() {
        $this->request = $this->ParentID;
        $this->sqlCommand =         new SqlCommand();
		
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->exec_bizonylatID_SQL(),
            ['id' => $this->request],
            $this->Customer
        );
        $this->result = $this->databaseManager->getData();
    }
}

