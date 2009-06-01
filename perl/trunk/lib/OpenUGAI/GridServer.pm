package OpenUGAI::GridServer;

use strict;
use OpenUGAI::Global;
use OpenUGAI::Util;
use OpenUGAI::Data::Regions;

our $ValidateContactable = 0; # 0 for debug

our %XMLRPCHandlers = (
		       "simulator_login" => \&_simulator_login,
		       "simulator_data_request" => \&_simulator_data_request,
		       "simulator_after_region_moved" => \&_simulator_after_region_moved,
		       "map_block" => \&_map_block,
		       # not implemented
		       "register_messageserver" => \&_not_implemented,
		       "deregister_messageserver" => \&_not_implemented,
		       );

sub _not_implemented {
    return &_make_false_response("not implemented yet");
}

sub StartUp {
    # for mod_perl startup
    ;
}

sub DispatchXMLRPCHandler {
    my ($methodname, @param) = @_; # @param is extracted by xmlrpc lib
    if ($XMLRPCHandlers{$methodname}) {
	return $XMLRPCHandlers{$methodname}->(@param);
    }
    Carp::croak("unknown xmlrpc method");
}

# #################
# XMLRPC Handlers
sub _simulator_after_region_moved {
    my $params = shift;
    my %response = ();
    
    my $region_uuid = "";
    if ($params->{UUID}) {
	$region_uuid = $params->{UUID};		
    } else {
	$response{"error"} = "No region_uuid passed to grid server";
	return \%response;
    }
    
    eval {
	&OpenUGAI::Data::Regions::deleteRegionByUUID($region_uuid);
    };
    if ($@) {
	$response{"status"} = "Deleting region failed: $region_uuid";
    } else {
	$response{"status"} = "Deleting region successful: $region_uuid";
    }
    return \%response;
}

sub _simulator_login {
    my $params = shift;
    my %response = ();
    my $region_data = undef;
    my %new_region_data = ();

    # check version
    # my $inerface_version = $params->{major_interface_version}
    # TODO : return faliled if (!isCurrentVersion($interface_version));
    if ($params->{"region_locx"} && $params->{"region_locy"}) {
	my $region_handle = &getRegionHandle($params->{"region_locx"}, $params->{"region_locy"});
	%new_region_data = (
	    uuid => $params->{UUID},
	    regionHandle => $region_handle,
	    regionName => $params->{sim_name},
	    regionRecvKey => $params->{recvkey},
	    regionSendKey => $params->{authkey},
	    regionSecret => $params->{region_secret},
	    regionDataURI => "",
	    serverIP => $params->{sim_ip},
	    serverPort => $params->{sim_port},
	    serverURI => "http://" . $params->{sim_ip} . ":" . $params->{sim_port} . "/",
	    locX => $params->{region_locx},
	    locY => $params->{region_locy},
	    locZ => 0,
	    eastOverrideHandle => undef,
	    westOverrideHandle => undef,
	    southOverrideHandle => undef,
	    northOverrideHandle => undef,
	    regionAssetURI => $OpenUGAI::Global::ASSET_SERVER_URL,
	    regionAssetRecvKey => $OpenUGAI::Global::ASSET_RECV_KEY,
	    regionAssetSendKey => $OpenUGAI::Global::ASSET_SEND_KEY,
	    regionUserURI => $OpenUGAI::Global::USER_SERVER_URL,
	    regionUserRecvKey => $OpenUGAI::Global::USER_RECV_KEY,
	    regionUserSendKey => $OpenUGAI::Global::USER_SEND_KEY,
	    regionMapTexture => $params->{"map-image-id"},
	    serverHttpPort => $params->{http_port},
	    serverRemotingPort => $params->{remoting_port},
	    owner_uuid => $params->{master_avatar_uuid},
	    originUUID => $params->{UUID},
	    access => 1,
	    );
	$region_data = &OpenUGAI::Data::Regions::getRegionByHandle($region_handle);
    } else {
	$response{"error"} = "No region_handle passed to grid server - unable to connect you";
	return \%response;
    }
    
    if (!$region_data) {
	eval {
	    &ValidateNewRegionKeys($params);
	    &ValidateRegionContactable($params);
	    &OpenUGAI::Data::Regions::addRegion(\%new_region_data);
	};
	if ($@) {
	    $response{"error"} = "unable to add region: $@";
	    return \%response;
	}
	$region_data = \%new_region_data;
    } else {
	eval {
	    &ValidateOverwriteKeys($params);
	    &ValidateRegionContactable($params);
	    $new_region_data{regionDataURI} = $region_data->{regionDataURI};
	    $new_region_data{locZ} = $region_data->{locZ};
	    $new_region_data{eastOverrideHandle} = $region_data->{eastOverrideHandle};
	    $new_region_data{westOverrideHandle} = $region_data->{westOverrideHandle};
	    $new_region_data{southOverrideHandle} = $region_data->{southOverrideHandle};
	    $new_region_data{northOverrideHandle} = $region_data->{northOverrideHandle};
	    $new_region_data{regionAssetURI} = $region_data->{regionAssetURI};
	    $new_region_data{regionAssetRecvKey} = $region_data->{regionAssetRecvKey};
	    $new_region_data{regionAssetSendKey} = $region_data->{regionAssetSendKey};
	    $new_region_data{regionUserURI} = $region_data->{regionUserURI};
	    $new_region_data{regionUserRecvKey} = $region_data->{regionUserRecvKey};
	    $new_region_data{regionUserSendKey} = $region_data->{regionUserSendKey};
	    &OpenUGAI::Data::Regions::updateRegionByHandle(\%new_region_data);
	};
	if ($@) {
	    $response{"error"} = "unable to add region: $@";
	    return \%response;
	}
    }
    
    my @region_neighbours_data = ();
    my $region_list = &OpenUGAI::Data::Regions::getRegionList($region_data->{locX}-1, $region_data->{locY}-1, $region_data->{locX}+1, $region_data->{locY}+1);
    foreach my $region (@$region_list) {
	next if ($region->{regionHandle} eq $region_data->{regionHandle});
	my %neighbour_block = (
	    "sim_ip" => $region->{serverIP},
	    "sim_port" => $region->{serverPort},
	    "region_locx" => $region->{locX},
	    "region_locy" => $region->{locY},
	    "UUID" => $region->{uuid},
	    "regionHandle" => $region->{regionHandle},
	    );
	push @region_neighbours_data, \%neighbour_block;
    }
    
    %response = (
	UUID => $region_data->{uuid},
	region_locx => $region_data->{locX},
	region_locy => $region_data->{locY},
	regionname => $region_data->{regionName},
	estate_id => "1", # TODO ???
	neighbours => \@region_neighbours_data,
	sim_ip => $region_data->{serverIP},
	sim_port => $region_data->{serverPort},
	asset_url => $region_data->{regionAssetURI},
	asset_recvkey => $region_data->{regionAssetRecvKey},
	asset_sendkey => $region_data->{regionAssetSendKey},
	user_url => $region_data->{regionUserURI},
	user_recvkey => $region_data->{regionUserRecvKey},
	user_sendkey => $region_data->{regionUserSendKey},
	authkey => $region_data->{regionSecret},
	data_uri => $region_data->{regionDataURI},
	"allow_forceful_banlines" => "TRUE",
	);
    # TODO @@@ message servers ...
    return \%response;
}

sub _simulator_data_request {
    my $params = shift;
    
    my $region_data = undef;
    my %response = ();
    if ($params->{"region_UUID"}) {
	$region_data = &OpenUGAI::Data::Regions::getRegionByUUID($params->{"region_UUID"});
    } elsif ($params->{"region_handle"}) {
	$region_data = &OpenUGAI::Data::Regions::getRegionByHandle($params->{"region_handle"});
    }
    if (!$region_data) {
	$response{"error"} = "Sim does not exist";
	return \%response;
    }
    
    $response{"region_locx"} = $region_data->{locX};
    $response{"region_locy"} = $region_data->{locY};
    $response{"sim_ip"} = $region_data->{serverIP};
    $response{"sim_port"} = $region_data->{serverPort};
    $response{"http_port"} = $region_data->{serverHttpPort};
    $response{"remoting_port"} = $region_data->{serverRemotingPort};
    $response{"server_uri"} = $region_data->{serverURI};
    $response{"region_UUID"} = $region_data->{uuid};
    $response{"region_name"} = $region_data->{regionName};
    $response{"regionHandle"} = $region_data->{regionHandle}; # TODO: check opensim. maybe need not
    $response{"internal_server_url"} = $region_data->{serverURI}; # TODO @@@ hack !!!??? only lulurun need this
    # TODO @@@ stupid, but its too late today
    foreach(keys %response) {
	$response{$_} = RPC::XML::string->new( $response{$_} );
    }
    return \%response;
}

sub _map_block {
    my $params = shift;
    
    my $xmin = $params->{xmin} || 980;
    my $ymin = $params->{ymin} || 980;
    my $xmax = $params->{xmax} || 1020;
    my $ymax = $params->{ymax} || 1020;
    
    my @sim_block_list = ();
    my $region_list = &OpenUGAI::Data::Regions::getRegionList($xmin, $ymin, $xmax, $ymax);
    foreach my $region (@$region_list) {
	my %sim_block = (
	    "x" => $region->{locX},
	    "y" => $region->{locY},
	    "name" => $region->{regionName},
	    "access" => 0, # TODO ? meaning unknown
	    "region-flags" => 0, # TODO ? unknown
	    "water-height" => 20, # TODO ? get from a XML
	    "agents" => 1, # TODO
	    "map-image-id" => $region->{regionMapTexture},
	    "regionhandle" => $region->{regionHandle},
	    "sim_ip" => $region->{serverIP},
	    "sim_port" => $region->{serverPort},
	    "sim_uri" => $region->{serverURI},
	    "uuid" => $region->{uuid},
	    "remoting_port" => $region->{serverRemotingPort},
	    );
	push @sim_block_list, \%sim_block;
    }
    
    my %response = (
	"sim-profiles" => \@sim_block_list,
	);
    return \%response;
}

# ############
# subs used by public methods
sub getRegionHandle {
    my ($x, $y) = @_;
    return &OpenUGAI::Util::UIntsToLong(256*$x, 256*$y);
}

sub ValidateNewRegionKeys {
    my $params = shift;
    if ($params->{recvkey} ne $OpenUGAI::Global::SIM_RECV_KEY || $params->{authkey} ne $OpenUGAI::Global::SIM_SEND_KEY) {
	Carp::croak("Authentication failed when trying to login existing region $params->{sim_name}");
    }
}

sub ValidateOverwriteKeys {
    my ($region_data, $params) = @_;
    if ($params->{recvkey} ne $region_data->{regionRecvKey} || $params->{authkey} ne $region_data->{regionSendKey}) {
	Carp::croak("Authentication failed when trying to login existing region $region_data->{regionName}");
    }
}

sub ValidateRegionContactable {
    my $params = shift;
    return if (!$ValidateContactable);
    my $region_status_url = "http://" . $params->{sim_ip} . ":" . $params->{http_port} . "/simstatus/";
    my $res_contents = undef;
    eval {
	$res_contents = &OpenUGAI::Util::HttpRequest("GET", $region_status_url);
    };
    if ($@) {
	Carp::croak($@);
    }
    if ($res_contents ne "OK") {
	Carp::croak("region server not ready: $res_contents");
    }
}

1;

