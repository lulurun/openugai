package OpenUGAI::Data::Agents;

use strict;
use OpenUGAI::DBData;

my %SQL = (
    select_agent_by_uuid =>
    "select * from agents where UUID=?",
    update_agent =>
    "REPLACE INTO agents VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
    update_agent_current_region =>
    "update agents set currentHandle=?, currentRegion=? where UUID=?",
    agent_logon =>
    "update agents set agentOnline=1, currentHandle=?, currentRegion=?," .
    "sessionID=?, secureSessionID=?, currentPos=?, loginTime=?, where UUID=?",
    agent_logoff =>
    "update agents set agentOnline=0, currentHandle=?, currentRegion=?," .
    "currentPos=?, currentLookAt=?, logoutTime=? where UUID=?",
    set_online_status =>
    "update agents set agentOnline=? where UUID=?",
    );

my @AGENTS_COLUMNS = (
    "UUID",
    "sessionID",
    "secureSessionID",
    "agentIP",
    "agentPort",
    "agentOnline",
    "loginTime",
    "logoutTime",
    "currentRegion",
    "currentHandle",
    "currentPos",
    "currentLookAt",
    );

sub SelectAgent {
    my $uuid = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{select_agent_by_uuid}, $uuid);
    my $count = @$res;
    if ($count == 1) {
	return $res->[0];
    }
    return undef;
}

sub UpdateAgent {
    my $params = shift;
    my @args;
    foreach (@AGENTS_COLUMNS) {
	push @args, $params->{$_};
    }
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{update_agent}, \@args);
    return $res;
}

sub UpdateAgentCurrentRegion {
    my ($aid, $rid, $handle) = @_;
    my @args = ( $handle, $rid, $aid );
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{update_agent_current_region}, \@args);
    return $res;
}


sub AgentLogoff {
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{agent_logoff}, \@_);
    return $res;
}

sub AgentLogon {
    return &UpdateAgent(shift);
    #my $res = &OpenUGAI::DBData::getSimpleResult($SQL{agent_logon}, \@_);
    #return $res;
}

sub SetOnlineStatus {
    my ($id, $online) = @_;
    my @args = ( $online, $id );
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{set_online_status}, \@args);
    return $res;
}

1;
