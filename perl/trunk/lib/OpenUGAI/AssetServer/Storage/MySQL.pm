package OpenUGAI::AssetServer::Storage::MySQL;

use strict;
use DBHandler;
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
    my $dbh = new DBHandler($db_info);
    # config.presentation     # not needed
    #my $presen_class = $option->{presentation} || Carp::croak("no presentation class");

    my %fields = (
		  #presen_class => $presen_class,		  
		  dbh => $dbh,
    );
    return bless \%fields, $this;
}

sub fetchAsset {
    my ($this, $id) = @_;
    my $st = $this->{dbh}->SimpleStatement( $SQL{select_asset_by_uuid} );
    my $result = $st->execute( [$id] );
    if (ref $result) {
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
    my $st = $this->{dbh}->SimpleStatement( $SQL{insert_asset} );
    return $st->execute( @asset_args );
}

# TODO @@@ !!! todo
sub delelteAsset {
    my ($this, $id) = @_;
    my $st = $this->{dbh}->SimpleStatement( $SQL{delete_asset_by_uuid} );
    return $st->execute( [$id] );
}

1;

