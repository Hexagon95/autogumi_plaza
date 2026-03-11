<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_ask_incomplete_days.php';

$taskAskIncompleteDays = new Task();
echo json_encode($taskAskIncompleteDays->getResult());