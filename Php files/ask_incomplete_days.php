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
        $this->_inizialite();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(): void{
        $decodedRequest = json_decode(file_get_contents('php://input'), true);
        $this->request = is_array($decodedRequest)? $decodedRequest : [];
        $this->sqlCommand = new SqlCommand();
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->select_tabletNaptarMunkalapok(),
            [
                'eszkoz_id' => $this->request['eszkoz_id'] ?? null,
                'datum_tol' => $this->request['datum_tol'] ?? null,
                'datum_ig' => $this->request['datum_ig'] ?? null
            ],
            $this->request['customer']
        );
        $data = $this->databaseManager->getData();
        $this->result = $data[0]['b'] ?? null;
    }
}

$taskAskIncompleteDays = new Task();
echo json_encode($taskAskIncompleteDays->getResult());