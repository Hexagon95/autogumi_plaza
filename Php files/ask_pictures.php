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
        try{
            $decodedRequest = json_decode(file_get_contents('php://input'), true);
            $this->request = is_array($decodedRequest)? $decodedRequest : [];

            $mit = ["☀️", "❄️", "🌦️", "🛞"];
            $mire = ["", "", "", ""];
            $this->request['pozicio'] = str_replace(
                $mit,
                $mire,
                $this->request['pozicio']
            );

            $this->sqlCommand = new SqlCommand();
            $this->databaseManager = new DatabaseManager(
                ($this->request['jelleg'] === 'Eseti')
                    ? $this->sqlCommand->select_MunkalapEsetiPozicioKepek()
                    : $this->sqlCommand->select_MunkalapSzezonalisPozicioKepek(),
                [
                    'foglalas_id' => $this->request['foglalas_id'],
                    'pozicio' => $this->request['pozicio']
                ],
                $this->request['customer']
            );

            $this->result = $this->databaseManager->getData();
        }
        catch(Throwable $th){
            $this->result = json_encode([
                ['Php Error' => $th->getMessage()]
            ]);
        }
    }
}

$taskAskPictures = new Task();
echo json_encode($taskAskPictures->getResult());