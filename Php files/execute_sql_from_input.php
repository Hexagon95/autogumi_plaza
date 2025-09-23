<?php
header('Content-Type: application/json; charset=utf-8');
include 'altered_database_managers/dm_execute_sql_from_input.php';
class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------    
    private $databaseManager;
    private $request;    

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){        
        $this->_initialize();        
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
      private function _initialize(){
        try {
            $raw = file_get_contents('php://input');
            $this->request = json_decode($raw, true);
            if (!is_array($this->request)) {
                throw new \Exception('Invalid JSON body.');
            }

            // Expect: input = SQL string like "EXEC dbo.proc :parameter"
            //         parameter = already-encoded JSON string (or whatever your proc expects)
            $sql        = $this->request['input']    ?? '';
            $parameter  = $this->request['parameter'] ?? null;
            $database   = $this->request['customer'] ?? 'mosaic';

            if ($sql === '') {
                throw new \Exception('Missing "input" SQL.');
            }

            // IMPORTANT: key must match the placeholder name including the colon
            $this->databaseManager = new DatabaseManager(
                $sql,
                [':parameter' => $parameter],
                $database
            );

            $response = [
                'ok'         => true,
                'data'       => $this->databaseManager->getData(),      // array of rowsets
                'rowCounts'  => $this->databaseManager->getRowCounts(), // array of ints
                'outParams'  => $this->databaseManager->getOutParams(), // if you ever bind OUT/INOUT
            ];
            echo json_encode($response, JSON_UNESCAPED_UNICODE);

        } catch (\Throwable $th) {
            http_response_code(500);
            echo json_encode([
                'ok'    => false,
                'error' => $th->getMessage(),
            ], JSON_UNESCAPED_UNICODE);
        }
    }
}

new Task();