package OpenUGAI::Data::Users;

use strict;
use OpenUGAI::DBData;

our %SQL = (
    select_user_by_name =>
    "select * from users where lcase(username)=? and lcase(lastname)=?",
    select_user_by_uuid =>
    "select * from users where uuid=?",
    create_user =>
    "replace into users values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
    update_user_by_uuid =>
    "update users set username=?,lastname=?,passwordHash=?,passwordSalt=?,homeRegion=?,homeLocationX=?,homeLocationY =?,homeLocationZ=?,homeLookAtX=?,homeLookAtY=?,homeLookAtZ=?,created=?,lastLogin=?,userInventoryURI=?,userAssetURI=?,profileCanDoMask=?,profileWantDoMask=?,profileAboutText=?,profileFirstText=?,profileImage=?,profileFirstImage=?,webLoginKey=? WHERE UUID=?",
    get_avatar_appearance =>
    "select * from avatarappearance where Owner=?",
    select_agent_by_uuid =>
    "select * from agents",
    insert_agent =>
    "REPLACE INTO agents VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
    );

our @USERS_COLUMNS = (
	"UUID",
	"username",
	"lastname",
	"passwordHash",
	"passwordSalt",
	"homeRegion",
	"homeLocationX",
	"homeLocationY",
	"homeLocationZ",
	"homeLookAtX",
	"homeLookAtY",
	"homeLookAtZ",
	"created",
	"lastLogin",
	"userInventoryURI",
	"userAssetURI",
	"profileCanDoMask",
	"profileWantDoMask",
	"profileAboutText",
	"profileFirstText",
	"profileImage",
	"profileFirstImage",
	"webLoginKey",
);

our %DEFAULT_USER = (
	"UUID" => "00000000-0000-0000-0000-000000000000",
	"username" => "Test",
	"lastname" => "User",
	"passwordHash" => "",
	"passwordSalt" => "",
	"homeRegion" => "1099511628032000",
	"homeLocationX" => 128,
	"homeLocationY" => 128,
	"homeLocationZ" => 128,
	"homeLookAtX" => 100,
	"homeLookAtY" => 100,
	"homeLookAtZ" => 100,
	"created" => 0,
	"lastLogin" => 0,
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

sub CreateTemporaryUser {
    my $userinfo = shift;
    my %new_user = ();
    foreach (@USERS_COLUMNS) {
	$new_user{$_} = $userinfo->{$_} ? $userinfo->{$_} : $DEFAULT_USER{$_};
    }
    return \%new_user;
}

sub getUserByName {
    my ($first, $last) = @_;
    my @args = ( lc($first), lc($last) );
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{select_user_by_name}, \@args);
    my $count = @$res;
    if ($count == 1) {
	return $res->[0];
    }
    return undef;
}

sub getUserByUUID {
    my $uuid = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{select_user_by_uuid}, $uuid);
    my $count = @$res;
    if ($count == 1) {
	return $res->[0];
    }
    return undef;
}

sub createUser {
    my $user = shift;
    my @params = ();
    foreach (@USERS_COLUMNS) {
	push @params, $user->{$_};
    }
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{create_user}, \@params);
}

sub updateUserByUUID {
    my $user = shift;
    my @params = ();
    foreach (@USERS_COLUMNS) {
	push @params, $user->{$_};
    }
    push @params, shift @params;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{update_user_by_uuid}, \@params);
}

1;

