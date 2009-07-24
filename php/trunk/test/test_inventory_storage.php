<?php

require_once "general.inc";
require_once "../lib/Inventory.php";
require_once "../lib/InventoryXMLSerializer.php";
require_once "../lib/InventoryMySQLStorage.php";

$host = "192.168.20.150";
$user = "opensim";
$pass = "1u1urun";
$db = "opensim_3di";

$success = true;

$storage = new InventoryMySQLStorage($host, $user, $pass, $db);

$new_root_folder_id = Util::CreateUUID();
$new_folder_id = Util::CreateUUID();
$new_user_id = Util::CreateUUID();

{
	$folder = new InventoryFolder();
	$folder->folderName = "openugai-test-root";
	$folder->type = 0;
	$folder->version = 1;
	$folder->folderID = $new_root_folder_id;
	$folder->agentID = $new_user_id;
	$folder->parentFolderID = Util::ZeroUUID();
	$storage->save($folder);
}
{
	$folder = new InventoryFolder();
	$folder->folderName = "openugai-test-child1";
	$folder->type = 5;
	$folder->version = 1;
	$folder->folderID = $new_folder_id;
	$folder->agentID = $new_user_id;
	$folder->parentFolderID = $new_root_folder_id;
	$storage->save($folder);
}

$root_folder = $storage->getRootFolder($new_user_id);
if (!isset($root_folder) || $root_folder->folderID != $new_root_folder_id) {
	echo "Failed! getRootFolder\n";
	$success = false;
	exit;
}

$folders = $storage->getUserFolders($new_user_id);
if (!isset($folders) || count($folders) != 2) {
	echo "Failed! getUserFolders\n";
	$success = false;
	exit;
}

$folders = $storage->getChildrenFolders($new_root_folder_id);
if (!isset($folders) || count($folders) != 1) {
	echo "Failed! getChildrenFolders\n";
	$success = false;
	exit;
}

$storage->delete($new_folder_id);
$storage->delete($new_root_folder_id);

if ($success) {
	echo "OK\n";
}

?>
