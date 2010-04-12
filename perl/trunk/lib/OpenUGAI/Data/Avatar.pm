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
    delete_avatar_attachments =>
    "delete from avatarattachments where uuid=?",
    get_avatar_3di =>
    "select * from avatardata_3di where user_id=?",
    update_avatar_3di =>
    "replace into avatardata_3di values(?,?)",    
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

sub DeleteAvatarAttachments {
    my $owner = shift;
    my @args = ( $owner );
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{delete_avatar_attachments}, \@args);
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

# #############
# Avatar 3di
sub GetAvatarID3Di {
    my $owner = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{get_avatar_3di}, $owner);
    my $count = @$res;
    if ($count == 1) {
	return $res->[0];
    } else {
	return undef;
    }
}

sub UpdateAvatar3Di {
    my $user_id = shift;
    my $avatar_id = shift;
    my @args = ($user_id, $avatar_id);
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{update_avatar_3di}, \@args);
    return $res;
}

1;
