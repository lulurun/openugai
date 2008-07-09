package OpenUGAI::UserServer;

use strict;
use OpenUGAI::Config;
use OpenUGAI::Utility;
use OpenUGAI::UserServer::Config;
use OpenUGAI::UserServer::UserManager;
use OpenUGAI::Data::Avatar;
use Digest::MD5;
use Storable;

sub getHandlerList {
    my %list = (
		"login_to_simulator" => \&_login_to_simulator,
		"logout_of_simulator" => \&_logout_of_simulator,
		"get_user_by_name" => \&_get_user_by_name,
		"get_user_by_uuid" => \&_get_user_by_uuid,
		"get_avatar_picker_avatar" => \&_get_avatar_picker_avatar,
		"get_avatar_appearance" => \&_get_avatar_appearance, # @@@ TODO: this method should be moved to inventory service or implemented in the hell.
		"update_user_current_region" => \&_update_user_current_region,
	);
    return \%list;
}

# ##################
#
sub Authenticate {
    my $params = shift;
    my $user = &OpenUGAI::UserServer::UserManager::getUserByName($params->{first}, $params->{last});
    my $login_pass = $params->{passwd};
    $login_pass =~ s/^\$1\$//;
    if ($user->{passwordHash} ne Digest::MD5::md5_hex($login_pass . ":")) {
		return 0;
    }
    if ($params->{weblogin}) {
		my $key = &OpenUGAI::Utility::GenerateUUID();
		Storable::store($user, $OpenUGAI::Config::LOGINKEYDIR . "/" . $key);
		return $key;
    } else {
		return $user;
    }
}

sub LogOffUser {
	my ($avatar_id, $region_id, $region_handle, $posx, $posy, $posz) = @_;
	
}

# #################
# Handlers
sub _logout_of_simulator {
	my $params = shift;
	# TODO @@@ inform message server
	if ($params->{avatar_uuid} && $params->{region_uuid} && $params->{region_handle}) {
		my $posx = $params->{region_pos_x} || 128;
		my $posy = $params->{region_pos_y} || 128;
		my $posz = $params->{region_pos_z} || 128;
		&LogoffUser($params->{avatar_uuid}, $params->{region_uuid}, $params->{region_handle}, $posx, $posy, $posz);
	} else {
	    return &_unknown_user_response; # TODO @@@ shoule be a "not enough params" error
	}
}

sub _update_user_current_region {
	my $params = shift;

	my $returnString = "FALSE";
	if ($params->{avatar_uuid}) {
		my $profile = &OpenUGAI::UserServer::UserManager::getUserProfile($params->{avatar_uuid});
		if ($profile->{CurrentAgent}) {
			$profile->{CurrentAgent}->{Region} = $params->{region_uuid} || &OpenUGAI::Utility::ZeroUUID();
			$profile->{CurrentAgent}->{Handle} = $params->{region_handle} || "1099511628032000"; # TODO @@@ use a default variable
		} else {
			; # TODO @@@ ???
		}
		&OpenUGAI::UserServer::UserManager::commitUserAgent($profile);
	} else {
		; # TODO @@@ just follow what opensim dose, but not good.
	}
	my %response = (
		returnString => $returnString,
	);
	return \%response;
}

sub _commit_agent{
	my $profile = shift;
}

sub _get_avatar_appearance {
    my $params = shift;
    if (!$params->{owner}) {
	return &_make_false_response("not enough params", "You must have been eaten by a wolf - onwer needed");
    }
    my $owner = $params->{owner};
    my $appearance = undef;
    eval {
	$appearance = &OpenUGAI::Data::Avatar::SelectAppearance($owner);
    };
    if ($@) {
	return &_make_false_response("can not get appearance", $@);
    }
    return $appearance;
}

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
		my $key = $OpenUGAI::Config::LOGINKEYDIR . "/" . $params->{web_login_key} || "unknown";
		$user = Storable::retrieve($key);
		unlink($key);
	} else {
		return &_make_false_response("not enough params", "You must have been eaten by a wolf");    
	}
	if (!$user) {
		return &_make_false_response("password not match", "Late! There is a wolf behind you");
	}

	# contact with Grid server
	my %grid_request_params = (
		region_handle => $user->{homeRegion},
		authkey => undef
	);
	OpenUGAI::Utility::Log("user", "grid_server_url", $OpenUGAI::Config::GRID_SERVER_URL);
    my $grid_response = &OpenUGAI::Utility::XMLRPCCall($OpenUGAI::Config::GRID_SERVER_URL, "simulator_data_request", \%grid_request_params);
	OpenUGAI::Utility::Log("user", "grid_response1", Data::Dump::dump($grid_response));
	if (!$grid_response || $grid_response->{error}) {
		return &_make_false_response("can not login", "requested region server is not alive -" . $grid_response->{error} . "-");
	}
    my $region_server_url = "http://" . $grid_response->{sim_ip} . ":" . $grid_response->{sim_port};
    my $internal_server_url = $grid_response->{internal_server_url}; # TODO: hack for regionservers behind a router
    # contact with Region server
    my $session_id = &OpenUGAI::Utility::GenerateUUID;
    my $secure_session_id = &OpenUGAI::Utility::GenerateUUID;
    my $circuit_code = int(rand() * 1000000000); # just a random integer
    my $caps_id = &OpenUGAI::Utility::GenerateUUID;
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
    # TODO: using $internal_server_url is a temporary solution
    my $region_response = undef;
	eval {
    	$region_response = &OpenUGAI::Utility::XMLRPCCall($internal_server_url, "expect_user", \%region_request_params);
	};
	if ($@) {
		return &_make_false_response("can not login", "failed to call expect_user: $@");
	}

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

sub _get_user_by_name {
    my $param = shift;
    
    if ($param->{avatar_name}) {
	my ($first, $last) = split(/\s+/, $param->{avatar_name});
	my $user = &OpenUGAI::UserServer::UserManager::getUserByName($first, $last);
	if (!$user) {
	    return &_unknown_user_response;
	}
	return &_convert_to_response($user);
    } else {
	return &_unknown_user_response;
    }
}

sub _get_user_by_uuid {
    my $param = shift;
    
    if ($param->{avatar_uuid}) {
	my $user = &OpenUGAI::UserServer::UserManager::getUserByUUID($param->{avatar_uuid});
	if (!$user) {
	    return &_unknown_user_response;
	}
	return &_convert_to_response($user);
    } else {
	return &_unknown_user_response;
    }
}

sub _get_avatar_picker_avatar {
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
    	$res = &OpenUGAI::Utility::HttpRequest("POST", $OpenUGAI::Config::INVENTORY_SERVER_URL . "/RootFolders/", $postdata);
    };
    if ($@) {
    	Carp::croak($@);
    }
    my $res_obj = &OpenUGAI::Utility::XML2Obj($res);
	OpenUGAI::Utility::Log("test", "root_folders", Data::Dump::dump($res_obj));

#    if (!$res_obj->{InventoryFolderBase}) {
#	&OpenUGAI::Utility::HttpPostRequest($OpenUGAI::Config::INVENTORY_SERVER_URL . "/CreateInventory/", $postdata);
#	# Sleep(10000); # TODO: need not to do this
#	$res = &OpenUGAI::Utility::HttpPostRequest($OpenUGAI::Config::INVENTORY_SERVER_URL . "/RootFolders/", $postdata);
#	$res_obj = &OpenUGAI::Utility::XML2Obj($res);
#   }

    my $folders = $res_obj->{InventoryFolderBase};
    my $folders_count = @$folders;
    if ($folders_count > 0) {
		my @AgentInventoryFolders = ();
		my $root_uuid = &OpenUGAI::Utility::ZeroUUID();
		foreach my $folder (@$folders) {
		    if ($folder->{ParentID}->{UUID} eq &OpenUGAI::Utility::ZeroUUID()) {
				$root_uuid = $folder->{ID}->{UUID};
		    }
		    my %folder_hash = (
				       name => $folder->{Name},
				       parent_id => $folder->{ParentID}->{UUID},
				       version => $folder->{Version},
				       type_default => $folder->{Type},
				       folder_id => $folder->{ID}->{UUID},
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
    return \%response;
}

# #################
# Utility Functions
sub _make_false_response {
    my ($reason, $message) = @_;
    return { reason => $reason, login => "false", message => $message };
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

sub OpenID_PRELogin {
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
	$user = &OpenUGAI::UserServer::UserManager::getUserByName($params->{first}, $params->{last});
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
    my $grid_response = &OpenUGAI::Utility::XMLRPCCall($OpenUGAI::Config::GRID_SERVER_URL, "simulator_data_request", \%grid_request_params);
    my $region_server_url = "http://" . $grid_response->{sim_ip} . ":" . $grid_response->{sim_port};
    # contact with Region server
    my $session_id = &OpenUGAI::Utility::GenerateUUID;
    my $secure_session_id = &OpenUGAI::Utility::GenerateUUID;
    my $circuit_code = int(rand() * 1000000000); # just a random integer
    my $caps_id = &OpenUGAI::Utility::GenerateUUID;
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
    my $region_response = &OpenUGAI::Utility::XMLRPCCall($region_server_url, "expect_user", \%region_request_params);
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

