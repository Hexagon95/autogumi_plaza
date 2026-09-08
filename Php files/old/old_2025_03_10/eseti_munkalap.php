<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_eseti_munkalap.php';

$task_abroncs_igenyles = new Task();
echo json_encode($task_abroncs_igenyles->getResult());