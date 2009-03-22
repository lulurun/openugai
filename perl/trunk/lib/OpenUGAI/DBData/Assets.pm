package OpenUGAI::DBData::Assets;

use strict;

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

sub fetchAsset {
    my ($conn, $id) = @_;
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
    my ($conn, $asset) = @_;
    my @asset_args;
    foreach(@ASSETS_COLUMNS) {
	push @asset_args, $asset->{$_};
    }
    return $conn->query($SQL{insert_asset}, \@asset_args);
}

sub delelteAsset {
    my ($conn, $id) = @_;
    return $conn->query($SQL{delete_asset_by_uuid}, [ $id ]);
}

1;

