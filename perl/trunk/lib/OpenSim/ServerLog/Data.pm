package OpenSim::ServerLog::Data;

use strict;

# LOGIN STATE ENUM
use constant {
    AUTHENTICATING => 1,
    Got_authenticated_connection => 2,
    Logout => 3,
};

# Public Methods
sub new {
    my ($this, $file) = @_;
    my %fields = (
	log_file => $file,
	Uname2Uid => undef,
	login_sessions => undef,
	session_count => 0,
	current_login_count => 0,
	max_login_count => 0,
	);

    return bless \%fields, $this;
}

sub get_status {
    my $this = shift;
    $this->_get_user_info;
    $this->_parse_log;
}

#Private Methods

sub _update_max_login {
    my ($this, $state) = @_;
    if ($state eq "login") {
	$this->{current_login_count}++;
	if ($this->{max_login_count} < $this->{current_login_count}) {
	    $this->{max_login_count} = $this->{current_login_count};
	}
    } else {
	$this->{current_login_count}--;
    }
}

sub _get_user_info {
    my $this = shift;
    my $file = $this->{log_file};
    open(FILE, $file) || die "can not open $file";
    while(<FILE>) {
	if ($_ =~ /\[([^\]]+)\] Got authenticated connection from ([^\s]+) \[([^\]]+)\]/) {
	    # Got_authenticated_connection
	    my $datetime = $1;
	    my $ip = $2;
	    my $msg = $3;
	    my $info = &_parse_msg($msg);
	    my $Uname = &_make_Uname($info);
	    $this->{Uname2Uid}->{$Uname} = $info->{agent};
	}
    }
    close(FILE);
    #print "DEBUG: get user info\n";
}

sub _parse_log {
    my $this = shift;
    my $file = $this->{log_file};
    open(FILE, $file) || die "can not open $file";
    my %user_state = ();
    my $line_no = 0;
    my $last_datetime = "";
    while(<FILE>) {
	$line_no++;
	if ($_ =~ /\[([^\]]+)\] Authenticating \[([^\]]+)\]/) {
	    # Authenticating
	    my $datetime = $1;
	    my $msg = $2;
	    my $info = &_parse_msg($msg);
	    my $Uname = &_make_Uname($info);
	    my $agent = $this->{Uname2Uid}->{$Uname} || "UNKOWN";
	    if (!$user_state{$agent}) {
		$user_state{$agent} = -1;
	    }
	    # Update user login state
	    if ($user_state{$agent} == AUTHENTICATING) {
		#print "WARN: $agent: $user_state{$agent} failed to login ($line_no)\n";
	    } elsif ($user_state{$agent} == Got_authenticated_connection) {
		#print "WARN: $agent duplicate login ($line_no)\n";
	    }
	    $user_state{$agent} = AUTHENTICATING;
	    # Do something here
	} elsif ($_ =~ /\[([^\]]+)\] Got authenticated connection from ([^\s]+) \[([^\]]+)\]/) {
	    # Got_authenticated_connection
	    my $datetime = $1;
	    my $ip = $2;
	    my $msg = $3;
	    my $info = &_parse_msg($msg);
	    my $agent = $info->{agent};
	    # Update user login state
	    if ($user_state{$agent} != AUTHENTICATING) {
		#print "ERROR: Wrong login state: $user_state{$agent} ($line_no)\n";
	    }
	    $user_state{$agent} = Got_authenticated_connection;
	    # Create Session !!
	    my $session_id = $info->{session};
	    my %session = (
		session_id => $session_id,
		agent_id => $info->{agent},
		agent_name => &_make_Uname($info),
		login_time => $datetime,
		logout_time => 0,
		);
	    if ($this->{login_sessions}->{$session_id}) {
		print "FATAL: Duplicate session id !! ($line_no)\n";
		exit(1);
	    }
	    $this->{login_sessions}->{$session_id} = \%session;
	    $this->{session_count}++;
	    # Update current login count
	    $this->_update_max_login("login");
	} elsif ($_ =~ /\[([^\]]+)\] Logout \[([^\]]+)\]/) {
	    # Logout
	    my $datetime = $1;
	    my $msg = $2;
	    my $info = &_parse_msg($msg);
	    my $agent = $info->{agent};
	    # Update user login state
	    if ($user_state{$agent} != Got_authenticated_connection) {
		#print "ERROR: Wrong login state: $user_state{$agent} ($line_no)\n";
	    }
	    $user_state{$agent} = Logout;
	    # Update session info
	    my $session_id = $info->{session};
	    if (!$this->{login_sessions}->{$session_id}) {
		print "FATAL: Invalid session state !! ($line_no)\n";
		exit(1);
	    }
	    $this->{login_sessions}->{$session_id}->{logout_time} = $datetime;
	    # Update current login count
	    $this->_update_max_login("logout");
	} elsif ($_ =~ /\[([^\]]+)\]/) {
	    $last_datetime = $1;
	}
    }
    close(FILE);
    #print "DEBUG: correcting data ...\n";
    foreach(keys %{$this->{login_sessions}}) {
	if (!$this->{login_sessions}->{$_}->{logout_time}) {
	    #print "DEBUG: add logout_time for Session: $_ ...\n";
	    $this->{login_sessions}->{$_}->{logout_time} = $last_datetime;
	}
    }
    #print "DEBUG: parse file finished\n";
}

#######################
# Utilities

sub _parse_msg {
    my $msg = shift;
    my %ret = ();
    my @pairs = split(/,/, $msg);
    foreach(@pairs) {
	my ($key, $value) = split(/=/, $_);
	$ret{$key} = $value;
    }
    return \%ret;
}

sub _make_Uname {
    my $data = shift;
    return $data->{"first"} . ":" . $data->{"last"};
}

1;
