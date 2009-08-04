<?php

require_once "general.inc";

$host = "192.168.20.150";
$user = "opensim";
$pass = "1u1urun";
$db = "opensim_3di";

// connect
$storage = new InventoryMySQLStorage($host, $user, $pass, $db);

$server = new InventoryServer($storage);
$server->init();
$server->run();

?>
