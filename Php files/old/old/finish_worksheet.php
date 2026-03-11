<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_finish_worksheet.php';
include 'tasks/task_finish_worksheet.php';

$taskFinishWorksheet = new Task();
echo json_encode($taskFinishWorksheet->getResult());