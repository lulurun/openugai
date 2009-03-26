package OpenUGAI::DBData::Assets;

use strict;
use DBConn;

our %SQL = (
	    select_asset_by_uuid =>
	    "SELECT * FROM assets WHERE id=?",
	    insert_asset =>
	    "REPLACE INTO assets VALUES (?,?,?,?,?,?,?,?,?)",
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

sub fetchAsset {
    my $db_info = shift;
    my $id = shift;
    my $conn = new DBConn($db_info);
    my $res = $conn->query($SQL{select_asset_by_uuid}, [ $id ]);
    if (ref $res) {
	my $count = @$res;
	if ($count > 0) {
	    return $res->[0];
	}
    }
    return 0;
}

sub storeAsset {
    my $db_info = shift;
    my $asset = shift;
    my @asset_args;
    foreach(@ASSETS_COLUMNS) {
	push @asset_args, $asset->{$_};
    }
    my $conn = new DBConn($db_info);
    return $conn->query($SQL{insert_asset}, \@asset_args);
}

sub delelteAsset {
    my $db_info = shift;
    my $id = shift;
    my $conn = new DBConn($db_info);
    return $conn->query($SQL{delete_asset_by_uuid}, [ $id ]);
}

1;

