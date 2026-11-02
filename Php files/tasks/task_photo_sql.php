<?php

class Task {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private SqlCommand $sqlCommand;
    private DatabaseManager $databaseManager;
    private mixed $request = null;
    private array $BizonylatDokumentumParams;
    private string $Customer;
    private array $result = [];

    public function getResult(): array{
        return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct(array $BizonylatDokumentumParams, string $Customer){
        $this->BizonylatDokumentumParams = $BizonylatDokumentumParams;
        $this->Customer = $Customer;
        $this->_inizialite();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(): void{
        $this->request = json_encode($this->BizonylatDokumentumParams, JSON_PRETTY_PRINT);
        $this->sqlCommand = new SqlCommand();
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->exec_bizonylatKepFelvitele(),
            [
                'parameter' => $this->request,
                'user_id' => $this->BizonylatDokumentumParams['user_id'] ?? 0
            ],
            $this->Customer
        );
        $this->result = $this->databaseManager->getData();
    }
}

class Task2 {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private SqlCommand $sqlCommand;
    private DatabaseManager $databaseManager;
    private mixed $request = null;
    private mixed $ParentID;
    private string $Customer;
    private array $result = [];

    public function getResult(): array{
        return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct(mixed $ParentID, string $Customer){
        $this->ParentID = $ParentID;
        $this->Customer = $Customer;
        $this->_inizialite();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(): void{
        $this->request = $this->ParentID;
        $this->sqlCommand = new SqlCommand();
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->exec_bizonylatID_SQL(),
            [
                'id' => $this->request
            ],
            $this->Customer
        );
        $this->result = $this->databaseManager->getData();
    }
}