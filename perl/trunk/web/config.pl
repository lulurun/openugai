use OpenUGAI::Global;

$OpenUGAI::Global::BASE_DIR = "/var/www/openugai/perl/trunk";
$OpenUGAI::Global::BASE_URL = "http://openugai.wolfdrawer.net";

# grid services
$OpenUGAI::Global::USER_SERVER_URL = $OpenUGAI::Global::BASE_DIR . "/user.cgi";
$OpenUGAI::Global::GRID_SERVER_URL = $OpenUGAI::Global::BASE_DIR . "/grid.cgi";
$OpenUGAI::Global::ASSET_SERVER_URL = $OpenUGAI::Global::BASE_DIR . "/asset.cgi";
$OpenUGAI::Global::INVENTORY_SERVER_URL = $OpenUGAI::Global::BASE_DIR . "/inventory.cgi";

# DIRs
$OpenUGAI::Global::LOGDIR = $OpenUGAI::Global::BASE_DIR . "/logs";
$OpenUGAI::Global::TMPLDIR = $OpenUGAI::Global::BASE_DIR . "/template";
$OpenUGAI::Global::LOGINKEYDIR = $OpenUGAI::Global::BASE_DIR . "/loginkey";
$OpenUGAI::Global::DATADIR = $OpenUGAI::Global::BASE_DIR . "/data";
$OpenUGAI::Global::WEBDIR = $OpenUGAI::Global::BASE_DIR . "/web";

$OpenUGAI::Global::Region_DIR = $OpenUGAI::Global::DATADIR . "/Regions";
$OpenUGAI::Global::Contents_DIR = $OpenUGAI::Global::WEBDIR . "/Contents";
$OpenUGAI::Global::Contents_URL = $OpenUGAI::Global::BASE_URL . "/Contents";

# db settings
$OpenUGAI::Global::DSN = "dbi:mysql:space;host=localhost;";
$OpenUGAI::Global::DBUSER = "lulu";
$OpenUGAI::Global::DBPASS = "1u1urun";

# ##########
$OpenUGAI::Global::ASSET_STORAGE = "mysql";

1;

