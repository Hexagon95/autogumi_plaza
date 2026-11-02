<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

if($_SERVER['REQUEST_METHOD'] === 'OPTIONS'){
    http_response_code(200);
    exit();
}

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/sql/altered_database_managers/dm_execute_sql_from_input.php';

class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private DatabaseManager $databaseManager;
    private array $request = [];

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct(){
        $this->_initialize();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _initialize(): void{
        try{
            $raw = file_get_contents('php://input');
            $decodedRequest = json_decode($raw, true);

            if(!is_array($decodedRequest)){
                throw new RuntimeException('Invalid JSON body.');
            }

            $this->request = $decodedRequest;

            $sql = trim((string)($this->request['input'] ?? ''));
            $parameter = $this->request['parameter'] ?? null;
            $database = (string)($this->request['customer'] ?? 'mosaic');

            if($sql === ''){
                throw new RuntimeException('Missing "input" SQL.');
            }

            $this->databaseManager = new DatabaseManager(
                $sql,
                [
                    ':parameter' => $parameter
                ],
                $database
            );

            echo json_encode(
                [
                    'ok' => true,
                    'data' => $this->databaseManager->getData(),
                    'rowCounts' => $this->databaseManager->getRowCounts(),
                    'outParams' => $this->databaseManager->getOutParams()
                ],
                JSON_UNESCAPED_UNICODE
            );
        }
        catch(Throwable $th){
            http_response_code(500);

            echo json_encode(
                [
                    'ok' => false,
                    'error' => $th->getMessage()
                ],
                JSON_UNESCAPED_UNICODE
            );
        }
    }
}

new Task();