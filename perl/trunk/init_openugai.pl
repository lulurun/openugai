use OpenUGAI::Global;
use OpenUGAI::Util;
use OpenUGAI::UserServer;
use OpenUGAI::GridServer;
use OpenUGAI::AssetServer;
use OpenUGAI::InventoryServer;
require "config.pl";

$OpenUGAI::Global::RUNNING_MODE = "mod_perl";

&OpenUGAI::Util::Log("startup", "OpenUGAI init", "Starting OpenUGAI ...");

# user server
{
    my $list = &OpenUGAI::UserServer::getHandlerList();
    foreach (keys %list) {
	$OpenUGAI::Global::HANDLER_LIST{$_} = $list->{$_};
    }
}
# grid server
{
    my $list = &OpenUGAI::GridServer::getHandlerList();
    foreach (keys %list) {
	$OpenUGAI::Global::HANDLER_LIST{$_} = $list->{$_};
    }
}
# inventory server
{
    my $list = &OpenUGAI::InventoryServer::getHandlerList();
    foreach (keys %list) {
	$OpenUGAI::Global::HANDLER_LIST{$_} = $list->{$_};
    }
}
# asset server
{
    &OpenUGAI::AssetServer::StartUp();
}

&OpenUGAI::Util::Log("startup", "OpenUGAI init", "OpenUGAI started ...");

1;

