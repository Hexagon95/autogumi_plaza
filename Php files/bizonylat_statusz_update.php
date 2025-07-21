<?php
header('Content-Type: application/json; charset=utf-8');

// Includes
include 'sql_commands.php';
include 'database_manager.php';

// Grab GET parameters
$bizonylat_id = isset($_GET['id'])      ? $_GET['id']     : null;
$statusz_id   = isset($_GET['status'])  ? $_GET['status'] : null;
$user_id      = isset($_GET['user'])    ? $_GET['user']   : null;

// Validate
if (!$bizonylat_id || !$statusz_id || !$user_id) {
    echo json_encode(["error" => "Missing required parameters."]);
    exit;
}

// Prepare SQL & parameters
$sqlCommand = new SqlCommand();
$procedure = $sqlCommand->exec_bizonylatStatuszUpdate();

$parameters = [
    'bizonylat_id' => $bizonylat_id,
    'statusz_id'   => $statusz_id,
    'user_id'      => $user_id
];

// Execute using burned-in "mercarius" DB
$databaseManager = new DatabaseManager($procedure, $parameters, 'mercarius');
echo json_encode($databaseManager->getData());