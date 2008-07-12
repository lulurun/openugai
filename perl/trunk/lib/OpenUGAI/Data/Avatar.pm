package OpenUGAI::Data::Avatar;

use strict;
use OpenUGAI::DBData;
use OpenUGAI::Utility;

my %SQL = (
    get_avatar_appearance =>
    "select * from avatarappearance where owner=?",
    update_avatar_appearance =>
    "replace into avatarappearance values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
);

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
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{update_avatar_appearance}, $appearance);
    return $res;
}

1;
