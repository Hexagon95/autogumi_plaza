<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'altered_database_managers/dm_save_eseti_munkalap.php';
include 'tasks/task_save_abroncs_igenyles.php';

$taskSaveAbroncsIgenyles = new Task();
echo json_encode($taskSaveAbroncsIgenyles->getResult());