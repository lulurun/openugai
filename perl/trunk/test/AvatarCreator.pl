!/usr/bin/perl -w

use strict;
use OpenUGAI::Global;
use OpenUGAI::Utility;
use OpenUGAI::Data::Inventory;
use OpenUGAI::Data::Users;
use OpenUGAI::Data::Assets;
use OpenUGAI::Avatar::Appearance;

require "config.pl";

my %TE_Name2IDX = (
                   eye => 3,
                   hair => 4,
                   jacket_top => 13,
                   jacket_lower => 14,
                   pants => 2,
                   shoes => 7,
		   sneakers => 7, # synonym
                   skin_face => 0,
                   skin_upper => 5,
                   skin_lower => 6,
                   underwear => 17,
		   skirt => 18,
		   shirt => 1,
                   );

my %WearableType = (
		    Shape => 0,
		    Skin => 1,
		    Hair => 2,
		    Eyes => 3,
		    Shirt => 4,
		    Pants => 5,
		    Shoes => 6,
		    Socks => 7,
		    Jacket => 8,
		    Gloves => 9,
		    Undershirt => 10,
		    Underpants => 11,
		    Skirt => 12,
		    );

# real
#&batch();

# test
my $base_dir = $ARGV[0] || die "no dir";
&make_avatar_dataset($base_dir);

sub batch {
    my $base_dir = $ARGV[0] || "";
    opendir(DIR, $base_dir) || die "can not opendir $base_dir";
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
}

sub make_avatar_dataset {
    my $folder = shift;
    # make user
    my $user_id = &OpenUGAI::Utility::GenerateUUID();
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
	&OpenUGAI::Data::Users::createUser(\%user);
    }
    # make inventory folder
    my $root_folder_id = &OpenUGAI::Utility::GenerateUUID();
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
    my $wearables_folder_id = &OpenUGAI::Utility::GenerateUUID();
    {
	my %inventory_folder = (
				"folderName" => "Wearables",
				"type" => -1,
				"version" => 1,
				"folderID" => $wearables_folder_id,
				"agentID" => $user_id,
				"parentFolderID" => $root_folder_id,
				);
	&OpenUGAI::Data::Inventory::saveInventoryFolder(\%inventory_folder);
    }
    my $images_folder_id = &OpenUGAI::Utility::GenerateUUID();
    {
	my %inventory_folder = (
				"folderName" => "Images",
				"type" => -1,
				"version" => 1,
				"folderID" => $images_folder_id,
				"agentID" => $user_id,
				"parentFolderID" => $root_folder_id,
				);
	&OpenUGAI::Data::Inventory::saveInventoryFolder(\%inventory_folder);
    }
    # make assets & inventory item
    opendir(DIR, $folder) || die "can not opendir $folder";
    my @ls = readdir(DIR);
    closedir(DIR);

    my %teidx2uuid = ();
    my $assetset_xml = "";
    foreach (@ls) {
	next if ($_ eq ".");
	next if ($_ eq "..");
	next if ($_ =~ /\.xml$/);
	my $filename = $folder . "/" .$_;
	my ($asset_name, undef) = split(/\./, $_);
	my $asset_id = &OpenUGAI::Utility::GenerateUUID();
	my $asset_data = &load_asset_data($filename);
	my $asset_type = 0;
	my $inv_type = 0;
	my $parent_folder_id = $images_folder_id;
	if ($_ =~ /\.jp2$/) {
	    $teidx2uuid{&guess_texture_index($_)} = $asset_id;
	}
	if ($_ =~ /\.dat$/) {
	    $parent_folder_id = $wearables_folder_id;
	    $inv_type = 18;
	    $asset_type = &guess_asset_type($_);
	}
	{
	    my %asset = (
			 "name" => $asset_name,
			 "description" => "",
			 "assetType" => $asset_type,
			 "local" => 0,
			 "temporary" => 0,
			 "data" => $asset_data,
			 "id" => $asset_id,
			 );
	    $assetset_xml .= &make_assetset_section(\%asset, $_);
	    #&OpenUGAI::Data::Assets::UpdateAsset(\%asset);
	}
	{
	    my %inv_item = (
			    "assetID" => $asset_id,
			    "assetType" => $asset_type,
			    "inventoryName" => $asset_name,
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
			    "inventoryID" => &OpenUGAI::Utility::GenerateUUID(),
			    "avatarID" => $user_id,
			    "parentFolderID" => $parent_folder_id,
			    );
	    &OpenUGAI::Data::Inventory::saveInventoryItem(\%inv_item);
	}
    } # foreach (@ls)

    # reassign textures
    foreach (@ls) {
	next if ($_ !~ /\.dat$/);
	&reassgin_wearable_textures($_, \%teidx2uuid, $folder);	
    }

    $assetset_xml = "<Nini>\n$assetset_xml</Nini>\n";
    open(FILE, ">$base_dir/assetset.xml");
    print FILE $assetset_xml;
    close(FILE);
}

sub make_assetset_section {
    my ($asset, $filename) = @_;
    my $xml = << "XML_SECTION";
 <Section Name="$asset->{name}">
    <Key Name="assetID" Value="$asset->{id}" />
    <Key Name="name" Value="$asset->{name}" />
    <Key Name="assetType" Value="$asset->{assetType}" />
    <Key Name="inventoryType" Value="0" />
    <Key Name="fileName" Value="$filename" />
  </Section>
XML_SECTION
    return $xml;
}

sub load_asset_data {
    my $filename = shift;
    my $bin = "";
    open(FH,'<'.$filename) || die "can not open $filename";
    binmode(FH);
    my $size = read(FH,$bin,-s $filename);
    print "INFO: load asset $filename data size: $size\n";
    close(FH);
    return $bin;
}

sub guess_asset_type {
    my $filename = shift;
    foreach (keys %WearableType) {
        my $pattern = $_;
        if ($filename =~ /$pattern/i) {
	    my $asset_type = $WearableType{$pattern} > 3 ? 5 : 13;
            print "Guess $asset_type $filename\n";
            return $asset_type;
        }
    }
    # must die
    die "WARN guess failed for $filename";
}

sub guess_texture_index {
    my $filename = shift;
    foreach (keys %TE_Name2IDX) {
        my $pattern = $_;
        my $index = $TE_Name2IDX{$pattern};
        if ($filename =~ /$pattern/i) {
            print "Guess $index $filename\n";
            return $index;
        }
    }
    # must die
    die "WARN guess failed for $filename";
}

sub reassgin_wearable_textures {
    my ($filename, $hash_map, $folder) = @_;
    my $app_file = "$folder/$filename";
    my $appearance = &ParseLLWearableFile($app_file);
    my $textures = $appearance->{textures};
    foreach (keys %$textures) {
	next if ($_ eq "header");
        $textures->{$_} = $hash_map->{$_};
    }
    $appearance->{textures} = $textures;
    # update appearance file
    open(FILE, ">$app_file") || die "can not save $app_file";
    print FILE $appearance->ToLLFormat();
    close(FILE);
}

sub ParseLLWearableFile {
    my $file = shift;
    open(FILE, $file) || die "can not open $file";
    my @data = <FILE>;
    close(FILE);
    my $appearance_string = join "", @data;
    my $appearance = new OpenUGAI::Avatar::Appearance($appearance_string);
    return $appearance;
}

