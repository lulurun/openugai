# this file can be used to overwrite the defualt configuration

use OpenUGAI::Global;

# grid services
$OpenUGAI::Global::USER_SERVER_URL = "http://openugai.wolfdrawer.net/perl/trunk/user.cgi";
$OpenUGAI::Global::GRID_SERVER_URL = "http://openugai.wolfdrawer.net/perl/trunk/grid.cgi";
$OpenUGAI::Global::ASSET_SERVER_URL = "http://openugai.wolfdrawer.net/perl/trunk/asset.cgi";
$OpenUGAI::Global::INVENTORY_SERVER_URL = "http://openugai.wolfdrawer.net/perl/trunk/inventory.cgi";

# log files
$OpenUGAI::Global::LOGDIR = "/srv/www/openugai/logs";
$OpenUGAI::Global::TMPLDIR = "/srv/www/openugai/perl/trunk/template";
$OpenUGAI::Global::LOGINKEYDIR = "/srv/www/openugai/perl/trunk/loginkey";

# db settings
$OpenUGAI::Global::DSN = "dbi:mysql:openugai;host=localhost;";
$OpenUGAI::Global::DBUSER = "opensim";
$OpenUGAI::Global::DBPASS = "opensim";


1;

