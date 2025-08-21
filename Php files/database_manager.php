<?php
class DatabaseManager {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $pdoServer   = "79.139.58.246";
    private $pdoUser     = "app";
    private $pdoPassword = "Dh!Flmn2J6uJ";
    private $conn;
    private $data;

    public function getData() {
        return $this->data;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct($queryString, $parameters = [], $pdoDatabase = "mosaic") {
        $this->_connect($pdoDatabase);
        $this->_executeQuery($queryString, $parameters);
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _connect($pdoDatabase) {
        try {
            $this->conn = new PDO("sqlsrv:Server=$this->pdoServer;Database=$pdoDatabase;", $this->pdoUser, $this->pdoPassword);
            $this->conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        } catch (\Throwable $th) {
            // Instead of echo → throw
            throw new \Exception("Connection failed: " . $th->getMessage());
        }
    }

    private function _executeQuery($queryString, $parameters) {
        try {
            $sqlQuery = $this->conn->prepare($queryString);
            $sqlQuery->execute($parameters);

            try {
                $sqlQuery->setFetchMode(PDO::FETCH_ASSOC);
                $this->data = $sqlQuery->fetchAll();
            } catch (\Throwable $th) {
                throw new \Exception("Fetch failed: " . $th->getMessage());
            }

        } catch (\Throwable $th) {
            // Instead of print → throw
            throw new \Exception("SQL execution failed: " . $th->getMessage() . " | Query: $queryString");
        }
    }
}
