#!/usr/bin/perl -w

use strict;
use Carp;
use MyCGI;
use OpenUGAI::Util;
use OpenUGAI::UserServer;
use OpenUGAI::SampleApp;
require "config.pl";

my $param = &MyCGI::getParam();
eval {
if ($ENV{"REQUEST_METHOD"} eq "GET") {
    Carp::croak("GET method not allowed");
} else { # POST method, XMLRPC
    my $postdata = $param->{'POSTDATA'};
    if (!$postdata) {
	Carp::croak("no post data");
    } else {
	&OpenUGAI::Util::Log("user", "request", $postdata);
	my $xmlrpc = new XML::RPC();
	my $response = $xmlrpc->receive($postdata, \&OpenUGAI::UserServer::DispatchXMLRPCHandler);
	&OpenUGAI::Util::Log("user", "response", Data::Dump::dump($response));
	&MyCGI::outputXml("utf-8", $response);
    }
}
};
if ($@) {
    &OpenUGAI::Util::Log("user", "error", $@);
    &MyCGI::outputHtml("utf-8", &OpenUGAI::SampleApp::Guide);
}

