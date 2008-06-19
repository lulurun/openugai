package OpenUGAI::UserServer::UserManager;

use strict;
use Carp;
use OpenUGAI::DBData;
use OpenUGAI::UserServer::Config;

sub getUserByName {
    my ($first, $last) = @_;
    my $res = &OpenUGAI::DBData::getSimpleResult($OpenUGAI::UserServer::Config::SYS_SQL{select_user_by_name}, lc($first), lc($last) );
    my $count = @$res;
    my %user = ();
    if ($count == 1) {
		my $user_row = $res->[0];
		foreach (@OpenUGAI::UserServer::Config::USERS_COLUMNS) {
	    	$user{$_} = $user_row->{$_} || "";
		}
    } else {
		return undef;
    }
    return \%user;
}

sub getUserByUUID {
    my ($uuid) = @_;
    my $res = &OpenUGAI::DBData::getSimpleResult($OpenUGAI::UserServer::Config::SYS_SQL{select_user_by_uuid}, $uuid);
    my $count = @$res;
    my %user = ();
    if ($count == 1) {
		my $user_row = $res->[0];
		foreach (@OpenUGAI::UserServer::Config::USERS_COLUMNS) {
			$user{$_} = $user_row->{$_} || "";
		}
    } else {
		return undef;
    }
    return \%user;
}

sub createUser {
    my $user = shift;
    my @params = ();
    foreach (@OpenUGAI::UserServer::Config::USERS_COLUMNS) {
		push @params, $user->{$_};
    }
    my $res = &OpenUGAI::Utility::getSimpleResult($OpenUGAI::UserServer::Config::SYS_SQL{create_user}, @params);
}

sub getAvatarAppearance {
	my $owner = shift;
    my $res = &OpenUGAI::Utility::getSimpleResult($OpenUGAI::UserServer::Config::SYS_SQL{get_avatar_appearance}, $owner);
    my $count = @$res;
    if ($count == 1) {
    	my $appearance = $res->[0];
		return $appearance;
    } else {
    	return undef;
    }
}

1;
