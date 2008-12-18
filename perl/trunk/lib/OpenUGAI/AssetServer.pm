package OpenUGAI::AssetServer;

use strict;
use Carp;
use OpenUGAI::AssetServer::Storage;
use OpenUGAI::Util;

our $AssetStorage;

sub StartUp {
    eval {
	$AssetStorage = &OpenUGAI::AssetServer::Storage::GetInstance();
    };
    if ($@) {
	$AssetStorage = undef;
	Cap::croak("can not start AssetServer: $@");
    }
}

# !!
# TODO: delete asset
#

sub getAsset {
    my ($asset_id, $param) = @_;
    # TODO: how to TODO ?
    if (!$AssetStorage) {
	OpenUGAI::Util::Log("asset", "startup", "AssetStorage is NULL !!");
	&StartUp;
    }
    # get asset
    return $AssetStorage->getAsset($asset_id);
}

sub saveAsset {
    my $asset_xml = shift;
    # TODO: how to TODO ?
    if (!$AssetStorage) {
	OpenUGAI::Util::Log("asset", "startup", "AssetStorage is NULL !!");
	&StartUp;
    }
    # save asset, they never update asset
    $AssetStorage->saveAsset($asset_xml);
    return "";
    # TODO: temporary solution of "success!"
    # TODO: message for save failed
}

1;

