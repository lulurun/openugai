package OpenSim::ServerLog::View;

use strict;

sub head_links {
    my $script = shift;
    return << "HEAD_LINKS";
<a href="$script?SHOW=byDate">byDate</a> |
<a href="$script?SHOW=byUser">byUser</a> |
<br>
HEAD_LINKS
}

sub date_summary {
    my $data = shift;
    my $max_login = &max_login($data);
    my $user_count = &user_count($data);
    my $average_session_time = &average_session_time($data);
    my $session_count = &session_count($data);
    return <<"SUMMARY";
<table>
<tr>
  <td>session_count</td><td>$session_count</td>
</tr>
<tr>
  <td>user_count</td><td>$user_count</td>
</tr>
<tr>
  <td>max_login</td><td>$max_login</td>
</tr>
<tr>
  <td>average_session_time</td><td>$average_session_time</td>
</tr>
</table>
SUMMARY
}

sub user_summary {
}

sub session_info {
    my $session = shift;
    my $session_view = "";
    foreach (keys %$session) {
	$session_view .= "\t" . $_ . ": " . $session->{$_} . "<br>\n";
    }
    my $agent_name = $session->{agent_name};
    $agent_name =~ s/:/ /;
    my $online_time = &_get_sec_in_day($session->{logout_time}) - &_get_sec_in_day($session->{login_time});
    my $online_time_string = &_get_timestring($online_time);
    return << "SESSION_INFO";
  <tr>
    <td>$agent_name</td>
    <td>$session->{login_time}</td>
    <td>$session->{logout_time}</td>
    <td>$online_time_string</td>
  </tr>
SESSION_INFO
}

sub output_user_detailed {
    print "User detailed:  Not Implemented!!\n";
}

sub output_raw {
    my $this = shift;
    my $sessions = $this->{login_sessions};
    foreach my $s (values %$sessions) {
        print "Session: " . $s->{session_id} . "\n";
	foreach (keys %$s) {
            print "\t" . $_ . ": " . $s->{$_} . "\n";
        }
    }
}

sub max_login {
    my $this = shift;
    return $this->{max_login_count};
}

sub user_count {
    my $this = shift;
    my %users = ();
    my $count = 0;
    my $sessions = $this->{login_sessions};
    foreach (values %$sessions) {
        my $agent_id = $_->{agent_id};
        if (!$users{$agent_id}) {
            $count++;
        }
        $users{$agent_id} = 1;
    }
    return $count;
}

sub average_session_time {
    my $this = shift;
    my $sessions = $this->{login_sessions};
    my $total_time = 0;
    foreach (values %$sessions) {
        my $session_time = &_get_sec_in_day($_->{logout_time}) - &_get_sec_in_day($_->{login_time});
        $total_time += $session_time;
    }
    my $avg = sprintf("%0.2f", $total_time / $this->{session_count});
    return $avg;
}

sub session_count {
    my $this = shift;
    return $this->{session_count};
}

#######################
# Utilities
sub _get_sec_in_day {
    my $datetime = shift;
    my ($date, $time) = split(/\s+/, $datetime);
    my ($hour, $min, $sec) = split(/:/, $time);
    if ($hour >= 1 && $hour <= 3) {
	$hour += 12;
    }
    return $hour*3600 + $min*60 + $sec;
}

sub _get_timestring {
    my $hour_sec = shift;
    my $hour = int($hour_sec / 3600);
    my $min_sec = $hour_sec % 3600;
    my $min = int($min_sec / 60);
    my $sec_sec = $min_sec % 60;
    my $sec = int($sec_sec);
    my $ret = ($hour == 0 ? "" : "$hour h ") .
	($min == 0 ? "" : "$min m ") .
	("$sec s");
    return $ret;
}


1;
