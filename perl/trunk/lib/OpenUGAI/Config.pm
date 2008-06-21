package OpenUGAI::Config;

# REGION
our $SIM_RECV_KEY = "null";
our $SIM_SEND_KEY = "null";
# ASSET
#our $ASSET_SERVER_URL = "http://127.0.0.1:8003/";
our $ASSET_SERVER_URL = "http://www.lulu/openugai/perl/trunk/asset.cgi";
our $ASSET_RECV_KEY = "null";
our $ASSET_SEND_KEY = "null";
# USER
#our $USER_SERVER_URL = "http://127.0.0.1:8001/";
our $USER_SERVER_URL = "http://www.lulu/openugai/perl/trunk/user.cgi";
our $USER_RECV_KEY = "null";
our $USER_SEND_KEY = "null";
# GRID
#our $GRID_SERVER_URL = "http://127.0.0.1:8001/";
our $GRID_SERVER_URL = "http://www.lulu/openugai/perl/trunk/grid.cgi";
our $GRID_RECV_KEY = "null";
our $GRID_SEND_KEY = "null";
# INVENTORY
#our $INVENTORY_SERVER_URL = "http://127.0.0.1:8004";
our $INVENTORY_SERVER_URL = "http://www.lulu/openugai/perl/trunk/inventory.cgi";

our $LOGDIR = "/srv/www/htdocs/openugai/perl/trunk/";
our $TMPLDIR = "/srv/www/htdocs/openugai/perl/trunk/template";
our $LOGINKEYDIR = "/srv/www/htdocs/openugai/perl/trunk/loginkey";

1;

