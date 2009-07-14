<?php

require_once "general.inc";

$host = "192.168.20.150";
$user = "opensim";
$pass = "1u1urun";
$db = "opensim_3di";

// connect
$storage = new AssetMySQLStorage($host, $user, $pass, $db);

$asset_server = new AssetServer($storage);
$asset_server->run("GET", "/assets/00000000-0000-0000-0000-000000000000");

?>

