package OpenUGAI::DBData::Inventory;

use strict;
use OpenUGAI::Util;

our %SQL = (
    save_inventory_folder =>
    "REPLACE INTO inventoryfolders VALUES (?,?,?,?,?,?)",
    save_inventory_item =>
    "REPLACE INTO inventoryitems VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
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
);

sub saveInventoryFolder {
    my $conn = shift;
    my $folder = shift;
    my @args;
    foreach(@INVENTORYFOLDERS_COLUMNS) {
	push @args, $folder->{$_};
    }
    return $conn->query($SQL{save_inventory_folder}, \@args);
}

sub saveInventoryItem {
    my $conn = shift;
    my $item = shift;
    my @args;
    foreach(@INVENTORYITEMS_COLUMNS) {
	push @args, $item->{$_};
    }
    return $conn->query($SQL{save_inventory_item}, \@args);
}

sub getRootFolder {
    my $conn = shift;
    my $agent_id = shift;
    my $res = $conn->query($SQL{get_root_folder}, [ &OpenUGAI::Util::ZeroUUID(), $agent_id ] );
    my $count = @$res;
    if ($count > 0) {
	return $res->[0];
    }
    return undef;
}

sub getChildrenFolders {
    my $conn = shift;
    my $parent_id = shift;
    return $conn->query($SQL{get_children_folders}, [ $parent_id ]);
}

sub getUserInventoryFolders {
    my $conn = shift;
    my $agent_id = shift;
    return $conn->query($SQL{get_user_inventory_folders}, [ $agent_id ]);
}

sub getUserInventoryItems {
    my $conn = shift;
    my $agent_id = shift;
    return $conn->query($SQL{get_user_inventory_items}, [ $agent_id ]);
}

sub deleteInventoryItem {
    my $conn = shift;
    my $item_id = shift;
    return $conn->query($SQL{delete_inventory_item}, [ $item_id ]);
}

sub purgeInventoryFolder {
    my $conn = shift;
    my $info = shift;
    my @args = (
		$info->{ID}->{Guid},
                # TODO: not good UUID should be extracted in the higher level
		);
    $conn->query($SQL{purge__delete_items}, \@args);
}



1;

