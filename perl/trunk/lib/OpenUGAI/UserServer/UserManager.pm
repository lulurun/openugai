package OpenUGAI::UserServer::UserManager;

use strict;
use Carp;
use OpenUGAI::DBData;
use OpenUGAI::UserServer::Config;

sub getUserByName {
    my ($first, $last) = @_;
    my $res = &OpenUGAI::DBData::getSimpleResult($OpenUGAI::UserServer::Config::SYS_SQL{select_user_by_name}, $first, $last);
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

1;
