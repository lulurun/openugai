<?php

require_once "general.inc";

// create 0
$asset0 = new Asset();
$asset0->name = "test";
$asset0->id = Util::CreateUUID();

// serialize 0
$asset_xml0 = AssetXMLSerializer::serialize($asset0);

// deserialize 1
$asset1 = AssetXMLSerializer::deserialize($asset_xml0);

// serialize 1
$asset_xml1 = AssetXMLSerializer::serialize($asset1);

// compare
if ($asset_xml0 == $asset_xml1) {
	echo "OK\n";
} else {
	echo "Failed\n";
}

?>
