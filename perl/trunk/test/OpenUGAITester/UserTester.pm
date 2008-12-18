package UserTester;

use strict;
use Digest::MD5;
use OpenUGAI::Util;

my $user_server_url;

sub init {
	&OpenUGAITester::Config::registerHandler("login_to_simulator", \&_login_to_simulator);
	&OpenUGAITester::Config::registerHandler("get_user_by_name", \&_get_user_by_name);
	&OpenUGAITester::Config::registerHandler("get_user_by_uuid", \&_get_user_by_uuid);
	&OpenUGAITester::Config::registerHandler("get_avatar_picker_avatar", \&_get_avatar_picker_avatar);
	&OpenUGAITester::Config::registerHandler("get_avatar_appearance", \&_get_avatar_appearance);
}

sub _get_avatar_appearance {
    my $url = shift || $OpenUGAITester::Config::USER_SERVER_URL;
    my @param = @_;
    my %xml_rpc_param = (
			 owner => $param[0],
			 );
    return &OpenUGAI::Util::XMLRPCCall($url, "get_avatar_appearance", \%xml_rpc_param);    
}

sub _login_to_simulator {
    my $url = shift || $OpenUGAITester::Config::USER_SERVER_URL;
    my @param = @_;
    my %xml_rpc_param = (
			 first => $param[0],
			 last => $param[1],
			 passwd => "\$1\$" . Digest::MD5::md5_hex($param[2]),
			 start => "last",
			 version => "1.18.3.5",
			 mac => "cc82e1e2bfd24e5424d66b4fd3f70d55",
			 );
    return &OpenUGAI::Util::XMLRPCCall($url, "login_to_simulator", \%xml_rpc_param);
}

sub _get_user_by_name {
    my $url = shift || $OpenUGAITester::Config::USER_SERVER_URL;
    my @param = @_;
    my %xml_rpc_param = (
			 avatar_name => $param[0],
			 );
    return &OpenUGAI::Util::XMLRPCCall($url, "get_user_by_name", \%xml_rpc_param);
}

# sample uuid:
# db836502-de98-49c9-9edc-b90a67beb0a8
sub _get_user_by_uuid {
    my $url = shift || $OpenUGAITester::Config::USER_SERVER_URL;
    my @param = @_;
    my %xml_rpc_param = (
			 avatar_uuid => $param[0],
			 );
    return &OpenUGAI::Util::XMLRPCCall($url, "get_user_by_uuid", \%xml_rpc_param);
}

sub _get_avatar_picker_avatar {
}

1;
