package OpenUGAI::Data::Avatar;

use strict;
use OpenUGAI::DBData;

our %SQL = (
    get_avatar_appearance =>
    "select * from avatarappearance where owner=?",
    update_avatar_appearance =>
    "replace into avatarappearance values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
    update_avatar_appearance_raw_data =>
    "replace into avatarappearance values(?,?,X?,X?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
    get_avatar_attachment =>
    "select * from avatarattachments where uuid=?",
    update_avatar_attachment =>
    "replace into avatarattachments values(?,?,?,?)",
);

our @ATTACHMENT_COLUMNS = (
   "UUID",
   "attachpoint",
   "item",
   "asset",
);

our @APPEARANCE_COLUMNS = (
    "Owner",
    "Serial",
    "Visual_Params",
    "Texture",
    "Avatar_Height",
    "Body_Item",
    "Body_Asset",
    "Skin_Item",
    "Skin_Asset",
    "Hair_Item",
    "Hair_Asset",
    "Eyes_Item",
    "Eyes_Asset",
    "Shirt_Item",
    "Shirt_Asset",
    "Pants_Item",
    "Pants_Asset",
    "Shoes_Item",
    "Shoes_Asset",
    "Socks_Item",
    "Socks_Asset",
    "Jacket_Item",
    "Jacket_Asset",
    "Gloves_Item",
    "Gloves_Asset",
    "Undershirt_Item",
    "Undershirt_Asset",
    "Underpants_Item",
    "Underpants_Asset",
    "Skirt_Item",
    "Skirt_Asset",
);
# #############
# Attachment
sub SelectAttachment {
    my $uuid = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{get_avatar_attachment}, $uuid);
    return $res;
}

sub UpdateAttachment {
    my $attachment = shift;
    my @args = ();
    foreach( @ATTACHMENT_COLUMNS ) {
	push @args, $attachment->{$_}; # TODO: OK ???
    }
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{update_avatar_attachment}, \@args);
    return $res;
}

# #############
# Appearance
sub SelectAppearance {
    my $owner = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{get_avatar_appearance}, $owner);
    my $count = @$res;
    if ($count == 1) {
    	return $res->[0];
    } else {
    	return undef;
    }
}

sub UpdateAppearance {
    my $appearance = shift;
    my @args = ();
    foreach( @APPEARANCE_COLUMNS ) {
	push @args, $appearance->{lc($_)}; # stupid lc because stupid opensim impl
    }
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{update_avatar_appearance}, \@args);
    return $res;
}

sub UpdateAppearance_RawData {
    my $appearance = shift;
    my @args = ();
    foreach( @APPEARANCE_COLUMNS ) {
	push @args, $appearance->{lc($_)}; # stupid lc because stupid opensim impl
    }
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{update_avatar_appearance_raw_data}, \@args);
    return $res;
}

1;
