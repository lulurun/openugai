package OpenUGAI::AssetServer::Storage::MySQL;

use strict;
use MIME::Base64;
use XML::Simple;
use OpenUGAI::DBData;
use OpenUGAI::Global;
use OpenUGAI::Util;

our %SQL = (
	    select_asset_by_uuid =>
	    "SELECT * FROM assets WHERE id=?",
	    insert_asset =>
	    "INSERT INTO assets VALUES (?,?,?,?,?,?,?,?,?)",
	    delete_asset =>
	    "DELETE FROM assets WHERE id=?",
	    );

our @ASSETS_COLUMNS = (
    "name",
    "description",
    "assetType",
    "local",
    "temporary",
    "data",
    "id",
    "create_time",
    "access_time",
    );

sub new {
    my ($this, $option) = @_;
    # config.presentation
    my $presen_class = $option->{presentation} || Carp::croak("no presentation class");

    my %fields = (
		  );
    # Do not get connection here
    # MySql Connection is managed by Apache::DBI
    return bless \%fields, $this;
}

sub fatchAsset {
    my ($this, $uuid) = @_;
    my $result = undef;
    $result = &OpenUGAI::DBObject::SimpleQuery( $SQL{select_asset_by_uuid}, [$uuid] );
    if ($result) {
	my $count = @$result;
	if ($count > 0) {
	    return $reault->[0];
	}
    }
    return 0;
}

sub storeAsset {
    my ($this, $asset) = @_;
    my @asset_args;
    foreach(@ASSETS_COLUMNS) {
	push @asset_args, $asset->{$_};
    }
    my $result = undef;
    $result = &OpenUGAI::DBObject::SimpleQuery( $SQL{select_asset_by_uuid}, \@asset_args);
    return $result;
}

# TODO @@@ !!! todo
sub delelteAsset {
    my ($this, $uuid) = @_;
    my $conn = $this->{Connection};
    my $result = undef;
    my $sql = $SQL{delete_asset};
    eval {
	my $st = new Statement($conn, $sql);
	$result = $st->exec($uuid);
    };
    if ($@) {
	Carp::croak("MySQL statement failed: $sql -> " . $@);	
    }
    return $result;
}

1;

