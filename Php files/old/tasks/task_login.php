<?php
/*class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $sqlCommand;
    private $databaseManager;
    private $request;
    private $customer;
    private $result;
        public function getResult(){return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){
        // default result, so it can never be empty
        $this->result = array(['error' => 'Unknown error']);

        try {
            $this->_inizialite();
            // if init failed and already set result, stop
            if (!is_array($this->request)) return;

            $this->_checkID();
        } catch (Throwable $e) {
            // Convert ANY fatal/exception into JSON-safe output
            $this->result = array([
                'error' => 'SERVER_EXCEPTION',
                'message' => $e->getMessage(),
            ]);
        }
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $raw = file_get_contents('php://input');
        $this->request = json_decode($raw, true);

        // Guard: invalid JSON or empty body
        if (!is_array($this->request)) {
            $this->result = array([
                'error' => 'INVALID_REQUEST',
                'message' => 'Invalid JSON or empty body',
                'raw' => $raw,
            ]);
            return;
        }

        // Guard: missing fields
        foreach (['customer','login_type','eszkoz_id'] as $k) {
            if (!isset($this->request[$k])) {
                $this->result = array([
                    'error' => 'INVALID_REQUEST',
                    'message' => "Missing field: $k",
                    'request' => $this->request,
                ]);
                // Mark request invalid so constructor returns early
                $this->request = null;
                return;
            }
        }

        $this->sqlCommand = new SqlCommand();

        // DB call can throw → catch here too (extra safety)
        try {
            $this->databaseManager = new DatabaseManager(
                $this->sqlCommand->select_tabletLista(),
                ['eszkoz_id' => $this->request['eszkoz_id']],
                $this->request['customer']
            );
        } catch (Throwable $e) {
            $this->result = array([
                'error' => 'DB_SELECT_FAILED',
                'message' => $e->getMessage(),
            ]);
            // Stop further processing
            $this->request = null;
            return;
        }
    }

    private function _checkID(){
        $isMatch = false;

        // Always start with a default error message
        if ($this->request['login_type'] === 'customer') {
            $this->result = array([
                'error' => "Az eszköz nincs ügyfélhez rendelve! ({$this->request['eszkoz_id']})"
            ]);
        } elseif ($this->request['login_type'] === 'service') {
            $this->result = array([
                'error' => "Az eszköz nincs szervízhez rendelve! ({$this->request['eszkoz_id']})"
            ]);
        } else {
            $this->result = array([
                'error' => "Érvénytelen login_type: {$this->request['login_type']}"
            ]);
            return;
        }

        // Iterate DB results safely
        $rows = $this->databaseManager ? $this->databaseManager->getData() : [];
        foreach ($rows as $value) {
            // NOTE: your table likely uses lowercase column names (eszkoz_id), but you compare Eszkoz_id
            // Keep BOTH to be safe:
            $dbId = $value['Eszkoz_id'] ?? $value['eszkoz_id'] ?? null;

            if ($dbId == $this->request['eszkoz_id']) {
                $isMatch = true;

                if ($this->request['login_type'] === 'customer') {
                    if (!is_null($value['dolgozo_kod']) && $value['dolgozo_kod'] > 0) {
                        $this->result = array(['error' => '', 'Ugyfel_id' => $value['Ugyfel_id']], $value);
                    }
                } else { // service
                    if (!is_null($value['szerviz_id']) && $value['szerviz_id'] > 0) {
                        $this->result = array(['error' => '', 'szerviz_megnevezes' => $value['szerviz_megnevezes']], $value);
                    }
                }
                break;
            }
        }

        // If not found, try to insert. Catch failures so output is never empty.
        if (!$isMatch) {
            try {
                new DatabaseManager(
                    $this->sqlCommand->exec_tabletFelvitele(),
                    ['eszkoz_id' => $this->request['eszkoz_id']],
                    $this->request['customer']
                );

                // Optional: add a debug hint so you SEE that insertion was attempted
                // You can remove this later.
                $this->result[] = ['debug' => 'insert_attempted'];
            } catch (Throwable $e) {
                // If insert fails, return a useful error instead of blank response
                $this->result = array([
                    'error' => 'DB_INSERT_FAILED',
                    'message' => $e->getMessage(),
                    'eszkoz_id' => $this->request['eszkoz_id'],
                ]);
            }
        }
    }
}*/


class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $sqlCommand;
    private $databaseManager;
    private $request;
    private $customer;
    private $result;
        public function getResult(){return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    function __construct(){       
        $this->_inizialite();
        $this->_checkID();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _inizialite(){
        $this->request =            json_decode(file_get_contents('php://input'), true);
        $this->result =             array(['error' => 'Unknown error']);
        $this->sqlCommand =         new SqlCommand();
        $this->databaseManager =    new DatabaseManager(
            $this->sqlCommand->select_tabletLista(),
            ['eszkoz_id' => $this->request['eszkoz_id']],
            $this->request['customer']
        );
    }

    private function _checkID(){
        $isMatch = false;
        switch($this->request['login_type']){

            case 'customer':
                $this->result = array(['error' => "Az eszköz nincs ügyfélhez rendelve! (".$this->request['eszkoz_id'].")"]);
                foreach ($this->databaseManager->getData() as $value) {
                    if($value['Eszkoz_id'] == $this->request['eszkoz_id']){
                        $isMatch = true;
                        if(!is_null($value['dolgozo_kod']) && $value['dolgozo_kod'] > 0){
                            $this->result = array(['error' => '', 'Ugyfel_id' => $value['Ugyfel_id']], $value);
                        }
                        break;
                    }
                }
                break;

            case 'service':
                $this->result = array(['error' => "Az eszköz nincs szervízhez rendelve! (".$this->request['eszkoz_id'].")"]);
                foreach ($this->databaseManager->getData() as $value) {
                    if($value['Eszkoz_id'] == $this->request['eszkoz_id']){
                        $isMatch = true;
                        if(!is_null($value['szerviz_id']) && $value['szerviz_id'] > 0){
                            $this->result = array(['error' => '', 'szerviz_megnevezes' => $value['szerviz_megnevezes']], $value);
                        }
                        break;
                    }
                }
                break;

            default: break;
        }
        if(!$isMatch) new DatabaseManager(
            $this->sqlCommand->exec_tabletFelvitele(),
            ['eszkoz_id' => $this->request['eszkoz_id']],
            $this->request['customer']
        );
    }
}
