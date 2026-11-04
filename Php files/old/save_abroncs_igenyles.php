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
include 'altered_database_managers/dm_save_eseti_munkalap.php';
include 'tasks/task_save_abroncs_igenyles.php';

$taskSaveAbroncsIgenyles = new Task();
echo json_encode($taskSaveAbroncsIgenyles->getResult());