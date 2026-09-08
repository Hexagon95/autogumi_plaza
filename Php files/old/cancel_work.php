<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_cancel_work.php';
include 'tasks/task_cancel_work.php';

$task_cancelWork = new Task();
echo json_encode($task_cancelWork->getResult());