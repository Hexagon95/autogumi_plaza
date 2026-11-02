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

$requestData = json_decode(file_get_contents('php://input'), true);
$requestData = is_array($requestData)? $requestData : [];

$requestDataParams = json_decode($requestData['parameter'] ?? '', true);
$requestDataParams = is_array($requestDataParams)? $requestDataParams : [];

$bizonylatID = $requestDataParams['id'] ?? 0;

$kepFile = base64_decode($requestDataParams['kep'] ?? '', true);
$kepFileName = randomName(20);
$kepFileKonyvtar = 'documents/' . ($requestData['customer'] ?? '');

$mit = ["☀️", "❄️", "🌦️", "🛞"];
$mire = ["", "", "", ""];
$requestDataParams['pozicio'] = str_replace(
    $mit,
    $mire,
    $requestDataParams['pozicio'] ?? ''
);

$bizonylatDokumentumParams = [
    'bizonylat_id' => $bizonylatID,
    'files' => [
        'id' => 0,
        'konyvtar' => $kepFileKonyvtar,
        'megnevezes' => $kepFileName . '.jpg',
        'name' => 'IMG_' . $requestDataParams['pozicio'] . '_' . date('YmdHis')
    ],
    'user_id' => $requestData['user_id'] ?? 0
];

$kepFileFullKonyvtar = __DIR__ . '/../../../appdoc/' . $kepFileKonyvtar;
$kepFileFullPath = $kepFileFullKonyvtar . '/' . $kepFileName . '.jpg';

if(!is_dir($kepFileFullKonyvtar)){
    mkdir($kepFileFullKonyvtar, 0777, true);
}

if($kepFile !== false){
    file_put_contents($kepFileFullPath, $kepFile);
}

$taskPhotoSave = new Task(
    $bizonylatDokumentumParams,
    $requestData['customer'] ?? 'mosaic'
);

echo json_encode($taskPhotoSave->getResult());