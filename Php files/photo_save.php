<?php

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");

if($_SERVER['REQUEST_METHOD'] === 'OPTIONS'){
    http_response_code(200);
    exit();
}

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/sql/sql_commands.php';
require_once __DIR__ . '/sql/database_manager.php';
require_once __DIR__ . '/tasks/task_photo_sql.php';

function randomName(int $number): string{
    $alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    $result = '';
    $alphaLength = strlen($alphabet) - 1;

    for($i = 0; $i < $number; $i++){
        $result .= $alphabet[random_int(0, $alphaLength)];
    }

    return $result;
}

$decodedRequest = json_decode(file_get_contents('php://input'), true);
$requestData = is_array($decodedRequest)? $decodedRequest : [];

$decodedParams = json_decode($requestData['parameter'] ?? '', true);
$requestDataParams = is_array($decodedParams)? $decodedParams : [];

$task2BizonylatID = new Task2(
    intval($requestDataParams['id'] ?? 0),
    $requestData['customer'] ?? 'mosaic'
);

$bizonylatIDData = $task2BizonylatID->getResult();
$bizonylatID = $bizonylatIDData[0]['id'] ?? 0;

$kepFile = base64_decode($requestDataParams['kep'] ?? '');
$kepFileName = randomName(20);
$kepFileKonyvtar = 'documents/' . ($requestData['customer'] ?? '');

$bizonylatDokumentumParams = [
    'bizonylat_id' => $bizonylatID,
    'files' => [
        'id' => 0,
        'konyvtar' => $kepFileKonyvtar,
        'megnevezes' => $kepFileName . '.jpg',
        'name' => 'IMG_' . ($requestDataParams['pozicio'] ?? '') . '_' . date('YmdHis')
    ],
    'user_id' => $requestData['user_id'] ?? 0
];

$kepFileFullKonyvtar = __DIR__ . '/../../../appdoc/' . $kepFileKonyvtar;
$kepFileFullPath = $kepFileFullKonyvtar . '/' . $kepFileName . '.jpg';

if(!is_dir($kepFileFullKonyvtar)){
    mkdir($kepFileFullKonyvtar, 0777, true);
}

file_put_contents($kepFileFullPath, $kepFile);

$taskPhotoSave = new Task(
    $bizonylatDokumentumParams,
    $requestData['customer'] ?? 'mosaic'
);

echo json_encode($taskPhotoSave->getResult());