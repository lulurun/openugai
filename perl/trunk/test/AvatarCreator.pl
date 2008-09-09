#!/usr/bin/perl -w

use strict;
use OpenUGAI::Global;
use OpenUGAI::Utility;
use OpenUGAI::Data::Inventory;
use OpenUGAI::Data::User;
use OpenUGAI::Data::Asset;

my $base_dir = $ARGV[0] || "";
opendir(DIR, $base_dir) || die "can not opendir $dir";
my @ls = readdir(DIR);
close(DIR);

foreach (@ls) {
    next if ($_ eq ".");
    next if ($_ eq "..");
    my $sub_dir = $base_dir . "/" . $_;
    if (-d $sub_dir) {
	&make_avatar_dataset($sub_dir);
    }
}

sub make_avatar_dataset {
    my $folder = shift;
    # make user
    my $user_id = &OpenUGAI::GenerateUUID();
    $folder =~ /([^\/]+)$/;
    my $first_name = $1;
    my $last_name = "tmpl";
    {
	my %user = (
		    "UUID" => $user_id,
		    "username" => $first_name,
		    "lastname" => $last_name,
		    "passwordHash" => "84e78b596fa8e391c49f3c4df7b9c57f",
		    "passwordSalt" => "",
		    "homeRegion" => "1099511628032000",
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
	&OpenUGAI::Data::User::createUser(\%user);
    }
    # make inventory folder
    my $root_folder_id = &OpenUGAI::GenerateUUID();
    {
	my %inventory_folder = (
				"folderName" => "My Inventory",
				"type" => 8,
				"version" => 1,
				"folderID" => $root_folder_id,
				"agentID" => $user_id,
				"parentFolderID" => &OpenUGAI::Utility::ZeroUUID,
				);
	&OpenUGAI::Data::Inventory::saveInventoryFolder(\%inventory_folder);
    }
    my $avatar_folder_id = &OpenUGAI::GenerateUUID();
    {
	my %inventory_folder = (
				"folderName" => "Avatar",
				"type" => -1,
				"version" => 1,
				"folderID" => $avatar_folder_id,
				"agentID" => $user_id,
				"parentFolderID" => $root_folder_id,
				);
	&OpenUGAI::Data::Inventory::saveInventoryFolder(\%inventory_folder);
    }
    # make assets & inventory item
    opendir(DIR, $folder) || die "can not opendir $folder";
    my @ls = readdir(DIR);
    closedir(DIR);
    foreach (@ls) {
	next if ($_ eq ".");
	next if ($_ eq "..");
	my $filename = $folder . $_;
	my ($asset_name, undef) = split(/\./, $_);
	my $asset_id = &OpenUGAI::GenerateUUID();
	my $asset_data = &load_asset_data($filename);
	{
	    my %asset = (
			 "name" => $asset_name,
			 "description" => "",
			 "assetType" => 0,
			 "local" => 0,
			 "temporary" => 0,
			 "data" => $asset_data,
			 "id" => $asset_id,
			 );
	    &OpenUGAI::Data::Asset::UpdateAsset(\%asset);
	}
	{
	    my %inv_item = (
			    "assetID" => $asset_id,
			    "assetType" => 0,
			    "inventoryName" => $asset_name,
			    "inventoryDescription" => "",
			    "inventoryNextPermissions" => 532480,
			    "inventoryCurrentPermissions" => 2147483647,
			    "invType" => 0,
			    "creatorID" => $user_id,
			    "inventoryBasePermissions" => 2147483647,
			    "inventoryEveryOnePermissions" => 0,
			    "salePrice" => 0,
			    "saleType" => 0,
			    "creationDate" => time,
			    "groupID" => &OpenUGAI::Utility::ZeroUUID,
			    "groupOwned" => 0,
			    "flags" => 0,
			    "inventoryID" => &OpenUGAI::GenerateUUID(),
			    "avatarID" => $user_id,
			    "parentFolderID" => $avatar_folder_id,
			    );
	    &OpenUGAI::Data::Inventory::saveInventoryItem(\%inv_item);
	}
    } # foreach (@ls)
}

sub load_asset_data {
    my $filename = shift;
    open(FH,'<'.$filename);
    binmode(FH);
    $size = read(FH,$bin,-s $filename);
    print "INFO: load asset $filename data size: $size\n";
    close(FH);
}

