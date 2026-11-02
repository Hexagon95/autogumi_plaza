<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

if($_SERVER['REQUEST_METHOD'] === 'OPTIONS'){
    http_response_code(200);
    exit();
}

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/sql/database_manager.php';

class Task{
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private array $result = [];

    public function getResult(): array{
        return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct(){
        $this->_initialize();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _initialize(): void{
        $decodedRequest = json_decode(file_get_contents('php://input'), true);
        $request = is_array($decodedRequest)? $decodedRequest : [];

        $data = isset($request['data']) && is_array($request['data'])? $request['data'] : [];
        $tasks = isset($request['tasks']) && is_array($request['tasks'])? $request['tasks'] : [];
        $customer = (string)($request['customer'] ?? 'mosaic');
        $errors = [];
        $debugTasks = [];

        // ───── LOG: START ───────────────────────────────────────────────
        $logStart = microtime(true);
        $logDir = __DIR__ . '/logs';

        if(!is_dir($logDir)){
            @mkdir($logDir, 0775, true);
        }

        $logFile = $logDir . '/task_multiple_tasks_at_once_log.txt';

        $log = static function(string $line) use ($logFile): void{
            @file_put_contents(
                $logFile,
                '[' . date('Y-m-d H:i:s') . '] ' . $line . PHP_EOL,
                FILE_APPEND
            );
        };

        $log(sprintf(
            'START customer=%s tasks=%d',
            $customer,
            count($tasks)
        ));
        // ────────────────────────────────────────────────────────────────

        foreach($tasks as $task){
            try{
                if(!is_array($task)) continue;

                $sql = (string)($task['lookup_data'] ?? '');
                $id = $task['id'] ?? null;
                $isPhp = isset($task['php']) && $task['php'] == "1";
                $event = $task['event'] ?? null;
                $newValue = $task['newValue'] ?? null;
                $isCheck = isset($task['isCheckBox']) && (bool)$task['isCheckBox'];

                // ───── 0️⃣ Event filtering (checkbox logic) ─────────────
                if($isCheck && $event){
                    if(
                        ($event === 'on' && $newValue == '0') ||
                        ($event === 'off' && $newValue == '1')
                    ){
                        continue;
                    }
                }

                // ───── 1️⃣ Placeholder replacement ─────────────────────
                $sql = preg_replace_callback(
                    '/\[([^\]]+)\]/',
                    static function(array $matches) use ($data): string{
                        $fieldId = $matches[1];

                        foreach($data as $field){
                            if(!is_array($field)) continue;
                            if(($field['id'] ?? null) !== $fieldId) continue;

                            $value = $field['value'] ?? null;

                            if($value === '' || $value === null){
                                return '0';
                            }

                            return is_numeric($value)
                                ? (string)$value
                                : "'" . str_replace("'", "''", (string)$value) . "'";
                        }

                        return '0';
                    },
                    $sql
                ) ?? $sql;

                $taskResult = null;

                // ───── 2️⃣ Handle SET commands ──────────────────────────
                if(stripos(trim($sql), 'SET') === 0){
                    $parts = preg_split('/\s+/', $sql, 4);

                    if($parts === false || count($parts) < 2){
                        throw new RuntimeException('Invalid SET command.');
                    }

                    $property = ltrim($parts[1], '@');

                    if(count($parts) === 4){
                        $newValue = trim($parts[3], "'\"");
                        $taskResult = $newValue;
                    }
                    else{
                        $equalsPosition = strpos($sql, '=');

                        if($equalsPosition === false){
                            throw new RuntimeException('Invalid SET command: missing "=".');
                        }

                        $valueSql = trim(substr($sql, $equalsPosition + 1));
                        $rows = $this->_executeSql($valueSql, $customer, $isPhp);
                        $newValue = (is_array($rows) && count($rows) > 0 && is_array($rows[0]))
                            ? reset($rows[0])
                            : null;
                        $taskResult = $newValue;
                    }

                    foreach($data as &$field){
                        if(!is_array($field)) continue;

                        if(($field['id'] ?? null) === $id){
                            $field[$property] = $taskResult;
                            break;
                        }
                    }
                    unset($field);
                }

                // ───── 3️⃣ Non-SET queries ──────────────────────────────
                else{
                    $rows = $this->_executeSql($sql, $customer, $isPhp);
                    $taskResult = $rows ?: [];

                    foreach($data as &$field){
                        if(!is_array($field)) continue;

                        if(($field['id'] ?? null) === $id){
                            $field['lookup_data'] = $taskResult;

                            // Auto-fill value for select/search
                            if(
                                isset($field['input_field']) &&
                                in_array($field['input_field'], ['select', 'search'], true) &&
                                is_array($taskResult)
                            ){
                                foreach($taskResult as $opt){
                                    if(
                                        is_array($opt) &&
                                        isset($opt['selected']) &&
                                        $opt['selected'] == '1'
                                    ){
                                        $field['value'] = $opt['id'] ?? null;
                                        break;
                                    }
                                }
                            }

                            break;
                        }
                    }
                    unset($field);
                }

                // Debug info
                $debugTask = $task;
                $debugTask['finalSQL'] = $sql;
                $debugTask['result'] = $taskResult;
                $debugTasks[] = $debugTask;
            }
            catch(Throwable $e){
                $log(
                    'EXCEPTION id=' .
                    ($task['id'] ?? 'unknown') .
                    ' msg=' .
                    (preg_replace('/\s+/', ' ', $e->getMessage()) ?? $e->getMessage())
                );

                $cleanMessage = preg_replace('/\[.*?\]/', '', $e->getMessage()) ?? $e->getMessage();
                $message = trim(strip_tags($cleanMessage));

                $originalSql = (string)($task['lookup_data'] ?? '');
                preg_match_all('/\[([^\]]+)\]/', $originalSql, $placeholders);

                $missing = [];

                foreach($placeholders[1] ?? [] as $phId){
                    $found = array_filter(
                        $data,
                        static fn($field) =>
                            is_array($field) &&
                            ($field['id'] ?? null) === $phId
                    );

                    if(empty($found)){
                        $missing[] = $phId;
                    }
                }

                $errors[] = [
                    'id' => $task['id'] ?? null,
                    'message' => $message,
                    'originalSQL' => $originalSql,
                    'finalSQL' => $sql ?? '',
                    'missingIds' => $missing
                ];
            }
        }

        // ───── 4️⃣ Normalize ────────────────────────────────────────────
        foreach($data as &$field){
            if(!is_array($field)) continue;

            if(array_key_exists('value', $field) && $field['value'] === null){
                $field['value'] = '';
            }

            if(isset($field['lookup_data']) && is_array($field['lookup_data'])){
                if(
                    count($field['lookup_data']) === 1 &&
                    isset($field['lookup_data'][0]['id']) &&
                    (
                        $field['lookup_data'][0]['id'] == '0' ||
                        $field['lookup_data'][0]['id'] == ''
                    )
                ){
                    $field['lookup_data'] = [];
                }
            }
        }
        unset($field);

        // Build lookupDatas map
        $lookupDatas = [];

        foreach($data as $field){
            if(!is_array($field)) continue;

            if(
                isset($field['id']) &&
                isset($field['lookup_data']) &&
                is_array($field['lookup_data'])
            ){
                $lookupDatas[$field['id']] = $field['lookup_data'];
            }
        }

        // ───── LOG: END ─────────────────────────────────────────────────
        $duration = round(microtime(true) - $logStart, 3);

        $log(sprintf(
            'END duration=%ss errors=%d mem=%sMB',
            number_format($duration, 3, '.', ''),
            count($errors),
            number_format(memory_get_peak_usage(true) / (1024 * 1024), 2)
        ));
        // ────────────────────────────────────────────────────────────────

        $this->result = [
            'data' => $data,
            'lookupDatas' => $lookupDatas,
            'errors' => $errors,
            'tasks' => $debugTasks
        ];
    }

    // ---------- <Methods [2]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _executeSql(string $sql, string $customer, bool $isPhp): mixed{
        if($isPhp){
            $url =
                'https://app.mosaic.hu/sql/ExternalInputChangeSQL.php?ceg=' .
                urlencode($customer) .
                '&SQL=' .
                urlencode($sql);

            $json = file_get_contents($url);

            if($json === false){
                throw new RuntimeException('ExternalInputChangeSQL.php could not be reached.');
            }

            return json_decode($json, true, 512, JSON_THROW_ON_ERROR);
        }

        $databaseManager = new DatabaseManager(
            $sql,
            [],
            $customer
        );

        return $databaseManager->getData();
    }
}

$task_multiple_tasks_at_once = new Task();
echo json_encode($task_multiple_tasks_at_once->getResult());