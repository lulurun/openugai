package OpenUGAI::AssetServer::Storage::MySQL;

use strict;
use DBHandler;
use OpenUGAI::Config;

our %SQL = (
    select_asset_by_uuid =>
    "SELECT * FROM assets WHERE id=?",
    insert_asset =>
    "REPLACE INTO assets VALUES (?,?,?,?,?,?,?)"
    );

our @ASSETS_COLUMNS = (
    "name",
    "description",
    "assetType",
    "local",
    "temporary",
    "data",
    "id",
    );

sub new {
    my $this = shift;
    my %fields = (
	Connection => &DBHandler::getConnection($OpenUGAI::Config::DSN,
						$OpenUGAI::Config::DBUSER,
						$OpenUGAI::Config::DBPASS);
	);
    return bless $this, \%fields;
}

sub getAsset {
    my ($this, $uuid) = @_;
    my $conn = $this->{Connection};
    my $result = undef;
    eval {
	my $st = new DBHandler::Statement($conn, $SQL{select_asset_by_uuid});
	$result = $st->exec($uuid);
    };
    if ($@) {
	Carp::croak("MySQL statement failed: $sql -> " . $@);	
    }
    if ($result) {
	my $count = @$result;
	if ($count > 0) {
	    return $result->[0];
	}
    }
    return undef;
}

sub saveAsset {
    my ($this, $asset) = @_;
    my @asset_args;
    foreach(@ASSETS_COLUMNS) {
	push @asset_args, $asset->{$_};
    }
    my $conn = $this->{Connection};
    my $result = undef;
    eval {
	my $st = new DBHandler::Statement($conn, $SQL{insert_asset});
	$result = $st->exec(@asset_args);
    };
    if ($@) {
	Carp::croak("MySQL statement failed: $sql -> " . $@);	
    }
    return $result;
}

1;
