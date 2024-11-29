<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_login.php';

$taskLogin = new Task();
echo json_encode($taskLogin->getResult());