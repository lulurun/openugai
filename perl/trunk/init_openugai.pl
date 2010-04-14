use OpenUGAI::Global;
use OpenUGAI::LoginServer;
use OpenUGAI::UserServer;
use OpenUGAI::GridServer;
use OpenUGAI::GridServer2;
use OpenUGAI::AssetServer;
use OpenUGAI::InventoryServer;
use OpenUGAI::AvatarSelectorServer;
use OpenUGAI::SpaceWeb;
require "config.pl";

use LWP::Protocol::http;
@LWP::Protocol::http::EXTRA_SOCK_OPTS = ( SendTE => 0 );
$OpenUGAI::Global::RUNNING_MODE = "mod_perl";

Apache2::ServerRec::warn("Starting OpenUGAI ...");

# login server
{
    &OpenUGAI::LoginServer::StartUp();
}
# user server
{ 
    &OpenUGAI::UserServer::StartUp();
}
# grid server
{
    &OpenUGAI::GridServer::StartUp();
}
# inventory server
{
    &OpenUGAI::InventoryServer::StartUp();
}
# asset server
{
    &OpenUGAI::AssetServer::StartUp();
}
# avatarselector server
{
    &OpenUGAI::AvatarSelectorServer::StartUp();
}
# grid2 server
{
    &OpenUGAI::GridServer2::StartUp();
}
# spaceweb
{
    &OpenUGAI::SpaceWeb::StartUp();
}

Apache2::ServerRec::warn("Starting OpenUGAI ...");

1;

