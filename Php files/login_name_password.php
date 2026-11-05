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
    private array $result = [];

    public function getResult(): array{
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
            $this->sqlCommand->exec_tabletFelhasznaloAdatok(),
            [
                'eszkoz_id' =>     $this->request['eszkoz_id'] ?? null,
                'user_name' =>     $this->request['user_name'] ?? null,
                'user_password' => $this->request['user_password'] ?? null
            ],
            $this->request['customer']
        );

        $this->result = $this->databaseManager->getData();
    }
}

$taskForgottenPassword = new Task();
echo json_encode($taskForgottenPassword->getResult());