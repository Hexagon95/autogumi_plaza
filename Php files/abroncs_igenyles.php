<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

if($_SERVER['REQUEST_METHOD'] === 'OPTIONS'){
    http_response_code(200);
    exit();
}

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/sql/sql_commands.php';
require_once __DIR__ . '/sql/database_manager.php';

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
            $this->sqlCommand->select_tabletAbroncsIgenylesReszletezo(),
            [
                'eszkoz_id' =>   $this->request['eszkoz_id'] ?? null,
                'munkalap_id' => $this->request['munkalap_id'] ?? null,
                'datum' =>       $this->request['datum'] ?? null,
                'foglalas_id' => $this->request['foglalas_id'] ?? null
            ],
            $this->request['customer']
        );
        $data = $this->databaseManager->getData();
        $this->result = $data[0]['b'] ?? null;
    }
}

$task_abroncs_igenyles = new Task();
echo json_encode($task_abroncs_igenyles->getResult());