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
our $Memcached;
our $Instance;

sub StartUp {
    my $config = undef; # TODO @@@ : = OpenUGAI::Config::GetConfig();
    my $file = "/var/www/openugai/perl/trunk/cache_server.list";
    my @memcached_server_list = ();
    open(FILE, $file) || Carp::croak("can not open $file");
    while(<FILE>) {
	chomp;
	push(@memcached_server_list, $_) if ($_);
    }
    close(FILE);
    
    my $options = {
	has_memcached => 1,
	memcached_server_list => \@memcached_server_list,
    };
    
    $Instance = new OpenUGAI::AssetServer();
    $Instance->init($options);
    &OpenUGAI::Util::Log("asset", "init $$", "asset server initialized");
}

sub init {
    my $this = shift;
    my $options = shift;
    # register handlers
    $this->registerHandler( "GET", qr{^/assets/([0-9a-f\-]{36})$}, \&_fetch_asset_handler );
    $this->registerHandler( "POST", qr{^/assets/$}, \&_store_asset_handler );
    $this->registerHandler( "DELETE", qr{^/assets/([0-9a-f\-]{36})$}, \&_delete_asset_handler );

    $this->registerHandler( "POST", qr{^/readsession/(start|stop)/([0-9a-f\-]{36})$}, \&_readsession_handler );
    $this->registerHandler( "GET", qr{^/cache_status$}, \&_get_cache_status_handler );
    # init
    eval {
	$AssetPresentation = new OpenUGAI::AssetServer::Presentation("XML");
	#my $storage_option = {
	#	      "root_dir" => "/tmp/assets",
	#	      "presentation" => $AssetPresentation,
	#	      };
	#$AssetStorage = &OpenUGAI::AssetServer::Storage::GetInstance("File", \%option);
	my $storage_option = {
	    dsn => $OpenUGAI::Global::DSN,
	    user => $OpenUGAI::Global::DBUSER,
	    pass => $OpenUGAI::Global::DBPASS,
	};
	$AssetStorage = &OpenUGAI::AssetServer::Storage::GetInstance("MySQL", $storage_option);
	if ($options && $options->{has_memcached} && $options->{memcached_server_list}) {
	    require 'OpenUGAI/AssetServer/Memcached.pm';
	    &OpenUGAI::Util::Log("asset", "init $$", "Load Memcached");
	    $AssetStorage =
		OpenUGAI::AssetServer::Memcached->new($options->{memcached_server_list}, $AssetStorage);

	}
    };
    if ($@) {
	$AssetStorage = undef;
	$AssetPresentation = undef;
	Carp::croak("can not start AssetServer:\n$@");
	&OpenUGAI::Util::Log("asset", "init $$", "can not start AssetServer:\n$@");
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
	print $cgi->header( -type => 'text/xml', -charset => "utf-8", -status => "404 Not Found" ), "";
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

sub _readsession_handler {
    my ($act, $session_id, $cgi) = @_;
    my $session_file = $OpenUGAI::Global::DATADIR . "/" . $session_id;
    if ($act eq "start") {
	if (!open(FILE, ">$session_file")) {
	    Carp::croak("can not open readsession: " . $session_file);
	    print $cgi->header( -type => 'text/xml', -charset => "utf-8", -status => "403 Forbidden" ), "";
	}
	close(FILE);
    } else { # stop
	if (-e $session_file) {
	    unlink($session_file);
	}
    }
    print $cgi->header( -type => 'text/xml', -charset => "utf-8", -status => "200 OK" ), "OK";
}

sub _get_cache_status_handler {
    my $this = shift;
    my $cgi = shift;
    my $status = $AssetStorage->getCacheStatus;
    print $cgi->header( -type => 'text/html', -charset => "utf-8" ), $status;
}


1;

