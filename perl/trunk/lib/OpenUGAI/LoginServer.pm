package OpenUGAI::LoginServer;

use strict;
use Storable;
use Digest::MD5;
use Carp;

use OpenUGAI::Global;
use OpenUGAI::Util;
use OpenUGAI::UserServer::Config;
use OpenUGAI::Data::Users;
use OpenUGAI::Data::Agents;
# OpenID
use CGI;
use LWPx::ParanoidAgent;
use Net::OpenID::Consumer;

sub getHandlerList {
    my %list = (
	"login_to_simulator" => \&_login_to_simulator,
	);
    return \%list;
}

# ##################
# OpenID authentication request
sub OpenIDRequestHandler {
    my $param = shift;
    my $openid = $param->{openid_identifier};
    my $csr = new Net::OpenID::Consumer(
					ua    => new LWPx::ParanoidAgent(),
					args  => new CGI, # TODO: should be $param
					consumer_secret => $OpenUGAI::Global::OPENID_CONSUMER_SECRET,
					);

    my $claimed_identity = $csr->claimed_identity($openid);
    &OpenUGAI::Util::Log("login", "cident", Data::Dump::dump($claimed_identity));
    &OpenUGAI::Util::Log("login", "cident->version", $claimed_identity->protocol_version);
    if (!$claimed_identity) {
	Carp::croak("not a valid openid");
    }
    # sreg
    #$claimed_identity->set_extension_args(
    #				  $OpenUGAI::Global::OPENID_NS_SREG_1_1,
    #				  {
    #				      required => 'nickname',
    #				  },
    #				  );
    # ax
    $claimed_identity->set_extension_args(
					  $OpenUGAI::Global::OPENID_NS_AX_1_0,
					  {
					      mode => 'fetch_request',
					      "type.nickname" => "http://schema.openid.net/namePerson/friendly",
					      "type.email" => "http://schema.openid.net/contact/email",
					      if_available => 'nickname,email',
					  },
					  );

    my $check_url = $claimed_identity->check_url(
						 return_to  => $OpenUGAI::Global::OPENID_RETURN_TO_URL,
						 trust_root => $OpenUGAI::Global::OPENID_TRUST_ROOT_URL,
						 );
    &OpenUGAI::Util::Log("login", "check_url", $check_url);
    #&MyCGI::redirect($check_url);
    return wantarray ? ["redirect", $check_url] : $check_url;
}

# ##################
# OpenID authentication verification
sub OpenIDVerifyHandler {
    my $param = shift;
    my $csr = new Net::OpenID::Consumer(
					ua    => new LWPx::ParanoidAgent(),
					args  => new CGI, # TODO: should be $param
					consumer_secret => $OpenUGAI::Global::OPENID_CONSUMER_SECRET,
					);

    $csr->handle_server_response(
				 not_openid => sub {
				     Carp::croak("Not an OpenID message");
				 },
				 setup_required => sub {
				     my $setup_url = shift;
				     # Redirect the user to $setup_url
				     #&MyCGI::redirect($setup_url);				     
                                     return wantarray ? ("redirect", $setup_url) : $setup_url;
				 },
				 cancelled => sub {
				     # Do something appropriate when the user hits "cancel" at the OP
				 },
				 verified => sub {
				     my $vident = shift;
				     # Do something with the VerifiedIdentity object $vident
				     return wantarray ? ("output", $vident) : $vident;
				 },
				 error => sub {
				     my $err = shift;
				     Carp::croak($err);
				 },
				 );
}

# ##################
# shared method
sub Authenticate {
    my $params = shift;
    my $user = &OpenUGAI::Data::Users::getUserByName($params->{first}, $params->{last});
    my $login_pass = $params->{passwd};
    $login_pass =~ s/^\$1\$//;
    if ($user->{passwordHash} ne Digest::MD5::md5_hex($login_pass . ":")) {
	return 0;
    }
    if ($params->{weblogin}) {
	my $key = &OpenUGAI::Util::GenerateUUID();
	Storable::store($user, $OpenUGAI::Global::LOGINKEYDIR . "/" . $key);
	return $key;
    } else {
	return $user;
    }
}

# #################
# Handlers
sub _login_to_simulator {
    my $params = shift;
    # check params
    if (!$params->{first} || !$params->{last}) {
	return &_make_false_response("not enough params", "You must have been eaten by a wolf");
    }
    # get the user (check passwd or from a saved webloginkey)
    my $user = undef;
    if ($params->{passwd}) {
	$user = &Authenticate($params);
    } elsif ($params->{web_login_key}) {
	my $key = $OpenUGAI::Global::LOGINKEYDIR . "/" . $params->{web_login_key} || "unknown";
	$user = Storable::retrieve($key);
	unlink($key);
    } else {
	return &_make_false_response("not enough params", "You must have been eaten by a wolf");    
    }
    if (!$user) {
	return &_make_false_response("password not match", "Late! There is a wolf behind you");
    }
    # check other online agent
    my $agent = &OpenUGAI::Data::Agents::SelectAgent($user->{UUID});
    if ($agent && $agent->{agentOnline}) {
	# try to notify the online user agent
	&OpenUGAI::Data::Agents::SetOnlineStatus($user->{UUID}, 0);
	return &_make_false_response(
	    "presence",
	    "You appear to be already logged in. " .
	    "If this is not the case please wait for your session to timeout. " .
	    "If this takes longer than a few minutes please contact the grid owner. " .
	    "Please wait 5 minutes if you are going to connect to a region nearby to" .
	    "the region you were at previously."
	    );
    }
    # get start region / location
    my $region_handle;
    my @start_location;
    my @start_lookat;
    if ($params->{start} eq "last") {
	if ($agent->{currentHandle}) {
	    $region_handle = $agent->{currentHandle};
	} else {
	    $region_handle = $user->{homeRegion};	    
	}
	if ($agent->{currentPos} =~ /<([\d\.]+),([\d\.]+),([\d\.]+)>/) {
	    @start_location = ($1, $2, $3);
	} else {
	    @start_location = ($user->{homeLocationX}, $user->{homeLocationY}, $user->{homeLocationZ});
	}
	if ($agent->{currentLookAt} =~ /<([\d\.]+),([\d\.]+),([\d\.]+)>/) {
	    @start_lookat = ($1, $2, $3);
	} else {
	    @start_lookat = ($user->{homeLookAtX}, $user->{homeLookAtY}, $user->{homeLookAtZ});
	}
    } elsif ($params->{start} eq "home") {
	$region_handle = $user->{homeRegion};
	@start_location = ($user->{homeLocationX}, $user->{homeLocationY}, $user->{homeLocationZ});
	@start_lookat = ($user->{homeLookAtX}, $user->{homeLookAtY}, $user->{homeLookAtZ});
    } else {
	# url login; # TODO @@@ parse opensim url
	$region_handle = $user->{homeRegion};
	@start_location = ($user->{homeLocationX}, $user->{homeLocationY}, $user->{homeLocationZ});
	@start_lookat = ($user->{homeLookAtX}, $user->{homeLookAtY}, $user->{homeLookAtZ});
    }
    # contact with Grid server
    my %grid_request_params = (
	region_handle => $region_handle,
	authkey => undef
	);
    my $grid_response = &OpenUGAI::Util::XMLRPCCall($OpenUGAI::Global::GRID_SERVER_URL, "simulator_data_request", \%grid_request_params);
    if (!$grid_response || $grid_response->{error}) {
	# TODO @@@ do not report "can not", instead, drive agent to a living sim
	return &_make_false_response("can not login", "requested region server is not alive -" . $grid_response->{error} . "-");
    }
    my $region_server_url = "http://" . $grid_response->{sim_ip} . ":" . $grid_response->{sim_port};
    my $internal_server_url = $grid_response->{internal_server_url}; # TODO: hack for regionservers behind a router
    # contact with Region server
    my $session_id = &OpenUGAI::Util::GenerateUUID;
    my $secure_session_id = &OpenUGAI::Util::GenerateUUID;
    my $circuit_code = int(rand() * 1000000000); # just a random integer
    my $caps_id = &OpenUGAI::Util::GenerateUUID;
    my %region_request_params = (
	session_id => $session_id,
	secure_session_id => $secure_session_id,
	firstname => $user->{username},
	lastname => $user->{lastname},
	agent_id => $user->{UUID},
	circuit_code => $circuit_code,
	startpos_x => $start_location[0],
	startpos_y => $start_location[1],
	startpos_z => $start_location[2],
	regionhandle => $region_handle,
	caps_path => $caps_id,
	user_server_url => "http://192.168.0.150/perl/trunk/user.cgi", # TODO: @@@ read from config
	);
    # TODO: using $internal_server_url is a temporary solution
    &OpenUGAI::Util::Log("user", "expect_user", Data::Dump::dump(\%region_request_params));
    &OpenUGAI::Util::Log("user", "internal_server", $internal_server_url);
    my $region_response = undef;
    eval {
    	$region_response = &OpenUGAI::Util::XMLRPCCall($internal_server_url, "expect_user", \%region_request_params);
    };
    if ($@) {
	return &_make_false_response("can not login", "failed to call expect_user: $@");
    }
    # make agent data at this point
    $agent->{UUID} = $user->{UUID};
    $agent->{sessionID} = $session_id;
    $agent->{secureSessionID} = $secure_session_id;
    $agent->{loginTime} = time;
    $agent->{currentRegion} = $grid_response->{region_UUID};
    $agent->{currentHandle} = $grid_response->{regionHandle};
    $agent->{currentPos} = "<$start_location[0],$start_location[1],$start_location[2]>";
    $agent->{currentLookAt} = "<$start_lookat[0],$start_lookat[1],$start_lookat[2]>";
    $agent->{agentOnline} = 1;
    $agent->{logoutTime} = 0;
    $agent->{agentIP} = "";  # TODO @@@ 
    $agent->{agentPort} = 0; # TODO @@@
    &OpenUGAI::Data::Agents::AgentLogon($agent);    
    # contact with Inventory server
    my $inventory_data = &_create_inventory_data($user->{UUID});
    # return to client
    my %response = (
	# login info
	login => "true",
	session_id => $session_id,
	secure_session_id => $secure_session_id,
	# agent
	first_name => $user->{username},
	last_name => $user->{lastname},
	agent_id => $user->{UUID},
	agent_access => "M", # ??? from linden => M & hard coding in opensim
	# grid
	start_location => $params->{start},
	sim_ip => $grid_response->{sim_ip},
	sim_port => $grid_response->{sim_port},
	#sim_port => 9001, # TODO: hack for testing another region server
	region_x => $grid_response->{region_locx} * 256,
	region_y => $grid_response->{region_locy} * 256,
	# other
	inventory_host => undef, # inv13-mysql
	circuit_code => $circuit_code,
	message => "Do you fear the wolf ?",
	seconds_since_epoch => time,
	seed_capability => $region_server_url . "/CAPS/" . $caps_id . "0000/", # https://sim2734.agni.lindenlab.com:12043/cap/61d6d8a0-2098-7eb4-2989-76265d80e9b6
	look_at => &_make_r_string($start_lookat[0], $start_lookat[1], $start_lookat[2]),
	home => &_make_home_string(
	    [ $grid_response->{region_locx} * 256, $grid_response->{region_locy} * 256 ],
	    [ $start_location[0], $start_location[1], $start_location[2] ],
	    [ $start_lookat[0], $start_lookat[1], $start_lookat[2] ]),
	"inventory-skeleton" => $inventory_data->{InventoryArray},
	"inventory-root" => [ { folder_id => $inventory_data->{RootFolderID} } ],
	"event_notifications" => \@OpenUGAI::UserServer::Config::event_notifications,
	"event_categories" => \@OpenUGAI::UserServer::Config::event_categories,
	"global-textures" => \@OpenUGAI::UserServer::Config::global_textures,
	"inventory-lib-owner" => \@OpenUGAI::UserServer::Config::inventory_lib_owner,
	"inventory-skel-lib" => \@OpenUGAI::UserServer::Config::inventory_skel_lib, # hard coding in OpenUGAI
	"inventory-lib-root" => \@OpenUGAI::UserServer::Config::inventory_lib_root,
	"classified_categories" => \@OpenUGAI::UserServer::Config::classified_categories,
	"login-flags" => \@OpenUGAI::UserServer::Config::login_flags,
	"initial-outfit" => \@OpenUGAI::UserServer::Config::initial_outfit,
	"gestures" => \@OpenUGAI::UserServer::Config::gestures,
	"ui-config" => \@OpenUGAI::UserServer::Config::ui_config,
	);
    return \%response;
}

# #################
# sub functions
sub _create_inventory_data {
    my $user_id = shift;
    my $postdata =<< "POSTDATA";
<?xml version="1.0" encoding="utf-8"?><guid>$user_id</guid>
POSTDATA
    # TODO:
    my $res = undef;
    eval {
    	$res = &OpenUGAI::Util::HttpRequest("POST", $OpenUGAI::Global::INVENTORY_SERVER_URL . "/RootFolders/", $postdata);
    };
    if ($@) {
    	Carp::croak($@);
    }
    my $res_obj = &OpenUGAI::Util::XML2Obj($res);
    
#    if (!$res_obj->{InventoryFolderBase}) {
#	&OpenUGAI::Util::HttpPostRequest($OpenUGAI::Config::INVENTORY_SERVER_URL . "/CreateInventory/", $postdata);
#	# Sleep(10000); # TODO: need not to do this
#	$res = &OpenUGAI::Util::HttpPostRequest($OpenUGAI::Config::INVENTORY_SERVER_URL . "/RootFolders/", $postdata);
#	$res_obj = &OpenUGAI::Util::XML2Obj($res);
#   }
    
    my $folders = $res_obj->{InventoryFolderBase};
    my $folders_count = @$folders;
    if ($folders_count > 0) {
	my @AgentInventoryFolders = ();
	my $root_uuid = &OpenUGAI::Util::ZeroUUID();
	foreach my $folder (@$folders) {
	    if ($folder->{ParentID}->{Guid} eq &OpenUGAI::Util::ZeroUUID()) {
		$root_uuid = $folder->{ID}->{Guid};
	    }
	    my %folder_hash = (
		name => $folder->{Name},
		parent_id => $folder->{ParentID}->{Guid},
		version => $folder->{Version},
		type_default => $folder->{Type},
		folder_id => $folder->{ID}->{Guid},
		);
	    push @AgentInventoryFolders, \%folder_hash;
	}
	return { InventoryArray => \@AgentInventoryFolders, RootFolderID => $root_uuid };
    } else {
	# TODO: impossible ???
    }
    return undef;
}

sub _convert_to_response {
    my $user = shift;
    my %response = (
	firstname => $user->{username},
	lastname => $user->{lastname},
	uuid => $user->{UUID},
	server_inventory => $user->{userInventoryURI},
	server_asset => $user->{userAssetURI},
	profile_about => $user->{profileAboutText},
	profile_firstlife_about => $user->{profileFirstText},
	profile_firstlife_image => $user->{profileFirstImage},
	profile_can_do => $user->{profileCanDoMask} || "0",
	profile_want_do => $user->{profileWantDoMask} || "0",
	profile_image => $user->{profileImage},
	profile_created => $user->{created},
	profile_lastlogin => $user->{lastLogin} || "0",
	home_coordinates_x => $user->{homeLocationX},
	home_coordinates_y => $user->{homeLocationY},
	home_coordinates_z => $user->{homeLocationZ},
	home_region => $user->{homeRegion} || 0,
	home_look_x => $user->{homeLookAtX},
	home_look_y => $user->{homeLookAtY},
	home_look_z => $user->{homeLookAtZ},
	);
    # TODO: OpenSim should handle this
    foreach(keys %response) {
	$response{$_} = RPC::XML::string->new( $response{$_} );
    }    
    return \%response;
}

# #################
# Util Functions
sub _make_false_response {
    my ($reason, $message) = @_;
    return { reason => $reason, login => "false", message => $message };
}

sub _make_error_response {
    my ($err_type, $err_desc) = @_;
    return { error_type => $err_type, error_desc => $err_desc };
}

sub _unknown_user_response {
    return {
	error_type => "unknown_user",
	error_desc => "The user requested is not in the database",
    };
}

sub _make_home_string {
    my ($region_handle, $position, $look_at) = @_;
    my $region_handle_string = "'region_handle':" . &_make_r_string(@$region_handle);
    my $position_string = "'position':" . &_make_r_string(@$position);
    my $look_at_string = "'look_at':" . &_make_r_string(@$look_at);
    return "{" . $region_handle_string . ", " . $position_string . ", " . $look_at_string . "}";
}

sub _make_r_string {
    my @params = @_;
    foreach (@params) {
	$_ = "r" . $_;
    }
    return "[" . join(",", @params) . "]";
}

# #################
# OpenID Function
sub _check_openid_param {
    my $params = shift;
    # @@@ not implemented
    return 1;
}

sub OpenID_PRELogin
{
    my $params = shift;
    my %response = ();
    # openid param validation
    if (!&_check_openid_param($params)) {
	$response{error} = "invalid openid parameter";
	return \%response;
    }
    # select user (check existence of the user)
    my $user = undef;
    eval {
	$user = &OpenUGAI::Data::Users::getUserByName($params->{first}, $params->{last});
    };
    if ($@) {
	$response{error} = $@; # will be redirect to user login page
	return \%response;
    }
    
    # contact with Grid server
    my %grid_request_params = (
	region_handle => $user->{homeRegion},
	authkey => undef
	);
    my $grid_response = &OpenUGAI::Util::XMLRPCCall($OpenUGAI::Global::GRID_SERVER_URL, "simulator_data_request", \%grid_request_params);
    my $region_server_url = "http://" . $grid_response->{sim_ip} . ":" . $grid_response->{sim_port};
    # contact with Region server
    my $session_id = &OpenUGAI::Util::GenerateUUID;
    my $secure_session_id = &OpenUGAI::Util::GenerateUUID;
    my $circuit_code = int(rand() * 1000000000); # just a random integer
    my $caps_id = &OpenUGAI::Util::GenerateUUID;
    my %region_request_params = (
	session_id => $session_id,
	secure_session_id => $secure_session_id,
	firstname => $user->{username},
	lastname => $user->{lastname},
	agent_id => $user->{UUID},
	circuit_code => $circuit_code,
	startpos_x => $user->{homeLocationX},
	startpos_y => $user->{homeLocationY},
	startpos_z => $user->{homeLocationZ},
	regionhandle => $user->{homeRegion},
	caps_path => $caps_id,
	);
    my $region_response = &OpenUGAI::Util::XMLRPCCall($region_server_url, "expect_user", \%region_request_params);
    # contact with Inventory server
    my $inventory_data = &_create_inventory_data($user->{UUID});
    # return to client
    %response = (
	# login info
	login => "true",
	session_id => $session_id,
	secure_session_id => $secure_session_id,
	# agent
	first_name => $user->{username},
	last_name => $user->{lastname},
	agent_id => $user->{UUID},
	agent_access => "M", # ??? from linden => M & hard coding in opensim
	# grid
	start_location => $params->{start},
	sim_ip => $grid_response->{sim_ip},
	sim_port => $grid_response->{sim_port},
	#sim_port => 9001,
	region_x => $grid_response->{region_locx} * 256,
	region_y => $grid_response->{region_locy} * 256,
	# other
	inventory_host => undef, # inv13-mysql
	circuit_code => $circuit_code,
	message => "Do you fear the wolf ?",
	seconds_since_epoch => time,
	seed_capability => $region_server_url . "/CAPS/" . $caps_id . "0000/", # https://sim2734.agni.lindenlab.com:12043/cap/61d6d8a0-2098-7eb4-2989-76265d80e9b6
	look_at => &_make_r_string($user->{homeLookAtX}, $user->{homeLookAtY}, $user->{homeLookAtZ}),
	home => &_make_home_string(
	    [$grid_response->{region_locx} * 256, $grid_response->{region_locy} * 256],
	    [$user->{homeLocationX}, $user->{homeLocationY}, $user->{homeLocationX}],
	    [$user->{homeLookAtX}, $user->{homeLookAtY}, $user->{homeLookAtZ}]),
	"inventory-skeleton" => $inventory_data->{InventoryArray},
	"inventory-root" => [ { folder_id => $inventory_data->{RootFolderID} } ],
	"event_notifications" => \@OpenUGAI::UserServer::Config::event_notifications,
	"event_categories" => \@OpenUGAI::UserServer::Config::event_categories,
	"global-textures" => \@OpenUGAI::UserServer::Config::global_textures,
	"inventory-lib-owner" => \@OpenUGAI::UserServer::Config::inventory_lib_owner,
	"inventory-skel-lib" => \@OpenUGAI::UserServer::Config::inventory_skel_lib, # hard coding in OpenUGAI
	"inventory-lib-root" => \@OpenUGAI::UserServer::Config::inventory_lib_root,
	"classified_categories" => \@OpenUGAI::UserServer::Config::classified_categories,
	"login-flags" => \@OpenUGAI::UserServer::Config::login_flags,
	"initial-outfit" => \@OpenUGAI::UserServer::Config::initial_outfit,
	"gestures" => \@OpenUGAI::UserServer::Config::gestures,
	"ui-config" => \@OpenUGAI::UserServer::Config::ui_config,
	);
    return \%response;
}

1;

