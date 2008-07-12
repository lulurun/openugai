package OpenUGAI::UserServer::UserManager;

use strict;
use Carp;
use OpenUGAI::DBData;
use OpenUGAI::UserServer::Config;

sub getAgentByUUID {
    my $uuid = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($OpenUGAI::UserServer::Config::SYS_SQL{select_agent_by_uuid}, $uuid);
    my $count = @$res;
    if ($count == 1) {
	return $res->[0];
    } else {
	return undef;
    }
}

sub insertAgent {
    my $agent = shift;
    my @params = ();
    foreach (@OpenUGAI::UserServer::Config::AGENTS_COLUMNS) {
	push @params, $agent->{$_};
    }
    my $res = &OpenUGAI::Utility::getSimpleResult($OpenUGAI::UserServer::Config::SYS_SQL{insert_agent}, @params);
}

sub commitUserAgent {
    my $profile = shift;
    if ($profile->{CurrentAgent}) {
	&insertAgent($profile->{CurrentAgent});
    }
    &updateUserByUUID($profile);
}

sub getUserProfile {
    my $uuid = shift;
    my $profile = &getUsetByUUID($uuid);
    if ($profile) {
	my $agent = &getAgentByUUID($uuid);
	if ($agent) {
	    $profile->{CurrentAgent} = $agent;
	} else {
	    $profile->{CurrentAgent} = undef;
	}
    }
    return $profile;
}

1;
