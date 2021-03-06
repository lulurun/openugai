# this file can be used to overwrite the defualt configuration

use OpenUGAI::Global;

my $base_url = "http://openugai.wolfdrawer.net/perl/trunk";
my $base_path = "/var/www/openugai";

# grid services
$OpenUGAI::Global::USER_SERVER_URL = $base_url . "/user.cgi";
$OpenUGAI::Global::GRID_SERVER_URL = $base_url . "/grid.cgi";
$OpenUGAI::Global::ASSET_SERVER_URL = $base_url . "/asset.cgi";
$OpenUGAI::Global::INVENTORY_SERVER_URL = $base_url . "/inventory.cgi";

# log files
$OpenUGAI::Global::LOGDIR = $base_path . "/logs";
$OpenUGAI::Global::TMPLDIR = $base_path . "/perl/trunk/template";
$OpenUGAI::Global::LOGINKEYDIR = $base_path . "/loginkey";
$OpenUGAI::Global::DATADIR = $base_path . "/data";

# db settings
$OpenUGAI::Global::DSN = "dbi:mysql:opensim;host=localhost;";
$OpenUGAI::Global::DBUSER = "lulu";
$OpenUGAI::Global::DBPASS = "1u1urun";

# ##########
$OpenUGAI::Global::ASSET_STORAGE = "mysql";

1;

