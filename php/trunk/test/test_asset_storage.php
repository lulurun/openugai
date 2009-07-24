<?php

require_once "general.inc";

$host = "192.168.20.150";
$user = "opensim";
$pass = "1u1urun";
$db = "opensim_3di";

// connect
$storage = new AssetMySQLStorage($host, $user, $pass, $db);

// create new
$asset0 = create_asset();
$storage->save($asset0);

// select
$asset1 = $storage->fetch($asset0->id);
foreach ($asset1->getProps() as $prop) {
	if ($asset0->$prop !== $asset1->$prop) {
		echo "Check insert Failed: $prop\n";
		exit();
	}
}

// delete
if ($storage->delete($asset1) != 1) {
		echo "Check delete Failed: $prop\n";
		exit();
}

// select
$success = false;
try {
	$asset2 = $storage->fetch($asset0->id);
	if (!isset($asset2)) {
		$success = true;
	}
} catch (Exception $e) {
	echo "Check delete failed: " . $e->getMessage() . "\n";
}

if ($success) {
	echo "OK\n";
} else {
	echo "Failed\n";
}

// ======
function create_asset() {
	$asset = new Asset();
	$asset->name = "test_name";
	$asset->description = "test_description";
	$asset->assetType = 5;
	$asset->local = 1;
	$asset->temporary = 1;
	$asset->data = "test_data";
	$asset->id = Util::CreateUUID();
	$asset->create_time = 1000;
	$asset->access_time = 1001;
	return $asset;
}

// 
?>
