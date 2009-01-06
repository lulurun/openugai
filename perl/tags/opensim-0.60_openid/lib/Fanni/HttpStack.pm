package Fanni::HttpStack;

use strict;
use Carp;
use Fanni::Global;

sub getHandlerList {
    my %list = (
		"expect_user" => \&_xmlrpc_expect_user,
		"logoff_user" => \&_xmlrpc_logoff_user,
		"check" => \&_xmlrpc_check,
		"land_data" => \&_xmlrpc_land_data,
	);
    return \%list;
}

sub _not_implemented {
    return &_make_false_response("not impleneted yet", "but I do not when will this works");
}

# ##################
# http hanlders
sub _xmlrpc_expect_user {
    my $params = shift;
    my %agent_data = {
	session_id => $param->{session_id},
	secure_session_id => $param->{secure_session_id},
	firstname => $param->{firstname},
	lastname => $param->{lastname},
	agent_id => $param->{agent_id},
	circuit_code => $param->{circuit_code},
	caps_path => $param->{caps_path},
    };
    my $region_handler = $param->{regionhanlder};
    #m_log.DebugFormat(
    #"[CLIENT]: Told by user service to prepare for a connection from {0} {1} {2}, circuit {3}",
    #agentData.firstname, agentData.lastname, agentData.AgentID, agentData.circuitcode);            
    if ($param->{child_agent} && $param->{child_agent} eq "1") {
	# child agent detected
	$agent_data{is_child} = 1;
    } else {
	# main agent detected
	$agent_data{is_child} = 0;
	$agent_data{startpos} = "<" . $param->{startpos_x} . "," . $param->{startpos_y} . "," . $param->{startpos_z} . ">";
    }

    my %respdata = ();

    if (&is_banned(\%agent_data)) {
	#m_log.InfoFormat(
	#"[CLIENT]: Denying access for user {0} {1} because user is banned",
	#agentData.firstname, agentData.lastname);
	$respdata{"success"} = "FALSE";
	$respdata{"reason"} = "banned";
    } else {
	&_TriggerExpectUser($region_handle, \%agent_data);
	$respdata{"success"} = "TRUE";
    }
    return \%respdata;
}

sub _xmlrpc_logoff_user {
}

sub _xmlrpc_check {
}

sub _xmlrpc_land_data {
}

# ##################
#
sub _is_banned {
    return 0;
}

sub _TriggerExpectUser {
    my ($region_handler, $agent_data) = @_;
    my $region_login_dir = $Fanni::Global::ExpectUserDir . "/" . $region_hanlder;
    if (! -d $region_login_dir) {
	mkdir($region_login_dir) || Carp::croak("can not create $region_login_dir");
    }
    my $login_filename = $region_login_dir . "/" . $agent_data->{agent_id};
    open(FILE, ">" . $login_filename) || Carp::croak("can not write $login_filename");
    foreach(keys %$agent_data) {
	print FILE $_ . "\t" . $agent_data->{$_} . "\n";
    }
    close(FILE);
}

1;

