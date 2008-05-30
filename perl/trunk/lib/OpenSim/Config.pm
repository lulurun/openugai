package OpenSim::Config;

# REGION
our $SIM_RECV_KEY = "";
our $SIM_SEND_KEY = "";
# ASSET
#our $ASSET_SERVER_URL = "http://127.0.0.1:8003/";
our $ASSET_SERVER_URL = "http://opensim.wolfdrawer.net:80/asset.cgi";
our $ASSET_RECV_KEY = "";
our $ASSET_SEND_KEY = "";
# USER
#our $USER_SERVER_URL = "http://127.0.0.1:8001/";
our $USER_SERVER_URL = "http://opensim.wolfdrawer.net:80/user.cgi";
our $USER_RECV_KEY = "";
our $USER_SEND_KEY = "";
# GRID
#our $GRID_SERVER_URL = "http://127.0.0.1:8001/";
our $GRID_SERVER_URL = "http://opensim.wolfdrawer.net:80/grid.cgi";
our $GRID_RECV_KEY = "";
our $GRID_SEND_KEY = "";
# INVENTORY
#our $INVENTORY_SERVER_URL = "http://127.0.0.1:8004";
our $INVENTORY_SERVER_URL = "http://opensim.wolfdrawer.net:80/inventory.cgi";

our $LOGDIR = "/srv/www/opensim";
our $TMPLDIR = "/srv/www/opensim/template";
our $LOGINKEYDIR = "/srv/www/opensim/loginkey";

1;

