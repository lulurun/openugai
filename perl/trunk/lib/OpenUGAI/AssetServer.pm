package OpenUGAI::AssetServer;

use strict;
use Carp;
use OpenUGAI::Util;
use OpenUGAI::RestService;
our @ISA = qw(OpenUGAI::RestService);
use OpenUGAI::AssetServer::Storage;
use OpenUGAI::AssetServer::Presentation;

our $AssetStorage;
our $AssetPresentation;

sub init {
    my $this = shift;
    # register handlers
    $this->registerHandler( "GET", qr{^/assets/([0-9a-f\-]{36})$}, \&_fetch_asset_handler );
    $this->registerHandler( "POST", qr{^/assets/([0-9a-f\-]{36})$}, \&_store_asset_handler );
    $this->registerHandler( "DELETE", qr{^/assets/([0-9a-f\-]{36})$}, \&_delete_asset_handler );
    # init
    eval {
	$AssetPresentation = new OpenUGAI::AssetServer::Presentation("XML");
	my %option = (
		      "root_dir" => "/tmp/assets",
		      "presentation" => $AssetPresentation,
		      );
	$AssetStorage = &OpenUGAI::AssetServer::Storage::GetInstance("File", \%option);
    };
    if ($@) {
	$AssetStorage = undef;
	$AssetPresentation = undef;
	Carp::croak("can not start AssetServer:\n$@");
    }
}

sub handler {
    my $this = shift;
    $this->run();
}

# Handler Functions
sub _fetch_asset_handler {
    my $id = shift;
    my $response = "<ERROR />";
    my $asset = $AssetStorage->fetchAsset($id);
    if (!$asset) {
	&OpenUGAI::Util::Log("asset", "postasset_error", $@);	    
    } else {
	$response = $AssetPresentation->serialize($asset);
    }
    &MyCGI::outputXml("utf-8", $response);
}

sub _store_asset_handler {
    my ($id, $cgi) = @_; 
    my $response = "<ERROR />";
    my $data = $cgi->param('POSTDATA');
    my $asset = $AssetPresentation->deserialize($data);
    $response = $AssetStorage->storeAsset($asset);
    &MyCGI::outputXml("utf-8", $response);
}

sub _delete_asset_handler {
    Carp::croak("not implemented");
}

1;

