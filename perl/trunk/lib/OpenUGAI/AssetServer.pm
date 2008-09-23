package OpenUGAI::AssetServer;

use strict;
use Carp;
use OpenUGAI::AssetServer::Storage;

our $AssetStorage;

BEGIN {
    eval {
	$AssetStorage = &OpenUGAI::AssetServer::Storage::GetInstance();
    };
    if ($@) {
	$AssetStorage = undef;
	Carp::croak("can not start AssetServer: $@");
    }
}

# !!
# TODO: delete asset
#

sub getAsset {
    my ($asset_id, $param) = @_;
    # get asset
    return $AssetStorage->getAsset($asset_id);
}

sub saveAsset {
    my $asset_xml = shift;
    $AssetStorage->saveAsset($asset_xml);
    return "";
    # TODO: temporary solution of "success!"
    # TODO: message for save failed
}

1;

