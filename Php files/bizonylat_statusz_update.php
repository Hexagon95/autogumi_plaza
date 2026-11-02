<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

if($_SERVER['REQUEST_METHOD'] === 'OPTIONS'){
    http_response_code(200);
    exit();
}

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/sql/sql_commands.php';
require_once __DIR__ . '/sql/database_manager.php';

// ---------- <GET Parameters> ---------------------------------------------------
$bizonylat_id = $_GET['id'] ?? null;
$statusz_id =   $_GET['status'] ?? null;
$user_id =      $_GET['user'] ?? null;

// ---------- <Validation> -------------------------------------------------------
if($bizonylat_id === null || $statusz_id === null || $user_id === null){
    echo json_encode([
        'error' => 'Missing required parameters.'
    ]);
    exit();
}

// ---------- <SQL> --------------------------------------------------------------
$sqlCommand = new SqlCommand();

$databaseManager = new DatabaseManager(
    $sqlCommand->exec_bizonylatStatuszUpdate(),
    [
        'bizonylat_id' => $bizonylat_id,
        'statusz_id' =>   $statusz_id,
        'user_id' =>      $user_id
    ],
    'mercarius'
);

echo json_encode($databaseManager->getData());