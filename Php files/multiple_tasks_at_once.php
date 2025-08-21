<?php
header('Content-Type: application/json; charset=utf-8');
include 'database_manager.php';
include 'tasks/task_multiple_tasks_at_once.php';

$task_multiple_tasks_at_once = new Task();
echo json_encode($task_multiple_tasks_at_once->getResult());