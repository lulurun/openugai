package OpenUGAI::AssetServer::Storage::MySQL;

use strict;
use OpenUGAI::DBData;
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
    my $db_info = $option->{db_info} || Carp::croak("db_info not set");
    Carp::croak("...") unless ($db_info->{DSN} && $db_info->{DBUSER} && $db_info->{DBPASS});

    # config.presentation     # not needed
    #my $presen_class = $option->{presentation} || Carp::croak("no presentation class");

    my %fields = (
		  #presen_class => $presen_class,		  
		  db_info => $db_info,
    );
    return bless \%fields, $this;
}

sub fetchAsset {
    my ($this, $id) = @_;
    my $result = undef;
    $result = &OpenUGAI::DBData::SimpleQuery( $SQL{select_asset_by_uuid}, [$id] );
    if ($result) {
	my $count = @$result;
	if ($count > 0) {
	    return $result->[0];
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

