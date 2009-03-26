package OpenUGAI::AssetServer::Storage;

use Carp;

our $singleton;

sub GetInstance {
    return $singleton if ($singleton);
    my ($storage_engine, $options) = @_;
    if ($storage_engine eq "MySQL") {
	require OpenUGAI::AssetServer::Storage::MySQL;
	$singleton = new OpenUGAI::AssetServer::Storage::MySQL($options);
    } elsif ($storage_engine eq "File") {
	require OpenUGAI::AssetServer::Storage::FS;
	$singleton = new OpenUGAI::AssetServer::Storage::FS($options);
    } elsif ($storage_engine eq "Gmail") {
	require OpenUGAI::AssetServer::Storage::Gmail;
	$singleton = new OpenUGAI::AssetServer::Storage::Gmail($options);
    } elsif ($storage_engine eq "Amazon") {
	require OpenUGAI::AssetServer::Storage::Amazon;
	$singleton = new OpenUGAI::AssetServer::Storage::Amazon($options);
    } else {
	Carp::croak("unknown storage engine name");
    }
    return $singleton;
}

1;

