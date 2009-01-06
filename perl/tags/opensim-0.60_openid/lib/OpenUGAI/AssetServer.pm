package OpenUGAI::AssetServer;

use strict;
use Carp;
use OpenUGAI::AssetServer::Storage;
use OpenUGAI::Util::Logger;

our $AssetStorage;
our $AssetLogger;

sub StartUp {
    eval {
	$AssetStorage = &OpenUGAI::AssetServer::Storage::GetInstance();
	$AssetLogger = new OpenUGAI::Util::Logger($OpenUGAI::Global::LOGDIR);
    };
    if ($@) {
	$AssetStorage = undef;
	$AssetLogger = undef;
	Carp::croak("can not start AssetServer: $@");
    }
}

# !!
# TODO: delete asset
#

sub getAsset {
    my ($asset_id, $param) = @_;
    if (!$AssetStorage) {
	OpenUGAI::Util::Log("asset", "startup", "AssetStorage is NULL !!");
	# &StartUp; # avoid infinite loop
    }
    # get asset
    return $AssetStorage->getAsset($asset_id);
}

sub saveAsset {
    my $asset_xml = shift;
    if (!$AssetStorage) {
	OpenUGAI::Util::Log("asset", "startup", "AssetStorage is NULL !!");
	# &StartUp; # avoid infinite loop
    }
    # save asset, they never update asset
    $AssetStorage->saveAsset($asset_xml);
    return "";
    # TODO: temporary solution of "success!"
    # TODO: message for save failed
}

1;

