<?php
class DatabaseManager {
    // ---------- <Config> -------------------------------------------------------
    private $pdoServer   = "79.139.58.246";
    private $pdoUser     = "app";
    private $pdoPassword = "Dh!Flmn2J6uJ";

    // ---------- <State> --------------------------------------------------------
    private $conn;
    private $rowsets      = [];   // array of result sets (each is array<assoc>)
    private $rowcounts    = [];   // array of ints (affected rows for each non-select rowset)
    private $outParams    = [];   // captured OUT/INPUT_OUTPUT params after execute

    // Public getters
    public function getData()       { return $this->rowsets; }          // all result sets
    public function getRowCounts()  { return $this->rowcounts; }        // row counts
    public function getOutParams()  { return $this->outParams; }        // OUT params (if used)

    // ---------- <Ctor> ---------------------------------------------------------
    function __construct($queryString, $parameters = [], $pdoDatabase = "mosaic") {
        $this->connect($pdoDatabase);
        $this->executeQuery($queryString, $parameters);
    }

    // ---------- <Connect> ------------------------------------------------------
    private function connect($pdoDatabase) {
        try {
            $this->conn = new PDO(
                "sqlsrv:Server={$this->pdoServer};Database={$pdoDatabase};",
                $this->pdoUser,
                $this->pdoPassword,
                [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
            );
        } catch (\Throwable $th) {
            throw new \Exception("Connection failed: " . $th->getMessage());
        }
    }

    // ---------- <Execute> ------------------------------------------------------
    /**
     * $parameters supports two styles:
     * 1) Simple execute params:
     *    [':id' => 123, ':name' => 'abc']
     *
     * 2) Advanced binding (for OUT / INPUT_OUTPUT):
     *    [
     *      ':inval'  => 123,                                   // simple IN
     *      ':outval' => ['value'=>null, 'type'=>PDO::PARAM_INT, 'length'=>8, 'io'=>'out'],
     *      ':inout'  => ['value'=>&$var,  'type'=>PDO::PARAM_STR, 'length'=>50, 'io'=>'inout'],
     *    ]
     */
    private function executeQuery($queryString, $parameters) {
        try {
            $stmt = $this->conn->prepare($queryString);

            // Detect whether we must bind manually (for OUT/INOUT)
            $needsBinding = false;
            foreach ($parameters as $k => $v) {
                if (is_array($v)) { $needsBinding = true; break; }
            }

            if ($needsBinding) {
                // Bind param-by-param to support OUT/INOUT
                foreach ($parameters as $name => &$meta) {
                    if (!is_array($meta)) {
                        // plain IN value
                        $stmt->bindValue($name, $meta);
                        continue;
                    }
                    $io     = strtolower($meta['io'] ?? 'in');
                    $type   = $meta['type']   ?? PDO::PARAM_STR;
                    $len    = $meta['length'] ?? 4000; // default length for strings
                    // Ensure we have a variable to bind by reference
                    if (!array_key_exists('value', $meta)) { $meta['value'] = null; }

                    $paramType = $type;
                    if ($io === 'out' || $io === 'inout') {
                        $paramType |= PDO::PARAM_INPUT_OUTPUT;
                    }

                    // bindParam needs a variable
                    $stmt->bindParam($name, $meta['value'], $paramType, $len);
                }
                $stmt->execute();
            } else {
                // Simple execute with array of values
                $stmt->execute($parameters);
            }

            // Collect all rowsets and row counts
            $this->rowsets   = [];
            $this->rowcounts = [];

            do {
                if ($stmt->columnCount() > 0) {
                    $this->rowsets[] = $stmt->fetchAll(PDO::FETCH_ASSOC);
                } else {
                    // no columns → this rowset is an update/insert count
                    $this->rowcounts[] = $stmt->rowCount();
                }
            } while ($stmt->nextRowset());

            // Capture OUT/INOUT values (if any)
            $this->outParams = [];
            foreach ($parameters as $name => $meta) {
                if (is_array($meta)) {
                    $io = strtolower($meta['io'] ?? 'in');
                    if ($io === 'out' || $io === 'inout') {
                        $this->outParams[$name] = $meta['value'];
                    }
                }
            }

        } catch (\Throwable $th) {
            throw new \Exception("SQL execution failed: " . $th->getMessage() . " | Query: $queryString");
        }
    }
}