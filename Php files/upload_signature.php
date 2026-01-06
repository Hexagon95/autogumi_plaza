<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_upload_signature.php';
try {
    $task = new Task();
    echo json_encode([
        "ok" => true,
        "data" => $task->getResult(),
    ]);
} catch (Throwable $e) {
    http_response_code(500);
    echo json_encode([
        "ok" => false,
        "error" => $e->getMessage(),
    ]);
}
