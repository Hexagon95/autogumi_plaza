<?php

require_once __DIR__ . '/config.php';

class DatabaseManager {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private string $pdoServer =     DB_SERVER;
    private string $pdoUser =       DB_USER;
    private string $pdoPassword =   DB_PASSWORD;
    private PDO $conn;
    private array $data = [];

    public function getData(): array {
        return $this->data;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct(string $queryString, array $parameters = [], string $pdoDatabase = "mosaic") {
        $this->_connect($pdoDatabase);
        $this->_executeQuery($queryString, $parameters);
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _connect(string $pdoDatabase): void {
        try {
            $this->conn = new PDO(
                "sqlsrv:Server={$this->pdoServer};Database={$pdoDatabase};",
                $this->pdoUser,
                $this->pdoPassword,
                [
                    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC
                ]
            );
        }
        catch(Throwable $th) {
            throw new RuntimeException(
                "Connection failed: " . $th->getMessage(),
                (int)$th->getCode(),
                $th
            );
        }
    }

    private function _executeQuery(string $queryString, array $parameters): void {
        try {
            $sqlQuery = $this->conn->prepare($queryString);
            $sqlQuery->execute($parameters);
            $this->data = [];
            do {
                if($sqlQuery->columnCount() > 0) {
                    $this->data = $sqlQuery->fetchAll(PDO::FETCH_ASSOC);
                    break;
                }
            } while($sqlQuery->nextRowset());
        }
        catch(Throwable $th) {
            throw new RuntimeException(
                "SQL execution failed: " . $th->getMessage() . " | Query: {$queryString}",
                (int)$th->getCode(),
                $th
            );
        }
    }
}