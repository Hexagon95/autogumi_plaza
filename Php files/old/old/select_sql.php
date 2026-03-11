<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_select_sql.php';

$taskSelectSql = new Task();
echo json_encode(array(['result' => $taskSelectSql->getResult()]));