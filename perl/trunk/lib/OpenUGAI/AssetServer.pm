package OpenUGAI::AssetServer;

use strict;
use Carp;
use OpenUGAI::Util;
use OpenUGAI::RestService;
our @ISA = qw(OpenUGAI::RestService);
use OpenUGAI::AssetServer::Storage;
use OpenUGAI::AssetServer::Presentation;
use OpenUGAI::Global;

our $AssetStorage;
our $AssetPresentation;

sub init {
    my $this = shift;
    # register handlers
    $this->registerHandler( "GET", qr{^/assets/([0-9a-f\-]{36})$}, \&_fetch_asset_handler );
    $this->registerHandler( "POST", qr{^/assets/$}, \&_store_asset_handler );
    $this->registerHandler( "DELETE", qr{^/assets/([0-9a-f\-]{36})$}, \&_delete_asset_handler );
    # init
    eval {
	$AssetPresentation = new OpenUGAI::AssetServer::Presentation("XML");
	#my %option = (
	#	      "root_dir" => "/tmp/assets",
	#	      "presentation" => $AssetPresentation,
	#	      );
	#$AssetStorage = &OpenUGAI::AssetServer::Storage::GetInstance("File", \%option);
	my $option = {
	    dsn => $OpenUGAI::Global::DSN,
	    user => $OpenUGAI::Global::DBUSER,
	    pass => $OpenUGAI::Global::DBPASS,
	};
	$AssetStorage = &OpenUGAI::AssetServer::Storage::GetInstance("MySQL", $option);
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
    my ($id, $cgi) = @_;
    my $response = "<ERROR />";
    my $asset = $AssetStorage->fetchAsset($id);
    if (!$asset) {
	# log asset not found
    } else {
	$response = $AssetPresentation->serialize($asset);
    }
    print $cgi->header( -type => 'text/xml', -charset => "utf-8" ), $response;
}

sub _store_asset_handler {
    my ($id, $cgi) = @_; 
    my $response = "<ERROR />";
    my $data = $cgi->param('POSTDATA');
    my $asset = $AssetPresentation->deserialize($data);
    $response = $AssetStorage->storeAsset($asset);
    print $cgi->header( -type => 'text/xml', -charset => "utf-8" ), $response;
}

sub _delete_asset_handler {
    Carp::croak("not implemented");
}

1;

