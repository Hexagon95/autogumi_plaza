<?php
require_once __DIR__ . '/../config.php';

class DatabaseManager{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private string $pdoServer =   DB_SERVER;
    private string $pdoUser =     DB_USER;
    private string $pdoPassword = DB_PASSWORD;
    private string $data =        '';
    public ?PDO $conn =           null;

    public function getData(): string{
        return $this->data;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct(string $queryString, array $parameters = [], string $pdoDatabase = "mosaic"){
        if(!$this->_connect($pdoDatabase)) return;
        $this->_executeQuery($queryString, $parameters);
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _connect(string $pdoDatabase): bool{
        try{
            $this->conn = new PDO(
                "sqlsrv:Server={$this->pdoServer};Database={$pdoDatabase};",
                $this->pdoUser,
                $this->pdoPassword,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
                ]
            );
            return true;
        }
        catch(Throwable $th){
            $this->data = json_encode([['Connection failed' => $th->getMessage()]]) ?: '[]';
            return false;
        }
    }

    private function _executeQuery(string $queryString, array $parameters): void{
        try{
            if($this->conn === null) return;
            $sqlQuery = $this->conn->prepare($queryString);
            $sqlQuery->bindValue(':foglalas_id', $parameters['foglalas_id'], PDO::PARAM_INT);
            $sqlQuery->bindValue(':indoklas', $parameters['indoklas'], PDO::PARAM_STR);
            $sqlQuery->bindValue(':user_id', $parameters['user_id'], PDO::PARAM_INT);
            $sqlQuery->bindParam(':output', $this->data, PDO::PARAM_STR | PDO::PARAM_INPUT_OUTPUT, 4000);
            $sqlQuery->execute();
            while($sqlQuery->nextRowset()){}
        }
        catch(Throwable $th){
            $this->data = json_encode([['Execution failed' => $th->getMessage()]]) ?: '[]';
        }
    }
}