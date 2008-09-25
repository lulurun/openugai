package OpenUGAI::AssetServer::Storage;

use Carp;
use OpenUGAI::Global;

our $singleton;

sub GetInstance {
    return $singleton if ($singleton);
    my $this = shift;
    if ($OpenUGAI::Global::AssetStorage eq "mysql") {
	require OpenUGAI::AssetServer::Storage::MySQL;
	$singleton = new OpenUGAI::AssetServer::Storage::MySQL();
	return $singleton;
    } elsif ($OpenUGAI::Global::AssetStorage eq "gmail") {
	require OpenUGAI::AssetServer::Storage::Gmail;
	$singleton = new OpenUGAI::AssetServer::Storage::Gmail();
	return $singleton;
    } else {
	Carp::croak("unknown storage engine name");
    }
}

1;

