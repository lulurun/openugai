<?php

require_once "general.inc";
require_once "../lib/Inventory.php";
require_once "../lib/InventoryXMLSerializer.php";

$folder_array = array();
for($i=0; $i<5; $i++) { 
	$folder = new InventoryFolder();
	array_push($folder_array, $folder);
}

echo InventoryFolderXMLSerializer::serialize($folder_array);
echo "";

?>

