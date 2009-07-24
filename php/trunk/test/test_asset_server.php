<?php

require_once "general.inc";

$host = "192.168.20.150";
$user = "opensim";
$pass = "1u1urun";
$db = "opensim_3di";

// connect
$storage = new AssetMySQLStorage($host, $user, $pass, $db);

$asset_server = new AssetServer($storage);
$asset_server->init();
$asset_server->run("GET", "/assets/fd9ad83a-4921-4b6e-8b8e-558556d9f503");

?>

