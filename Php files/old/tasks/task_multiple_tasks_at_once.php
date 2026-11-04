<?php
class Task {
    private $result;
    public function getResult() {
        return $this->result;
    }

    public function __construct() {
        $this->_initialize();
    }

    private function _initialize() {       
        $request  = json_decode(file_get_contents('php://input'), true);
        $data     = $request['data'];
        $tasks    = $request['tasks'];
        $customer = $request['customer'];
        $errors   = [];
        $debugTasks = [];

        // ───── LOG: START ───────────────────────────────────────────────
        $___logStart = microtime(true);
        $___logDir   = __DIR__ . '/logs';
        if (!is_dir($___logDir)) { @mkdir($___logDir, 0775, true); }
        $___logFile  = $___logDir . '/task_multiple_tasks_at_once_log.txt';
        $___log = function(string $line) use ($___logFile) {
            @file_put_contents(
                $___logFile,
                '[' . date('Y-m-d H:i:s') . '] ' . $line . PHP_EOL,
                FILE_APPEND
            );
        };
        $___log(sprintf(
            'START customer=%s tasks=%d',
            (string)$customer,
            is_array($tasks) ? count($tasks) : 0
        ));
        // ────────────────────────────────────────────────────────────────

        foreach ($tasks as $task) {
            try {
                $sql      = $task['lookup_data'];
                $id       = $task['id'];
                $isPhp    = isset($task['php']) && $task['php'] == "1";
                $event    = $task['event'] ?? null;
                $newValue = $task['newValue'] ?? null;
                $isCheck  = isset($task['isCheckBox']) && $task['isCheckBox'];

                // ───── 0️⃣  Event filtering (checkbox logic) ─────────────
                if ($isCheck && $event) {
                    if (($event === "on"  && $newValue == "0") ||
                        ($event === "off" && $newValue == "1")) {
                        continue; // skip this task
                    }
                }

                // ───── 1️⃣  Placeholder replacement ─────────────
                $sql = preg_replace_callback('/\[([^\]]+)\]/', function ($matches) use ($data) {
                    $fieldId = $matches[1];
                    foreach ($data as $field) {
                        if ($field['id'] === $fieldId) {
                            $value = $field['value'];
                            if ($value === '' || $value === null) return '0';
                            return is_numeric($value)
                                ? $value
                                : "'" . str_replace("'", "''", $value) . "'";
                        }
                    }
                    return '0';
                }, $sql);

                $taskResult = null;

                // ───── 2️⃣  Handle SET commands ─────────────
                if (stripos(trim($sql), 'SET') === 0) {
                    $parts = preg_split('/\s+/', $sql, 4);
                    $property = ltrim($parts[1], '@');

                    if (count($parts) === 4) {
                        $newValue   = trim($parts[3], "'\"");
                        $taskResult = $newValue;
                    } else {
                        $valueSql = trim(substr($sql, strpos($sql, '=') + 1));
                        $rows     = $this->_executeSql($valueSql, $customer, $isPhp);
                        $newValue = ($rows && count($rows) > 0) ? reset($rows[0]) : null;
                        $taskResult = $newValue;
                    }

                    foreach ($data as &$field) {
                        if ($field['id'] === $id) {
                            $field[$property] = $taskResult;
                            break;
                        }
                    }
                }
                // ───── 3️⃣  Non-SET queries ─────────────
                else {
                    $rows       = $this->_executeSql($sql, $customer, $isPhp);
                    $taskResult = $rows ?: [];

                    foreach ($data as &$field) {
                        if ($field['id'] === $id) {
                            $field['lookup_data'] = $taskResult;

                            // auto-fill value for select/search
                            if (isset($field['input_field']) &&
                                in_array($field['input_field'], ['select','search']) &&
                                is_array($taskResult)
                            ) {
                                foreach ($taskResult as $opt) {
                                    if (isset($opt['selected']) && $opt['selected'] == "1") {
                                        $field['value'] = $opt['id'];
                                        break;
                                    }
                                }
                            }
                            break;
                        }
                    }
                }

                // Debug info
                $debugTask = $task;
                $debugTask['finalSQL'] = $sql;
                $debugTask['result']   = $taskResult;
                $debugTasks[] = $debugTask;

            } catch (Throwable $e) {
                if (isset($___log)) {
                    $___log('EXCEPTION id=' . ($task['id'] ?? 'unknown') . ' msg=' . preg_replace('/\s+/', ' ', $e->getMessage()));
                }
                $message = trim(strip_tags(preg_replace('/\[.*?\]/', '', $e->getMessage())));
                $originalSql = $task['lookup_data'];
                preg_match_all('/\[([^\]]+)\]/', $originalSql, $placeholders);
                $missing = [];
                foreach ($placeholders[1] as $phId) {
                    if (!array_filter($data, fn($field) => $field['id'] === $phId)) {
                        $missing[] = $phId;
                    }
                }
                $errors[] = [
                    'id'          => $task['id'],
                    'message'     => $message,
                    'originalSQL' => $originalSql,
                    'finalSQL'    => $sql ?? '',
                    'missingIds'  => $missing
                ];
            }
        }

        // ───── 4️⃣  Normalize ─────────────
        foreach ($data as &$field) {
            if (array_key_exists('value', $field) && is_null($field['value'])) {
                $field['value'] = '';
            }
            if (isset($field['lookup_data']) && is_array($field['lookup_data'])) {
                if (count($field['lookup_data']) === 1 &&
                    isset($field['lookup_data'][0]['id']) &&
                    ($field['lookup_data'][0]['id'] == "0" || $field['lookup_data'][0]['id'] == "")
                ) {
                    $field['lookup_data'] = [];
                }
            }
        }
        unset($field);

        // Build lookupDatas map
        $lookupDatas = [];
        foreach ($data as $field) {
            if (isset($field['lookup_data']) && is_array($field['lookup_data'])) {
                $lookupDatas[$field['id']] = $field['lookup_data'];
            }
        }

        // ───── LOG: END ─────────────────────────────────────────────────
        $___duration = round(microtime(true) - $___logStart, 3);
        $___log(sprintf(
            'END duration=%ss errors=%d mem=%sMB',
            number_format($___duration, 3, '.', ''),
            is_array($errors) ? count($errors) : 0,
            number_format(memory_get_peak_usage(true) / (1024*1024), 2)
        ));
        // ────────────────────────────────────────────────────────────────


        $this->result = [
            'data'        => $data,
            'lookupDatas' => $lookupDatas,
            'errors'      => $errors,
            'tasks'       => $debugTasks
        ];
    }

    // ───── Helper: SQL execution with isPhp ─────────────
    private function _executeSql($sql, $customer, $isPhp) {
        if ($isPhp) {
            // call ExternalInputChangeSQL.php
            $url = "https://app.mosaic.hu/sql/ExternalInputChangeSQL.php?ceg={$customer}&SQL=" . urlencode($sql);
            $json = file_get_contents($url);
            return json_decode($json, true);
        } else {
            $db = new DatabaseManager($sql, [], $customer);
            return $db->getData();
        }
    }
}

/*
class Task {
    // ---------- <Variables [1]> ----- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private $result;
    public function getResult() {
        return $this->result;
    }

    // ---------- <Constructors> ------ ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    public function __construct() {
        $this->_initialize();
    }

    // ---------- <Methods [1]> ------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
    private function _initialize() {
        $request  = json_decode(file_get_contents('php://input'), true);
        $data     = $request['data'];
        $tasks    = $request['tasks'];
        $customer = $request['customer'];
        $errors   = [];

        $debugTasks = []; // <-- for debugging

        foreach ($tasks as $task) {
            try {
                $sql = $task['lookup_data'];
                $id  = $task['id'];

                // Replace placeholders
                $sql = preg_replace_callback('/\[([^\]]+)\]/', function ($matches) use ($data) {
                    $fieldId = $matches[1];
                    if (stripos($fieldId, 'id_') === 0) {
                        foreach ($data as $field) {
                            if ($field['id'] === $fieldId) {
                                $value = $field['value'];
                                if ($value === '' || $value === null) return '0';
                                return is_numeric($value)
                                    ? $value
                                    : "'" . str_replace("'", "''", $value) . "'";
                            }
                        }
                        return '0';
                    }
                    return '[' . $fieldId . ']';
                }, $sql);

                $taskResult = null;

                if (stripos(trim($sql), 'SET') === 0) {
                    // Handle SET commands
                    $parts = preg_split('/\s+/', $sql, 4);
                    if (count($parts) === 4) {
                        $property = ltrim($parts[1], '@');
                        $newValue = trim($parts[3], "'\"");
                        $taskResult = $newValue;
                    } else {
                        $property = ltrim($parts[1], '@');
                        $valueSql = trim(substr($sql, strpos($sql, '=') + 1));

                        $db   = new DatabaseManager($valueSql, [], $customer);
                        $rows = $db->getData();
                        $newValue = ($rows && count($rows) > 0) ? reset($rows[0]) : null;
                        $taskResult = $newValue;
                    }

                    foreach ($data as &$field) {
                        if ($field['id'] === $id) {
                            $field[$property] = $taskResult;
                            break;
                        }
                    }
                } else {
                    // Non-SET query
                    $db   = new DatabaseManager($sql, [], $customer);
                    $rows = $db->getData();
                    $taskResult = $rows ?: [];

                    foreach ($data as &$field) {
                        if ($field['id'] === $id) {
                            $field['lookup_data'] = $taskResult;
                            break;
                        }
                    }
                }

                // add debugging info for this task
                $debugTask = $task;
                $debugTask['finalSQL'] = $sql;
                $debugTask['result']   = $taskResult;
                $debugTasks[] = $debugTask;

            } catch (Throwable $e) {
                $message = trim(strip_tags(preg_replace('/\[.*?\]/', '', $e->getMessage())));
                $originalSql = $task['lookup_data'];
                preg_match_all('/\[([^\]]+)\]/', $originalSql, $placeholders);
                $missing = [];
                foreach ($placeholders[1] as $phId) {
                    if (!array_filter($data, fn($field) => $field['id'] === $phId)) {
                        $missing[] = $phId;
                    }
                }
                $errors[] = [
                    'id'          => $task['id'],
                    'message'     => $message,
                    'originalSQL' => $originalSql,
                    'finalSQL'    => $sql,
                    'missingIds'  => $missing
                ];
            }
        }

        // Normalize value & empty lookup_data
        foreach ($data as &$field) {
            if (array_key_exists('value', $field) && is_null($field['value'])) {
                $field['value'] = '';
            }
            if (isset($field['lookup_data']) && is_array($field['lookup_data'])) {
                if (count($field['lookup_data']) === 1 &&
                    isset($field['lookup_data'][0]['id']) &&
                    ($field['lookup_data'][0]['id'] == "0" || $field['lookup_data'][0]['id'] == "")
                ) {
                    $field['lookup_data'] = [];
                }
            }
        }
        unset($field);

        // Build lookupDatas map
        $lookupDatas = [];
        foreach ($data as $field) {
            if (isset($field['lookup_data']) && is_array($field['lookup_data'])) {
                $lookupDatas[$field['id']] = $field['lookup_data'];
            }
        }

        // Final result with debug tasks
        $this->result = [
            'data'        => $data,
            'lookupDatas' => $lookupDatas,
            'errors'      => $errors,
            'tasks'       => $debugTasks // <-- full debug info
        ];
    }
}
*/