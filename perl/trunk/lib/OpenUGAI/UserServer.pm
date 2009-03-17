package OpenUGAI::UserServer;

use strict;
use Storable;
use Digest::MD5;

use OpenUGAI::Global;
use OpenUGAI::Util;
use OpenUGAI::UserServer::Config;
use OpenUGAI::Data::Avatar;
use OpenUGAI::Data::Users;
use OpenUGAI::Data::Agents;

our %XMLRPCHandlers = (
		       "get_user_by_name" => \&_get_user_by_name,
		       "get_user_by_uuid" => \&_get_user_by_uuid,
		       "get_avatar_appearance" => \&_get_avatar_appearance,
		       "update_avatar_appearance" => \&_update_avatar_appearance,
		       "update_user_current_region" => \&_update_user_current_region,
		       "logout_of_simulator" => \&_logout_of_simulator,
		       "get_agent_by_uuid" => \&_get_agent_by_uuid,
		       "agent_change_region" => \&_agent_change_region,
		       "deregister_messageserver" => \&_deregister_messageserver,
		       # not implemented
		       "register_messageserver" => \&_not_implemented,
		       "update_user_profile" => \&_not_implement,
		       "add_new_user_friend" => \&_not_implemented,
		       "remove_user_frind" => \&_not_implemented,
		       "update_user_friend_perms" => \&_not_implemented,
		       "get_user_friend_list" => \&_not_implemented,
		       "get_avatar_picker_avatar" => \&_not_implemented,
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
	&OpenUGAI::Util::Log("user", "Dispatch", $methodname);
	return $XMLRPCHandlers{$methodname}->(@param);
    }
    Carp::croak("unknown xmlrpc method");
}

# #################
# Handlers
sub _logout_of_simulator {
    my $params = shift;
    # TODO @@@ inform message server: NotifyMessageServersUserLoggOff
    if ($params->{avatar_uuid} && $params->{region_uuid} && $params->{region_handle}) {
	my $posx = $params->{region_pos_x} || 128;
	my $posy = $params->{region_pos_y} || 128;
	my $posz = $params->{region_pos_z} || 128;
	my $lookatx = $params->{lookat_x} || 100;
	my $lookaty = $params->{lookat_y} || 100;
	my $lookatz = $params->{lookat_z} || 100;
	my @args = (
	    $params->{region_handle},
	    $params->{region_uuid},
	    "<$posx,$posy,$posz>",
	    "<$lookatx,$lookaty,$lookatz>",
	    time,
	    $params->{avatar_uuid},
	    );
	&OpenUGAI::Data::Agents::AgentLogoff(@args);
    } else {
	return &_unknown_user_response; # TODO @@@ shoule be a "not enough params" error
    }
}

sub _update_user_current_region {
    my $params = shift;
    my $returnString = "FALSE";
    if ($params->{avatar_id} && $params->{region_uuid} && $params->{region_handle}) {
	&OpenUGAI::Data::Agents::UpdateAgentCurrentRegion($params->{avatar_id},$params->{region_uuid}, $params->{region_handle});
	$returnString = "TRUE";
    } else {
	return &_make_false_response("not enough params", "You must have been eaten by a wolf");
    }
    return { returnString => $returnString, };
}

sub _get_avatar_appearance {
    my $params = shift;
    &OpenUGAI::Util::Log("user", "get_avatar", $params);
    if (!$params->{owner}) {
	return &_make_error_response("unknown_avatar", "You must have been eaten by a wolf - onwer needed");
    }
    my $owner = $params->{owner};
    my %appearance = ();
    eval {
	my $res = &OpenUGAI::Data::Avatar::SelectAppearance($owner);
	if ($res) {
	    $appearance{visual_params} = RPC::XML::base64->new($res->{Visual_Params});
	    delete $res->{Visual_Params};
	    $appearance{texture} = RPC::XML::base64->new($res->{Texture});
	    delete $res->{Texture};
	    map { $appearance{lc($_)} = RPC::XML::string->new($res->{$_}); } keys %$res;
	    # attachments
	    my $attachments = &OpenUGAI::Data::Avatar::SelectAttachment($owner);
	    my @attachment_string_list = ();
	    my $attachment_string = "";
	    if ($attachments) {
		foreach (@$attachments) {
		    push @attachment_string_list, $_->{attachpoint} . "," . $_->{item} . "," . $_->{asset};
		}
		$attachment_string = join(",", @attachment_string_list);
	    }
	    if ($attachment_string) {
		$appearance{attachments} = $attachment_string;
	    }
	} else {
	    Carp::croak("There was no appearance found for this avatar");
	}
    };
    if ($@) {
	return &_make_error_response("no appearance", $@);
    }
    return \%appearance;
}

sub _update_avatar_appearance {
    my $params = shift;
    &OpenUGAI::Util::Log("user", "update_avatar", $params);
    if (!$params->{owner}) {
	return &_make_error_response("unknown_avatar", "You must have been eaten by a wolf - onwer needed");
    }
    eval {
	# TODO: also on opensim side
	# 1. Too stupid that here always contains both appearance and attachment
	# 2. Need to think about transaction
	&OpenUGAI::Data::Avatar::UpdateAppearance($params);
	if ($params->{attachments}) {
	    my @attachments = ();
	    my @values = split(/,/, $params->{attachments});
	    while (my $p = shift @values) {
		push @attachments, {
		    UUID => $params->{owner},
		    attachpoint => $p,
		    item => shift @values,
		    asset => shift @values
		    };
	    }
	    if (@attachments > 0) {
		&OpenUGAI::Data::Avatar::DeleteAvatarAttachments($params->{owner});
		foreach (@attachments) {
		    &OpenUGAI::Data::Avatar::UpdateAttachment($_);
		}
	    }
	}
    };
    if ($@) {
	return &_make_false_response("can not update appearance", $@);
    }
    return { returnString => "TRUE" };
}

sub _get_user_by_name {
    my $param = shift;
    
    if ($param->{avatar_name}) {
	my ($first, $last) = split(/\s+/, $param->{avatar_name});
	my $user = &OpenUGAI::Data::Users::getUserByName($first, $last);
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
	my $user = &OpenUGAI::Data::Users::getUserByUUID($param->{avatar_uuid});
	if (!$user) {
	    # @@@ move this to OpenUGAI::Data::Users
	    $user = &_getForeginLoginUser($param->{avatar_uuid});
	}
	if (!$user) {
	    return &_unknown_user_response;
	}
	return &_convert_to_response($user);
    } else {
	return &_unknown_user_response;
    }
}

sub _getForeginLoginUser {
    my $user_id = shift;
    my $user = Storable::retrieve($user_id);
    # @@@ error check !! if not found ...
    return $user;
}

# #################
# Util Functions
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

1;

