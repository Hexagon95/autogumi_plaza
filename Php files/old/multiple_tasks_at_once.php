<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
header('Content-Type: application/json; charset=utf-8');
include 'database_manager.php';
include 'tasks/task_multiple_tasks_at_once.php';

$task_multiple_tasks_at_once = new Task();
echo json_encode($task_multiple_tasks_at_once->getResult());