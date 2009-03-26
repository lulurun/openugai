use OpenUGAI::Global;
use OpenUGAI::Util;
use OpenUGAI::LoginServer;
use OpenUGAI::UserServer;
use OpenUGAI::GridServer;
use OpenUGAI::AssetServer;
use OpenUGAI::InventoryServer;
require "config.pl";

use LWP::Protocol::http;
@LWP::Protocol::http::EXTRA_SOCK_OPTS = ( SendTE => 0 );

$OpenUGAI::Global::RUNNING_MODE = "mod_perl";

&OpenUGAI::Util::Log("startup", "OpenUGAI init", "Starting OpenUGAI ...");

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
#    &OpenUGAI::AssetServer::StartUp();
}

&OpenUGAI::Util::Log("startup", "OpenUGAI init", "OpenUGAI started ...");

1;

