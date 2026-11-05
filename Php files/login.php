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
        $this->_checkID();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(): void{
        $decodedRequest = json_decode(file_get_contents('php://input'), true);
        $this->request = is_array($decodedRequest)? $decodedRequest : [];
        $this->result = [['error' => 'Unknown error']];
        $this->sqlCommand = new SqlCommand();
        $this->databaseManager = new DatabaseManager(
            $this->sqlCommand->select_tabletLista(),
            [
                'eszkoz_id' => $this->request['eszkoz_id']
            ],
            $this->request['customer']
        );
    }

    private function _checkID(): void{
        $isMatch = false;

        switch($this->request['login_type'] ?? ''){
            case 'customer':
                $this->result = [[
                    'error' => "Az eszköz nincs ügyfélhez rendelve! ({$this->request['eszkoz_id']})"
                ]];

                foreach($this->databaseManager->getData() as $value){
                    if($value['Eszkoz_id'] == $this->request['eszkoz_id']){
                        $isMatch = true;

                        if(!is_null($value['dolgozo_kod']) && $value['dolgozo_kod'] > 0){
                            $this->result = [
                                [
                                    'error' => '',
                                    'Ugyfel_id' => $value['Ugyfel_id']
                                ],
                                $value
                            ];
                        }

                        break;
                    }
                }
                break;

            case 'service':
                $this->result = [[
                    'error' => "Az eszköz nincs szervízhez rendelve! ({$this->request['eszkoz_id']})"
                ]];

                foreach($this->databaseManager->getData() as $value){
                    if($value['Eszkoz_id'] == $this->request['eszkoz_id']){
                        $isMatch = true;

                        if(!is_null($value['szerviz_id']) && $value['szerviz_id'] > 0){
                            $this->result = [
                                [
                                    'error' => '',
                                    'szerviz_megnevezes' => $value['szerviz_megnevezes']
                                ],
                                $value
                            ];
                        }

                        break;
                    }
                }
                break;

            default:
                break;
        }

        if(!$isMatch){
            new DatabaseManager(
                $this->sqlCommand->exec_tabletFelvitele(),
                [
                    'eszkoz_id' => $this->request['eszkoz_id'] ?? null
                ],
                $this->request['customer']
            );
        }
    }
}

$taskLogin = new Task();
echo json_encode($taskLogin->getResult());