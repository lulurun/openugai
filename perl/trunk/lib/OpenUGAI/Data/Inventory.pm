package OpenUGAI::Data::Inventory;

use strict;
use OpenUGAI::DBData;
use OpenUGAI::Util;

our %SQL = (
    save_inventory_folder =>
    "REPLACE INTO inventoryfolders VALUES (?,?,?,?,?,?)",
    save_inventory_item =>
    "REPLACE INTO inventoryitems VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
    get_root_folder =>
    "SELECT * FROM inventoryfolders WHERE parentFolderID=? AND agentId=?",
    #"SELECT * FROM inventoryfolders WHERE agentId=?",
    get_children_folders =>
    "SELECT * FROM inventoryfolders WHERE parentFolderID=?",
    get_user_inventory_folders =>
    "SELECT * FROM inventoryfolders WHERE agentID=?",
    get_user_inventory_items =>
    "SELECT * FROM inventoryitems WHERE avatarID=?",
    delete_inventory_item =>
    "DELETE FROM inventoryitems WHERE inventoryID=?",
    move_inventory_folder =>
    "UPDATE inventoryfolders SET parentFolderID=? WHERE folderID=?",
    purge__delete_items =>
    "DELETE FROM inventoryitems WHERE parentFolderID=?",
    purge__delete_folders =>
    "DELETE FROM inventoryfolders WHERE parentFolderID=?",
    );


our @INVENTORYFOLDERS_COLUMNS = (
    "folderName",
    "type",
    "version",
    "folderID",
    "agentID",
    "parentFolderID",
    );

our @INVENTORYITEMS_COLUMNS = (
    "assetID",
    "assetType",
    "inventoryName",
    "inventoryDescription",
    "inventoryNextPermissions",
    "inventoryCurrentPermissions",
    "invType",
    "creatorID",
    "inventoryBasePermissions",
    "inventoryEveryOnePermissions",
    "salePrice",
    "saleType",
    "creationDate",
    "groupID",
    "groupOwned",
    "flags",
    "inventoryID",
    "avatarID",
    "parentFolderID",
    "inventoryGroupPermissions",
);

sub saveInventoryFolder {
    my $folder = shift;
    my @args;
    foreach(@INVENTORYFOLDERS_COLUMNS) {
	push @args, $folder->{$_};
    }
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{save_inventory_folder}, \@args);
    return $res;
}

sub saveInventoryItem {
    my $item = shift;
    my @args;
    foreach(@INVENTORYITEMS_COLUMNS) {
	push @args, $item->{$_};
    }
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{save_inventory_item}, \@args);
    return $res;
}

sub getRootFolder {
    my $agent_id = shift;
    my @args = ( &OpenUGAI::Util::ZeroUUID(), $agent_id );
    #my @args = ( $agent_id );
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{get_root_folder}, \@args);
    my $count = @$res;
    if ($count > 0) {
	return $res->[0];
    }
    return undef;
}

sub getChildrenFolders {
    my $parent_id = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{get_children_folders}, $parent_id);
    return $res;
}

sub getUserInventoryFolders {
    my $agent_id = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{get_user_inventory_folders}, $agent_id);
    return $res;
}

sub getUserInventoryItems {
    my $agent_id = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{get_user_inventory_items}, $agent_id);
    return $res;
}

sub deleteInventoryItem {
    my $item_id = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{delete_inventory_item}, $item_id);
    return $res;
}

use Data::Dump;
sub purgeInventoryFolder {
    my $info = shift;
    &OpenUGAI::Util::Log("test", "purge_req", Data::Dump::dump($info));

    my @args = (
	$info->{ID}->{Guid}, # TODO: not good UUID should be extracted in the higher level
	);
    &OpenUGAI::DBData::getSimpleResult($SQL{purge__delete_items}, \@args);
}



1;

