<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_worksheet.php';
include 'tasks/task_worksheet.php';

$taskWorksheet = new Task();
echo json_encode($taskWorksheet->getResult());