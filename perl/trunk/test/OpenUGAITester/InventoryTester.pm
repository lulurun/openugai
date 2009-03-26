package InventoryTester;

use strict;
use XML::Serializer;
use OpenUGAI::Util;

sub init {
	&OpenUGAITester::Config::registerHandler("create_inventory", \&_create_inventory);
	&OpenUGAITester::Config::registerHandler("root_folders", \&_root_folders);
	&OpenUGAITester::Config::registerHandler("get_inventory", \&_get_inventory);
	&OpenUGAITester::Config::registerHandler("new_item", \&_new_item);
	&OpenUGAITester::Config::registerHandler("new_folder", \&_new_folder);
}

sub _apache_flag {
	my $url = shift;
	return $url =~ /inventory.cgi/ ? 1 : 0;
}

sub _new_folder {
	my $url = shift || $OpenUGAITester::Config::INVENTORY_SERVER_URL;
	my $post_data =<<"POSTDATA";
<InventoryFolderBase>
<name>New Folder</name>
	<agentID>
<UUID>b9cb58e8-f3c9-4af5-be47-029762baa68f</UUID>
</agentID>
	<parentID>
<UUID>500ea141-2967-49e2-9e18-fcdedffe68df</UUID>
</parentID>
	<folderID>
<UUID>aa6f9220-c945-0b23-6141-43c9ef734100</UUID>
</folderID>
<type>-1</type>
<version>0</version>
</InventoryFolderBase>
POSTDATA
	if (&_apache_flag($url)) {
		$post_data = "POSTDATA=" . $post_data; # TODO: bad temporary solution
	}
	my $res = &OpenUGAI::Util::HttpRequest("POST",$url . "/NewFolder/", $post_data) . "\n";
}

sub _new_item {
	my $url = shift || $OpenUGAITester::Config::INVENTORY_SERVER_URL;
	my $post_data =<<"POSTDATA";
<InventoryItemBase>
	<inventoryID>
<UUID>f975d038-3bd7-4e8b-a945-f46b0c962ee3</UUID>
</inventoryID>
	<assetID>
<UUID>5f50f162-1cc6-4907-99be-a4c81d7f5e10</UUID>
</assetID>
<assetType>6</assetType>
<invType>6</invType>
	<parentFolderID>
<UUID>7018dc23-43a9-493f-b3f7-869a6bbad0f3</UUID>
</parentFolderID>
	<avatarID>
<UUID>b9cb58e8-f3c9-4af5-be47-029762baa68f</UUID>
</avatarID>
	<creatorsID>
<UUID>b9cb58e8-f3c9-4af5-be47-029762baa68f</UUID>
</creatorsID>
<inventoryName>Primitive</inventoryName>
<inventoryDescription/>
<inventoryNextPermissions>2147483647</inventoryNextPermissions>
<inventoryCurrentPermissions>526053692</inventoryCurrentPermissions>
<inventoryBasePermissions>2147483647</inventoryBasePermissions>
<inventoryEveryOnePermissions>0</inventoryEveryOnePermissions>
</InventoryItemBase>
POSTDATA
	if (&_apache_flag($url)) {
		$post_data = "POSTDATA=" . $post_data;
	}
	my $res = &OpenUGAI::Util::HttpRequest("POST", $url . "/NewItem/", $post_data) . "\n";
}

sub _get_inventory {
	my $url = shift || $OpenUGAITester::Config::INVENTORY_SERVER_URL;
	my $uuid = shift;
	my %req_obj = (
	    Body => $uuid,
	);
	my $serializer = new XML::Serializer("RestSessionObjectOfGuid", \%req_obj);
	my $post_data = $serializer->to_string(XML::Serializer::WITH_HEADER);
	my $res = &OpenUGAI::Util::HttpRequest("POST", $url . "/GetInventory/", $post_data) . "\n";
	my $res_obj = &OpenUGAI::Util::XML2Obj($res);
	return $res_obj;
}

sub _create_inventory {
	my $url = shift || $OpenUGAITester::Config::INVENTORY_SERVER_URL;
	my $uuid = shift;
	my $serializer = new XML::Serializer("guid", $uuid);
	my $post_data = $serializer->to_string(XML::Serializer::WITH_HEADER);
	my $res = &OpenUGAI::Util::HttpRequest("POST", $url . "/CreateInventory/", $post_data) . "\n";
	return 1;
}

sub _root_folders {
	my $url = shift || $OpenUGAITester::Config::INVENTORY_SERVER_URL;
	my $uuid = shift;
	my $serializer = new XML::Serializer("guid", $uuid);
	my $post_data = $serializer->to_string(XML::Serializer::WITH_HEADER);
	print $post_data . "\n\n";
	my $res = &OpenUGAI::Util::HttpRequest("POST", $url . "/RootFolders/", $post_data) . "\n";
	return $res;
}

1;

