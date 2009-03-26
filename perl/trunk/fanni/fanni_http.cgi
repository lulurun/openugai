#!/usr/bin/perl -w

use strict;
use Carp;
use Fanni::HttpStack;
use Fanni::Global;

my $param = &MyCGI::getParam();
if ($ENV{"REQUEST_METHOD"} eq "GET") {
    my $method = $param->{method} || "";
    if ($method eq "udp_login") {
	&MyCGI::outputText("utf-8", &get_expected_user($param));
    } else {
	&MyCGI::outputHtml("utf-8", &guide);
    }
} else { # POST method, XMLRPC
    my $postdata = $param->{'POSTDATA'};
    if (!$postdata) {
	&MyCGI::outputHtml("utf-8", "");
    } else {
	&OpenUGAI::Util::Log("user", "request", $postdata);
	my $xmlrpc = new XML::RPC();
	my $response = $xmlrpc->receive($postdata, \&XMLRPCHandler);
	&OpenUGAI::Util::Log("user", "response", Data::Dump::dump($response));
	&MyCGI::outputXml("utf-8", $response);
    }
}

sub XMLRPCHandler {
    my ($methodname, @param) = @_;
    my $handler_list = &Fanni::HttpStack::getHandlerList();
    if (!$handler_list->{$methodname}) {
	Carp::croak("?");
    } else {
	my $handler = $handler_list->{$methodname};
	$handler->(@param);
    }
}

sub get_expected_user {
    my $param = shift;
    my $agent_id = $param->{agent_id};
    my $region_login_dir = $Fanni::Global::ExpectUserDir . "/" . $region_hanlder;
    my $login_filename = $region_login_dir . "/" . $agent_data->{agent_id};
    if (! -e $login_filename) {
	return "Error: Invalid Access!";
    }
    open(FILE, $login_filename) || Carp::croak("can not open $login_filename");
    my @lines = <FILE>;
    close(FILE);
    return join("", @lines);
}

sub guide {
    return "hello!";
}
