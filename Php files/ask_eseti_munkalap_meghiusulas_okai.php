<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_ask_eseti_munkalap_meghiusulas_okai.php';

$task_ask_eseti_munkalap_meghiusulas_okai = new Task();
echo json_encode($task_ask_eseti_munkalap_meghiusulas_okai->getResult());