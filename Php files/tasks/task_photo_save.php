<?php

class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private SqlCommand $sqlCommand;
    private DatabaseManager $databaseManager;
    private array $request = [];
    private mixed $result = null;

    public function getResult(): mixed{
        return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct(){
        $this->_initialize();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _initialize(): void{
        $this->request = json_decode(file_get_contents('php://input'), true) ?? [];
        $this->sqlCommand = new SqlCommand();
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->exec_bizonylatKepPozicioFelvitele(),
            [
                'parameter' => $this->request['parameter'],
                'user_id' =>   $this->request['user_id']
            ],
            $this->request['customer']
        );
        $this->result = $this->databaseManager->getData();
    }
}