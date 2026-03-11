<?php
header('Content-Type: application/json; charset=utf-8');
include 'sql_commands.php';
include 'database_manager.php';
include 'tasks/task_photo_sql.php';

$logPath = "../../logs/PhotoTemp_".date("YmdHis").".txt";

function randomName($number) {
    $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    $pass = array(); //remember to declare $pass as an array
    $alphaLength = strlen($alphabet) - 1; //put the length -1 in cache
    for ($i = 0; $i < $number; $i++) {
        $n = rand(0, $alphaLength);
        $pass[] = $alphabet[$n];
    }
    return implode($pass); //turn the array into a string
}

$RequestData = json_decode(file_get_contents('php://input'), true);
$RequestDataParams = json_decode($RequestData['parameter'],true);

$BizonylatID = $RequestDataParams['id'];

/*$logPath = "../../logs/PhotoTemp_".date("YmdHis").".txt";
file_put_contents($logPath, print_r($BizonylatID_Data, true), FILE_APPEND);
file_put_contents($logPath, $BizonylatID, FILE_APPEND);*/

$KepFile = base64_decode($RequestDataParams['kep']);
$KepFileName = randomName(20);
$KepFileKonyvtar = "documents/".$RequestData['customer'];

$BizonylatDokumentumParams = array(
    "bizonylat_id" => $BizonylatID,
    "files" => array(
        "id" => 0,
        "konyvtar" => $KepFileKonyvtar,
        "megnevezes" => $KepFileName.".jpg",
        "name" => "IMG_".$RequestDataParams['pozicio']."_".date("YmdHis")
    )
);


//file_put_contents($logPath, print_r($BizonylatDokumentumParams, true).chr(10), FILE_APPEND);

if (!is_dir("../../".$KepFileKonyvtar)) {
    mkdir("../../".$KepFileKonyvtar, 0777, true);
}

file_put_contents("../../".$KepFileKonyvtar."/".$KepFileName.".jpg", $KepFile);

$taskPhotoSave = new Task($BizonylatDokumentumParams, $RequestData['customer']);
echo json_encode($taskPhotoSave->getResult());