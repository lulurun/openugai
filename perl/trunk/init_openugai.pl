use OpenUGAI::Global;
use OpenUGAI::UserServer;
use OpenUGAI::GridServer;
use OpenUGAI::AssetServer;
use OpenUGAI::InventoryServer;

$OpenUGAI::Global::RUNNING_MODE = "mod_perl";

{
    my $list = &OpenUGAI::UserServer::getHandlerList();
    foreach (keys %list) {
	$OpenUGAI::Global::HANDLER_LIST{$_} = $list->{$_};
    }
}
{
    my $list = &OpenUGAI::GridServer::getHandlerList();
    foreach (keys %list) {
	$OpenUGAI::Global::HANDLER_LIST{$_} = $list->{$_};
    }
}
{
    my $list = &OpenUGAI::InventoryServer::getHandlerList();
    foreach (keys %list) {
	$OpenUGAI::Global::HANDLER_LIST{$_} = $list->{$_};
    }
}

1;

