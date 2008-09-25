package OpenUGAI::Global;

our $RUNNING_MODE = "cgi";

# Grid Services Configuration
# REGION
our $SIM_RECV_KEY = "null";
our $SIM_SEND_KEY = "null";
# ASSET
#our $ASSET_SERVER_URL = "http://127.0.0.1:8003/";
our $ASSET_SERVER_URL = "http://openugai.work.lulu/perl/trunk/asset.cgi";
our $ASSET_RECV_KEY = "null";
our $ASSET_SEND_KEY = "null";

our $AssetStorage = "gmail";

# USER
#our $USER_SERVER_URL = "http://127.0.0.1:8001/";
our $USER_SERVER_URL = "http://openugai.work.lulu/perl/trunk/user.cgi";
our $USER_RECV_KEY = "null";
our $USER_SEND_KEY = "null";
# GRID
#our $GRID_SERVER_URL = "http://127.0.0.1:8001/";
our $GRID_SERVER_URL = "http://openugai.work.lulu/perl/trunk/grid.cgi";
our $GRID_RECV_KEY = "null";
our $GRID_SEND_KEY = "null";
# INVENTORY
#our $INVENTORY_SERVER_URL = "http://127.0.0.1:8004";
our $INVENTORY_SERVER_URL = "http://openugai.work.lulu/perl/trunk/inventory.cgi";

# Directory Configuration
our $LOGDIR = "/srv/www/openugai/perl/trunk/";
our $TMPLDIR = "/srv/www/openugai/perl/trunk/template";
our $LOGINKEYDIR = "/srv/www/openugai/perl/trunk/loginkey";

# DB Settings
our $DSN = "dbi:mysql:openugai;host=localhost;";
our $DBUSER = "opensim";
our $DBPASS = "opensim";

# Global Vars
our %Handlerlist = ();

1;

