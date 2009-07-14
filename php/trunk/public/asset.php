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
$asset_server->run();

// ff7069c8-86b0-331f-fd81-3f5557c66c73

?>
