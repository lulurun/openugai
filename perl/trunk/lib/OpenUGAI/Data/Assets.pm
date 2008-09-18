package OpenUGAI::Data::Assets;

use strict;
use OpenUGAI::DBData;

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

sub SelectAsset {
    my $uuid = shift;
    my $result = &OpenUGAI::DBData::getSimpleResult($SQL{select_asset_by_uuid}, $uuid);
    my $count = @$result;
    if ($count > 0) {
	return $result->[0];
    }
    return undef;
}

sub UpdateAsset {
    my $asset = shift;
    my @asset_args;
    foreach(@ASSETS_COLUMNS) {
	push @asset_args, $asset->{$_};
    }
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{insert_asset}, \@asset_args);
    return $res;
}

1;
