<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_ask_panel.php';

$task_ask_panel = new Task();
echo json_encode($task_ask_panel->getResult());