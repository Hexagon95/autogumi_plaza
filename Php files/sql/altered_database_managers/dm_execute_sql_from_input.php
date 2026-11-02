<?php

require_once __DIR__ . '/../config.php';

class DatabaseManager {
    // ---------- <Config> -------------------------------------------------------
    private string $pdoServer =   DB_SERVER;
    private string $pdoUser =     DB_USER;
    private string $pdoPassword = DB_PASSWORD;

    // ---------- <State> --------------------------------------------------------
    private PDO $conn;
    private array $rowsets =   [];
    private array $rowcounts = [];
    private array $outParams = [];

    // ---------- <Getters> ------------------------------------------------------
    public function getData(): array {
        return $this->rowsets;
    }

    public function getRowCounts(): array {
        return $this->rowcounts;
    }

    public function getOutParams(): array {
        return $this->outParams;
    }

    // ---------- <Constructor> --------------------------------------------------
    public function __construct(string $queryString, array $parameters = [], string $pdoDatabase = "mosaic") {
        $this->connect($pdoDatabase);
        $this->executeQuery($queryString, $parameters);
    }

    // ---------- <Connect> ------------------------------------------------------
    private function connect(string $pdoDatabase): void {
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

    // ---------- <Execute> ------------------------------------------------------
    private function executeQuery(string $queryString, array $parameters): void {
        try {
            $stmt = $this->conn->prepare($queryString);
            $needsBinding = false;
            foreach($parameters as $value) {
                if(is_array($value)) {
                    $needsBinding = true;
                    break;
                }
            }

            if($needsBinding) {
                foreach($parameters as $name => &$meta) {
                    if(!is_array($meta)) {
                        $stmt->bindValue($name, $meta);
                        continue;
                    }
                    $io = strtolower((string)($meta['io'] ?? 'in'));
                    $type = (int)($meta['type'] ?? PDO::PARAM_STR);
                    $length = (int)($meta['length'] ?? 4000);
                    if(!array_key_exists('value', $meta)) $meta['value'] = '';
                    $paramType = $type;
                    if($io === 'out' || $io === 'inout') $paramType |= PDO::PARAM_INPUT_OUTPUT;
                    $stmt->bindParam($name, $meta['value'], $paramType, $length);
                }
                unset($meta);
                $stmt->execute();
            }
            else {
                $stmt->execute($parameters);
            }

            $this->rowsets = [];
            $this->rowcounts = [];

            do {
                if($stmt->columnCount() > 0) {
                    $this->rowsets[] = $stmt->fetchAll(PDO::FETCH_ASSOC);
                }
                else {
                    $this->rowcounts[] = $stmt->rowCount();
                }
            } while($stmt->nextRowset());

            $this->outParams = [];

            foreach($parameters as $name => $meta) {
                if(!is_array($meta)) continue;
                $io = strtolower((string)($meta['io'] ?? 'in'));
                if($io === 'out' || $io === 'inout') $this->outParams[$name] = $meta['value'];
            }
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