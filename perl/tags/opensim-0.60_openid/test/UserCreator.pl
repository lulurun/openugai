#!/usr/bin/perl -w

use strict;
use OpenUGAI::Global;
use OpenUGAI::Utility;
use OpenUGAI::Data::Inventory;
use OpenUGAI::Data::Users;
use OpenUGAI::Data::Assets;
use OpenUGAI::Data::Avatar;
use OpenUGAI::Avatar::Appearance;

require "config.pl";

my $default_visual_params = "381742000019007C6B00005B8924B44F4E1420FF003F89893F7A00477F5E3F00CB00001100000000007F0000FF7F727F633F7F8C7F7F000000BF004E00000000000000000091D885000000DB6B0000A58700557F7F3F709B64D8D6CCCCCC3319594CCC00000000BCFF5BDB7C00007FA57F7F7F7F3B3F6B474459214F72B27F028D4200007F7F000000007F009F0000B27F005583757F93A368008C12006B8200D6CCC6000028265BA5D1C67F7F99CC3333FFFFFFCC00FFFFFFFFFFFFFFFFFFFFFF00FFFFFFFFFF007F16FF1964FFFFFFFF540000003384FFFFFF";
#my $default_texture = "C228D1CF4B5D4BA884F4899A0796AA970100000000000011119999000000000012025748DECCF629461C9A36A35A221FE21F045748DECCF629461C9A36A35A221FE21F086522E74D16604E7FB6016F48C1659A77107CA39B4CBD194699AFF7F93FD03D3E7B200000000000001111999900000000001040000000000000111199990000000000118200B68D1290F0B40A7A22061A8D50252EAA84009648CA8A6115B86E589DF20EDF8FB55E88002EDF4DEE5D10CF6CD4D9866FD85A55A390003009DD1868FAAF2FA46F0FC08497D1E00000000000000000803F000000803F000000000000000000000000000000";
#my $default_texture = "C228D1CF4B5D4BA884F4899A0796AA970100000000000011119999000000000012025748DECCF629461C9A36A35A221FE21F045748DECCF629461C9A36A35A221FE21F086522E74D16604E7FB6016F48C1659A77107CA39B4CBD194699AFF7F93FD03D3E7B200000000000001111999900000000001040000000000000111199990000000000118200B68D1290F0B40A7A22061A8D50252EAA84009648CA8A6115B86E589DF20EDF8FB55E88002EDF4DEE5D10CF6CD4D9866FD85A55A390003009DD1868FAAF2FA46F0FC08497D1E00000000000000000803F000000803F000000000000000000000000000000";
my $default_texture = "C228D1CF4B5D4BA884F4899A0796AA9701A17420F47EB811DD9A1358D4138B191304A174D6AC7EB811DD9A1358D4138B191308A17459167EB811DD9A1358D4138B191310A17263B87EB811DD9A1358D4138B191320A1757DC87EB811DD9A1358D4138B191340A1779E5A7EB811DD9A1358D4138B19138100A173E9F47EB811DD9A1358D4138B19138200B68D1290F0B40A7A22061A8D50252EAA84009648CA8A6115B86E589DF20EDF8FB55E88002EDF4DEE5D10CF6CD4D9866FD85A55A390003009DD1868FAAF2FA46F0FC08497D1E0C000858BB38CBD4B4DA5B10692CAD52DBEFA81800017FBCEFB2F914A73AD5EDAEE70BC645B888000A17657347EB811DD9A1358D4138B19130000000000000000803F000000803F000000000000000000000000000000";
my $default_texture = "C228D1CF4B5D4BA884F4899A0796AA9701A17420F47EB811DD9A1358D4138B191304A174D6AC7EB811DD9A1358D4138B191308A17459167EB811DD9A1358D4138B191310A17263B87EB811DD9A1358D4138B191320A1757DC87EB811DD9A1358D4138B191340A1779E5A7EB811DD9A1358D4138B19138100A173E9F47EB811DD9A1358D4138B19138200B68D1290F0B40A7A22061A8D50252EAA8400A29D1652A6199BACFD8770AFD4E32D0A8800E74B6583F3FCB3D5398F62A94C56369C90003009DD1868FAAF2FA46F0FC08497D1E0C000858BB38CBD4B4DA5B10692CAD52DBEFA81800017FBCEFB2F914A73AD5EDAEE70BC645B888000A17657347EB811DD9A1358D4138B19130000000000000000803F000000803F000000000000000000000000000000";



my $first_name = $ARGV[0] || "";
my $last_name = $ARGV[1] || "";
my $wearables_file = $ARGV[2] || "";

# get information
# user
my $user = &get_user($first_name, $last_name);
# wearables & assets
my $wearables = &get_wearables($wearables_file);
my $wearable_assets = &get_wearables_assets($wearables);
&recreate_wearables($wearables, $wearable_assets);
# inventory
my $inventory_folders = &get_inventory_default_set($user);
my $wearables_folder = $inventory_folders->{"Wearables"};
my $wearable_items = &create_wearables_items($wearables, $wearables_folder);
my $appearance = &get_appearance($user->{UUID}, 0, 0.0, $wearables);
#Data::Dump::dump $user->{UUID};
#Data::Dump::dump $inventory_folders;
#Data::Dump::dump $wearable_items;
#Data::Dump::dump $appearance;

# insert user
&OpenUGAI::Data::Users::createUser($user);
# insert inventory folders
foreach (values %$inventory_folders) {
    &OpenUGAI::Data::Inventory::saveInventoryFolder($_);
}
# insert inventory items & assets
foreach (values %$wearable_items) {
    &OpenUGAI::Data::Inventory::saveInventoryItem($_);    
}
foreach (values %$wearable_assets) {
    &OpenUGAI::Data::Assets::UpdateAsset($_);    
}
# insert avatarappearance
&OpenUGAI::Data::Avatar::UpdateAppearance_RawData($appearance);

# ###############
# get_appearance
sub get_appearance {
    my ($user_id, $serial, $height, $wearables) = @_;
    my %fields = ();
    foreach (keys %$wearables) {
	my $name = $_;
	my $wearable = $wearables->{$name};
	my $asset_key = lc($name . "_Asset");
	my $item_key = lc($name . "_Item");
	$fields{$asset_key} = $wearable->{Asset};
	$fields{$item_key} = $wearable->{Item};
    }
    $fields{owner} = $user_id;
    $fields{serial} = $serial;
    $fields{avatar_height} = $height;
    $fields{visual_params} = $default_visual_params;
    $fields{texture} = $default_texture;
    return \%fields;
}

# ###############
# reassgin item id to wearables
sub recreate_wearables {
    my ($wearables, $wearable_assets) = @_;
    foreach (keys %$wearable_assets) {
	my ($name, $type) = split(/_/, $_);
	$wearables->{$name}->{$type} = $wearable_assets->{$_}->{id};
    }
}

# #############
# get wearable asset data from assets table
sub get_wearables_assets {
    my $wearables = shift;
    my %wearable_assets = ();
    foreach my $name (keys %$wearables) {
	my $wearable = $wearables->{$name};
	my $asset_id = $wearable->{Asset};
	next if ($asset_id eq &OpenUGAI::Utility::ZeroUUID);
	my $wearable_asset = &OpenUGAI::Data::Assets::SelectAsset($asset_id);
	# change to a new asset_id
	$wearable_asset->{id} = &OpenUGAI::Utility::GenerateUUID();
	$wearable_assets{$name . "_Item"} = $wearable_asset;
    }
    return \%wearable_assets;
}

# #############
# create a set of inventory folders
sub get_inventory_default_set {
    my $user = shift;
    my $user_id = $user->{UUID};
    my %folders = ();
    my $root_folder_id = &OpenUGAI::Utility::GenerateUUID();
    my $wearables_folder_id = &OpenUGAI::Utility::GenerateUUID();
    my $images_folder_id = &OpenUGAI::Utility::GenerateUUID();
    {
	my $folder_name = "My Inventory";
	$folders{$folder_name} = &get_inventory_folder($folder_name, 8, 1, $root_folder_id, $user_id, &OpenUGAI::Utility::ZeroUUID);
    }
    {
	my $folder_name = "Wearables";
	$folders{$folder_name} = &get_inventory_folder($folder_name, -1, 1, $wearables_folder_id, $user_id, $root_folder_id);
    }
    {
	my $folder_name = "Imamges";
	$folders{$folder_name} = &get_inventory_folder($folder_name, -1, 1, $images_folder_id, $user_id, $root_folder_id);
    }
    return \%folders;
}

# ###############
# get wearables asset id from a file
sub get_wearables {
    my $file = shift;
    open(FILE, $file) || die "can not open $file";
    my @lines = <FILE>;
    close(FILE);

    my %wearables = ();
    foreach (@lines) {
	chomp;
	my ($key, $asset_id) = split(/[:\s]+/, $_);
	my ($name, $type) = split(/_/, $key);
	$wearables{$name}->{$type} = $asset_id;
    }
    return \%wearables;
}

# ##############
# create inventory items for avatar wearables
sub create_wearables_items {
    my ($wearables, $wearables_folder) = @_;
    my $folder_id = $wearables_folder->{folderID};
    my $user_id = $wearables_folder->{agentID};
    my %items = ();
    foreach my $name (keys %$wearables) {
	my $wearable = $wearables->{$name};
	my $asset_id = $wearable->{"Asset"};
	next if ($asset_id eq &OpenUGAI::Utility::ZeroUUID);
	my $asset_type = 13;
	my $item_id = &OpenUGAI::Utility::GenerateUUID();
	my $item_name = $name . "_Item";
	$items{$item_name} = &get_inventory_item($asset_id, $asset_type, $item_name, 18,
						 $user_id, $folder_id, $item_id);
    }
    return \%items;
}

# ##############
# create a user with default profile
sub get_user {
    my ($first_name, $last_name, $user_id) = @_;
    $user_id ||= &OpenUGAI::Utility::GenerateUUID();
    my %user = (
		"UUID" => $user_id,
		"username" => $first_name,
		"lastname" => $last_name,
		"passwordHash" => "84e78b596fa8e391c49f3c4df7b9c57f",
		"passwordSalt" => "",
		"homeRegion" => "10995116280320000",
		"homeLocationX" => 128,
		"homeLocationY" => 128,
		"homeLocationZ" => 20,
		"homeLookAtX" => 100,
		"homeLookAtY" => 100,
		"homeLookAtZ" => 100,
		"created" => "1220207762",
		"lastLogin" => "0",
		"userInventoryURI" => "",
		"userAssetURI" => "",
		"profileCanDoMask" => 0,
		"profileWantDoMask" => 0,
		"profileAboutText" => "",
		"profileFirstText" => "",
		"profileImage" => "",
		"profileFirstImage" => "",
		"webLoginKey" => "",
		);
    return \%user;
}

# #############
# create an inventory folder
sub get_inventory_folder {
    my ($name, $type, $ver, $folder_id, $user_id, $parent_folder_id) = @_;
    my %inventory_folder = (
			    "folderName" => $name,
			    "type" => $type,
			    "version" => $ver,
			    "folderID" => $folder_id,
			    "agentID" => $user_id,
			    "parentFolderID" => $parent_folder_id,
			    );
    return \%inventory_folder;
}

# ############
# create an inventory item
sub get_inventory_item {
    my ($asset_id, $asset_type, $inv_name, $inv_type, $user_id, $folder_id, $inv_id) = @_;
    $inv_id ||=  &OpenUGAI::Utility::GenerateUUID();
    my %inv_item = (
		    "assetID" => $asset_id,
		    "assetType" => $asset_type,
		    "inventoryName" => $inv_name,
		    "inventoryDescription" => "",
		    "inventoryNextPermissions" => 532480,
		    "inventoryCurrentPermissions" => 2147483647,
		    "invType" => $inv_type,
		    "creatorID" => $user_id,
		    "inventoryBasePermissions" => 2147483647,
		    "inventoryEveryOnePermissions" => 0,
		    "salePrice" => 0,
		    "saleType" => 0,
		    "creationDate" => time,
		    "groupID" => &OpenUGAI::Utility::ZeroUUID,
		    "groupOwned" => 0,
		    "flags" => 0,
		    "inventoryID" => $inv_id,
		    "avatarID" => $user_id,
		    "parentFolderID" => $folder_id,
		    );
    return \%inv_item;
}
