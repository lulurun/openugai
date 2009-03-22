package OpenUGAI::InventoryServer;

use strict;
use Carp;
use DBHandler;
use OpenUGAI::Util;
use OpenUGAI::RestService;
our @ISA = qw(OpenUGAI::RestService);
use OpenUGAI::DBData::Inventory;
use XML::Serializer;

our $dbh;

sub init {
    my $this = shift;
    # init db
    my $db_info = {
	dsn => $OpenUGAI::Global::DSN,
	user => $OpenUGAI::Global::DBUSER,
	pass => $OpenUGAI::Global::DBPASS,
    };
    $dbh = new DBHandler($db_info);
    # register handlers # not really restful
    $this->registerHandler( "POST", qr{GetInventory} => \&_get_inventory);
    $this->registerHandler( "POST", qr{CreateInventory} => \&_create_inventory);
    $this->registerHandler( "POST", qr{NewFolder} => \&_new_folder);
    $this->registerHandler( "POST", qr{MoveFolder} => \&_move_folder);
    $this->registerHandler( "POST", qr{NewItem} => \&_new_item);
    $this->registerHandler( "POST", qr{DeleteItem} => \&_delete_item);
    $this->registerHandler( "POST", qr{RootFolders} => \&_root_folders);
    $this->registerHandler( "POST", qr{UpdateFolder} => \&_update_folder);
    $this->registerHandler( "POST", qr{PurgeFolder} => \&_purge_folder);
    &OpenUGAI::Util::Log("invnetory", "init", "OK");
}

# #################
# Handlers
sub _get_inventory {
    my $path = shift;
    my $cgi = shift;
    my $postdata = $cgi->param("POSTDATA");
    my $request_obj = &OpenUGAI::Util::XML2Obj($postdata);
    &OpenUGAI::Util::Log("inventory", "get_inventory_request", $request_obj);

    # secure inventory, but do nothing for now
    #&_validate_session($request_obj);

    my $uuid = $request_obj->{Body};
    my $inventry_folders = &OpenUGAI::DBData::Inventory::getUserInventoryFolders($dbh, $uuid);
    my @response_folders = ();
    foreach (@$inventry_folders) {
	my $folder = &_convert_to_response_folder($_);
	push @response_folders, $folder;
    }
    my $inventry_items = &OpenUGAI::DBData::Inventory::getUserInventoryItems($dbh, $uuid);
    my @response_items = ();
    foreach (@$inventry_items) {
	my $item = &_convert_to_response_item($_);
	push @response_items, $item;
    }
    my $response_obj = { # TODO much duplicated data ***
	Folders => { InventoryFolderBase => \@response_folders },
	UserID => { Guid => $uuid },
	Items => { InventoryItemBase => \@response_items },
    };
    &_output_response($cgi, $response_obj, "InventoryCollection");
}

sub _create_inventory {
    my $path = shift;
    my $cgi = shift;
    my $postdata = $cgi->param("POSTDATA");
    my $uuid = &_get_uuid($postdata);
    my $InventoryFolders = &_create_default_inventory($uuid);
    foreach (@$InventoryFolders) {
	&OpenUGAI::Data::Inventory::saveInventoryFolder($_);
    }
    &_output_response($cgi, "true", "boolean");
}

sub _update_folder {
    my $path = shift;
    my $cgi = shift;
    my $postdata = $cgi->param("POSTDATA");
    my $request_obj = &OpenUGAI::Util::XML2Obj($postdata);
    my $folder = &_convert_to_db_folder($request_obj->{Body});
    &OpenUGAI::Data::Inventory::saveInventoryFolder($folder);
    &_output_response($cgi, "true", "boolean");
}

sub _new_folder {
    my $path = shift;
    my $cgi = shift;
    my $postdata = $cgi->param("POSTDATA");
    my $request_obj = &OpenUGAI::Util::XML2Obj($postdata);
    my $folder = &_convert_to_db_folder($request_obj->{Body});
    &OpenUGAI::Data::Inventory::saveInventoryFolder($folder);
    &_output_response($cgi, "true", "boolean");
}

sub _move_folder {
    my $path = shift;
    my $cgi = shift;
    my $postdata = $cgi->param("POSTDATA");
    my $request_obj = &OpenUGAI::Util::XML2Obj($postdata);
    &OpenUGAI::Data::Inventory::moveInventoryFolder($request_obj->{Body});
    &_output_response($cgi, "true", "boolean");
}

sub _purge_folder {
    my $path = shift;
    my $cgi = shift;
    my $postdata = $cgi->param("POSTDATA");
    my $request_obj = &OpenUGAI::Util::XML2Obj($postdata);
    &OpenUGAI::Data::Inventory::purgeInventoryFolder($request_obj->{Body});
    &_output_response($cgi, "true", "boolean");
}

sub _new_item {
    my $path = shift;
    my $cgi = shift;
    my $postdata = $cgi->param("POSTDATA");

    my $request_obj = &OpenUGAI::Util::XML2Obj($postdata);
    my $item = &_convert_to_db_item($request_obj->{Body});
    &OpenUGAI::Data::Inventory::saveInventoryItem($item);
    &_output_response($cgi, "true", "boolean");
}

sub _delete_item {
    my $path = shift;
    my $cgi = shift;
    my $postdata = $cgi->param("POSTDATA");
    my $request_obj = &OpenUGAI::Util::XML2Obj($postdata);
    my $item = $request_obj->{Body};
    my $item_id = $item->{ID}->{Guid};
    &OpenUGAI::Data::Inventory::deleteInventoryItem($item_id);
    &_output_response($cgi, "true", "boolean");
}

sub _root_folders {
    my $path = shift;
    my $cgi = shift;
    my $postdata = $cgi->param("POSTDATA");
    my $uuid = &_get_uuid($postdata);
    my $response = undef;
    my $inventory_root_folder = &OpenUGAI::DBData::Inventory::getRootFolder($dbh, $uuid);
    if ($inventory_root_folder) {
	my $root_folder_id = $inventory_root_folder->{folderID};
	my $root_folder = &_convert_to_response_folder($inventory_root_folder);
	my $root_folders = &OpenUGAI::DBData::Inventory::getChildrenFolders($dbh, $root_folder_id);
	my @folders = ($root_folder);
	foreach(@$root_folders) {
	    my $folder = &_convert_to_response_folder($_);
	    push @folders, $folder;
	}
	$response = { InventoryFolderBase => \@folders };
    } else {
	$response = { InventoryFolderBase => &_create_default_inventory($uuid, 1) };
    }
    &_output_response($cgi, $response, "ArrayOfInventoryFolderBase");
}

# #################
# subfunctions
sub _output_response {
    my ($cgi, $response, $node) = @_;
    my $serializer = new XML::Serializer($response, $node);
    print $cgi->header( -type => 'text/xml', -charset => "utf-8" );
    print $serializer->to_formatted(XML::Serializer::WITH_HEADER);
}

sub _convert_to_db_item {
    my $item = shift;
    my $ret = {
	assetID => $item->{AssetID}->{Guid},
	assetType => $item->{AssetType},
	inventoryName => $item->{Name},
	inventoryDescription => ref($item->{Description}) ? "" : $item->{Description},
	inventoryNextPermissions => $item->{NextPermissions},
	inventoryCurrentPermissions => $item->{CurrentPermissions},
	invType => $item->{InvType},
	creatorID => $item->{Creator}->{Guid},
	inventoryBasePermissions => $item->{BasePermissions} || 0,
	inventoryEveryOnePermissions => $item->{EveryOnePermissions} || 0,
	"salePrice" => 0,
	"saleType" => 0,
	"creationDate" => time,
	"groupID" => "00000000-0000-0000-0000-000000000000",
	"groupOwned" => 0,
	"flags" => 0,
	inventoryID => $item->{ID}->{Guid}, # TODO @@@ this can not be null
	avatarID => $item->{Owner}->{Guid},
	parentFolderID => $item->{Folder}->{Guid},
    };
    return $ret;
}

sub _convert_to_response_item {
    my $item = shift;
    my $ret = {
	ID => { Guid => $item->{inventoryID} },
	AssetID => { Guid => $item->{assetID} },
	AssetType => $item->{assetType},
	InvType => $item->{invType},
	Folder => { Guid => $item->{parentFolderID} },
	Owner => { Guid => $item->{avatarID} },
	Creator => { Guid => $item->{creatorID} },
	Name => $item->{inventoryName},
	Description => $item->{inventoryDescription} || "",
	NextPermissions => $item->{inventoryNextPermissions},
	CurrentPermissions => $item->{inventoryCurrentPermissions},
	BasePermissions => $item->{inventoryBasePermissions},
	EveryOnePermissions => $item->{inventoryEveryOnePermissions},
	CreationDate => $item->{creationDate},
	Flags => $item->{flags},
	GroupID => $item->{groupID},
	GroupOwned => $item->{groupOwned},
	SalePrice => $item->{salePrice},
	SaleType => $item->{saleType},
    };
    return $ret;
}

sub _convert_to_db_folder {
    my $folder = shift;
    my $ret = {
	folderName => $folder->{Name},
	agentID => $folder->{Owner}->{Guid},
	parentFolderID => $folder->{ParentID}->{Guid},
	folderID => $folder->{ID}->{Guid},
	type => $folder->{Type},
	version => $folder->{Version},
    };
    return $ret;
}

sub _convert_to_response_folder {
    my $folder = shift;
    my $ret = {
	Name => $folder->{folderName},
	Owner => { Guid => $folder->{agentID} },
	ParentID => { Guid => $folder->{parentFolderID} },
	ID => { Guid => $folder->{folderID} },
	Type => $folder->{type},
	Version => $folder->{version},
    };
    return $ret;
}

sub __create_folder_struct {
    my ($id, $owner, $parentid, $name, $type, $version) = @_;
    return {
	"Name" => $name,
	"Owner" => { Guid => $owner },
	"ParentID" => { Guid => $parentid },
	"ID" => { Guid => $id },
	"Type" => $type,
	"Version" => $version,
    };
}

sub _create_default_inventory {
    my ($uuid, $save_flag)= @_;
    $save_flag ||= 0;
    my @InventoryFolders = ();
    my $root_folder_id = &OpenUGAI::Util::GenerateUUID();
    push @InventoryFolders, &__create_folder_struct($root_folder_id, $uuid, &OpenUGAI::Util::ZeroUUID(), "My Inventory", 8, 1);
    push @InventoryFolders, &__create_folder_struct(&OpenUGAI::Util::GenerateUUID(), $uuid, $root_folder_id, "Textures", 0, 1);
    push @InventoryFolders, &__create_folder_struct(&OpenUGAI::Util::GenerateUUID(), $uuid, $root_folder_id, "Objects", 6, 1);
    push @InventoryFolders, &__create_folder_struct(&OpenUGAI::Util::GenerateUUID(), $uuid, $root_folder_id, "Clothes", 5, 1);
    push @InventoryFolders, &__create_folder_struct(&OpenUGAI::Util::GenerateUUID(), $uuid, $root_folder_id, "Bodyparts", 13, 1);
    if ($save_flag) {
	foreach(@InventoryFolders) {
	    &OpenUGAI::Data::Inventory::saveInventoryFolder(&_convert_to_db_folder($_));
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

sub _validate_session {
    my $data = shift;
    if (!$data->{SessionID} || !$data->{AvatarID} || !$data->{Body}) {
	Carp::croak("invalid data format");	
    }
    my $session_id = $data->{SessionID};
    my $user_id = $data->{AvatarID};
    if ( !&_check_auth_session($user_id, $session_id) ) {
	Carp::croak("invalid session id");
    }
}

sub _check_auth_session {
    # TODO @@@ not inplemented
    return 1;
}


1;
