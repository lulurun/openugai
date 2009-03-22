package OpenUGAI::DBData::Avatar;

use strict;

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
    my ($conn, $uuid) = @_;
    my $res = $conn->query($SQL{get_avatar_attachment}, { $uuid });
    my $count = @$res;
    if ($count == 1) {
    	return $res->[0];
    } else {
    	return undef;
    }
 }

sub UpdateAttachment {
    my ($conn, $attachment) = @_;
    my @args = ();
    foreach( @ATTACHMENT_COLUMNS ) {
	push @args, $attachment->{$_}; # TODO: OK ???
    }
    return $conn->query($SQL{update_avatar_attachment}, \@args);
}

sub DeleteAvatarAttachments {
    my ($conn, $owner) = @_;
    return $conn->query($SQL{delete_avatar_attachments}, { $owner });
}

# #############
# Appearance
sub SelectAppearance {
    my ($conn, $owner) = @_;
    my $res = $conn->query($SQL{get_avatar_appearance}, { $owner });
    my $count = @$res;
    if ($count == 1) {
    	return $res->[0];
    } else {
    	return undef;
    }
}

sub UpdateAppearance {
    my ($conn, $appearance) = @_;
    my @args = ();
    foreach( @APPEARANCE_COLUMNS ) {
	push @args, $appearance->{lc($_)}; # stupid lc because stupid opensim impl
    }
    return $conn->query($SQL{update_avatar_appearance}, \@args);
}

sub UpdateAppearance_RawData {
    my ($conn, $appearance) = @_;
    my @args = ();
    foreach( @APPEARANCE_COLUMNS ) {
	push @args, $appearance->{lc($_)}; # stupid lc because stupid opensim impl
    }
    return $conn->query($SQL{update_avatar_appearance_raw_data}, \@args);
}

1;
