package OpenUGAI::InventoryServer;

use strict;
use Carp;
use XML::Serializer;
use OpenUGAI::Utility;
use OpenUGAI::Config;
use OpenUGAI::InventoryServer::Config;
use OpenUGAI::InventoryServer::InventoryManager;

sub getHandlerList {
    my %list = (
	"GetInventory" => \&_get_inventory,
	"CreateInventory" => \&_create_inventory,
	"NewFolder" => \&_new_folder,
	"MoveFolder" => \&_move_folder,
	"NewItem" => \&_new_item,
	"DeleteItem" => \&_delete_item,
	"RootFolders" => \&_root_folders,
	);
    return \%list;
}

# #################
# Handlers
sub _get_inventory {
    my $post_data = shift;
    my $uuid = &_get_uuid($post_data);
    my $inventry_folders = &OpenUGAI::InventoryServer::InventoryManager::getUserInventoryFolders($uuid);
    my @response_folders = ();
    foreach (@$inventry_folders) {
	my $folder = &_convert_to_response_folder($_);
	push @response_folders, $folder;
    }
    my $inventry_items = &OpenUGAI::InventoryServer::InventoryManager::getUserInventoryItems($uuid);
    my @response_items = ();
    foreach (@$inventry_items) {
	my $item = &_convert_to_response_item($_);
	push @response_items, $item;
    }
    my $response_obj = { # TODO much duplicated data ***
	_folders => { InventoryFolderBase => \@response_folders },
	_allItems => { InventoryItemBase => \@response_items },
	_userID => { UUID => $uuid },
	Folders => { InventoryFolderBase => \@response_folders },
	AllItems => { InventoryItemBase => \@response_items },
	UserID => { UUID => $uuid },
	Items => { InventoryItemBase => \@response_items },
    };
    my $serializer = new XML::Serializer( $response_obj, "InventoryCollection");
    return $serializer->to_formatted(XML::Serializer::WITH_HEADER); # TODO:
}

sub _create_inventory {
    my $post_data = shift;
    my $uuid = &_get_uuid($post_data);
    my $InventoryFolders = &_create_default_inventory($uuid);
    foreach (@$InventoryFolders) {
	&OpenUGAI::InventoryServer::InventoryManager::saveInventoryFolder($_);
    }
    my $serializer = new XML::Serializer("true", "boolean");
    return $serializer->to_formatted(XML::Serializer::WITH_HEADER); # TODO:
}

sub _new_folder {
    my $post_data = shift;
    my $request_obj = &OpenUGAI::Utility::XML2Obj($post_data);
    my $folder = &_convert_to_db_folder($request_obj);
    &OpenUGAI::InventoryServer::InventoryManager::saveInventoryFolder($folder);
    my $serializer = new XML::Serializer("true", "boolean");
    return $serializer->to_formatted(XML::Serializer::WITH_HEADER); # TODO:
}

sub _move_folder {
    my $post_data = shift;
    my $request_info = &OpenUGAI::Utility::XML2Obj($post_data);
    &OpenUGAI::InventoryServer::InventoryManager::moveInventoryFolder($request_info);
    my $serializer = new XML::Serializer("true", "boolean");
    return $serializer->to_formatted(XML::Serializer::WITH_HEADER); # TODO:
}

sub _new_item {
    my $post_data = shift;
    my $request_obj = &OpenUGAI::Utility::XML2Obj($post_data);
    my $item = &_convert_to_db_item($request_obj);
    &OpenUGAI::InventoryServer::InventoryManager::saveInventoryItem($item);
    my $serializer = new XML::Serializer("true", "boolean");
    return $serializer->to_formatted(XML::Serializer::WITH_HEADER); # TODO:
}

sub _delete_item {
    my $post_data = shift;
    my $request_obj = &OpenUGAI::Utility::XML2Obj($post_data);
    my $item_id = $request_obj->{ID}->{UUID};
    &OpenUGAI::InventoryServer::InventoryManager::deleteInventoryItem($item_id);
    my $serializer = new XML::Serializer("true", "boolean");
    return $serializer->to_formatted(XML::Serializer::WITH_HEADER); # TODO:
}

sub _root_folders {
    my $post_data = shift;
    my $uuid = &_get_uuid($post_data);
    my $response = undef;
    my $inventory_root_folder = &OpenUGAI::InventoryServer::InventoryManager::getRootFolder($uuid);
    if ($inventory_root_folder) {
	my $root_folder_id = $inventory_root_folder->{folderID};
	my $root_folder = &_convert_to_response_folder($inventory_root_folder);
	my $root_folders = &OpenUGAI::InventoryServer::InventoryManager::getChildrenFolders($root_folder_id);
	my @folders = ($root_folder);
	foreach(@$root_folders) {
	    my $folder = &_convert_to_response_folder($_);
	    push @folders, $folder;
	}
	$response = { InventoryFolderBase => \@folders };
    } else {
	$response = { InventoryFolderBase => &_create_default_inventory($uuid, 1) };
    }
    my $serializer = new XML::Serializer($response, "ArrayOfInventoryFolderBase");
    return $serializer->to_formatted(XML::Serializer::WITH_HEADER); # TODO:
}

# #################
# subfunctions
sub _convert_to_db_item {
    my $item = shift;
    my $ret = {
	inventoryID => $item->{ID}->{UUID},
	assetID => $item->{AssetID}->{UUID},
	assetType => $item->{AssetType},
	invType => $item->{InvType},
	parentFolderID => $item->{Folder}->{UUID},
	avatarID => $item->{Owner}->{UUID},
	creatorID => $item->{Creator}->{UUID},
	inventoryName => $item->{Name},
	inventoryDescription => ref($item->{Description}) ? "" : $item->{Description},
	inventoryNextPermissions => $item->{NextPermissions},
	inventoryCurrentPermissions => $item->{CurrentPermissions},
	inventoryBasePermissions => $item->{BasePermissions},
	inventoryEveryOnePermissions => $item->{EveryOnePermissions},
    };
    return $ret;
}

sub _convert_to_response_item {
    my $item = shift;
    my $ret = {
	ID => { UUID => $item->{inventoryID} },
	AssetID => { UUID => $item->{assetID} },
	AssetType => $item->{assetType},
	InvType => $item->{invType},
	Folder => { UUID => $item->{parentFolderID} },
	Owner => { UUID => $item->{avatarID} },
	Creator => { UUID => $item->{creatorID} },
	Name => $item->{inventoryName},
	Description => $item->{inventoryDescription} || "",
	NextPermissions => $item->{inventoryNextPermissions},
	CurrentPermissions => $item->{inventoryCurrentPermissions},
	BasePermissions => $item->{inventoryBasePermissions},
	EveryOnePermissions => $item->{inventoryEveryOnePermissions},
    };
    return $ret;
}

sub _convert_to_db_folder {
    my $folder = shift;
    my $ret = {
	folderName => $folder->{Name},
	agentID => $folder->{Owner}->{UUID},
	parentFolderID => $folder->{ParentID}->{UUID},
	folderID => $folder->{ID}->{UUID},
	type => $folder->{Type},
	version => $folder->{Version},
    };
    return $ret;
}

sub _convert_to_response_folder {
    my $folder = shift;
    my $ret = {
	Name => $folder->{folderName},
	Owner => { UUID => $folder->{agentID} },
	ParentID => { UUID => $folder->{parentFolderID} },
	ID => { UUID => $folder->{folderID} },
	Type => $folder->{type},
	Version => $folder->{version},
    };
    return $ret;
}

sub __create_folder_struct {
    my ($id, $owner, $parentid, $name, $type, $version) = @_;
    return {
	"Name" => $name,
	"Owner" => { UUID => $owner },
	"ParentID" => { UUID => $parentid },
	"ID" => { UUID => $id },
	"Type" => $type,
	"Version" => $version,
    };
}

sub _create_default_inventory {
    my ($uuid, $save_flag)= @_;
    $save_flag ||= 0;
    my @InventoryFolders = ();
    my $root_folder_id = &OpenUGAI::Utility::GenerateUUID();
    push @InventoryFolders, &__create_folder_struct($root_folder_id, $uuid, &OpenUGAI::Utility::ZeroUUID(), "My Inventory", 8, 1);
    push @InventoryFolders, &__create_folder_struct(&OpenUGAI::Utility::GenerateUUID(), $uuid, $root_folder_id, "Textures", 0, 1);
    push @InventoryFolders, &__create_folder_struct(&OpenUGAI::Utility::GenerateUUID(), $uuid, $root_folder_id, "Objects", 6, 1);
    push @InventoryFolders, &__create_folder_struct(&OpenUGAI::Utility::GenerateUUID(), $uuid, $root_folder_id, "Clothes", 5, 1);
    push @InventoryFolders, &__create_folder_struct(&OpenUGAI::Utility::GenerateUUID(), $uuid, $root_folder_id, "Bodyparts", 13, 1);
    if ($save_flag) {
	foreach(@InventoryFolders) {
	    &OpenUGAI::InventoryServer::InventoryManager::saveInventoryFolder(&_convert_to_db_folder($_));
	}
    }
    return \@InventoryFolders;
}


# #################
# Utilities
sub _get_uuid {
    my $data = shift;
    if ($data =~ /<guid\s*>([^<]+)<\/guid>/) {
	return $1;
    } else {
	Carp::croak("can not find uuid [$data]");
    }
}

1;

