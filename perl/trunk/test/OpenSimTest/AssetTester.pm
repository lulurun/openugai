package AssetTester;

use strict;
use XML::Serializer;
use OpenUGAI::Utility;

sub init {
	&OpenSimTest::Config::registerHandler("get_asset", \&_get_asset);
}

sub _get_asset {
	my $url = shift || $OpenSimTest::Config::ASSET_SERVER_URL;
	my $asset_id = shift;
	my $res = &OpenUGAI::Utility::HttpRequest("GET", $url . "/assets/" . $asset_id) . "\n";
}

1;
