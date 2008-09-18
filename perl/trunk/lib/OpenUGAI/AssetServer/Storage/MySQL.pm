package OpenUGAI::AssetServer::Storage::MySQL;

use strict;
use DBHandler;
use OpenUGAI::Global;

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
	Connection => &DBHandler::getConnection($OpenUGAI::Global::DSN,
						$OpenUGAI::Global::DBUSER,
						$OpenUGAI::Global::DBPASS),
	);
    return bless \%fields , $this;
}

sub getAsset {
    my ($this, $uuid) = @_;
    my $conn = $this->{Connection};
    my $result = undef;
    my $sql = $SQL{select_asset_by_uuid};
    eval {
	my $st = new Statement($conn, $sql);
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
    my $sql = $SQL{insert_asset};
    eval {
	my $st = new Statement($conn, $sql);
	$result = $st->exec(@asset_args);
    };
    if ($@) {
	Carp::croak("MySQL statement failed: $sql -> " . $@);	
    }
    return $result;
}

1;
