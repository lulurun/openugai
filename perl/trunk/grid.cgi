#!/usr/bin/perl -w

use strict;
use Carp;
use XML::RPC;
use MyCGI;
use OpenUGAI::Util;
use OpenUGAI::GridServer;
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
	&OpenUGAI::Util::Log("grid", "request", $postdata);
	my $xmlrpc = new XML::RPC();
	my $response = $xmlrpc->receive($postdata, \&OpenUGAI::GridServer::DispatchXMLRPCHandler);
	&OpenUGAI::Util::Log("grid", "response", Data::Dump::dump($response));
	&MyCGI::outputXml("utf-8", $response);
    }
}
};
if ($@) {
    &OpenUGAI::Util::Log("grid", "error", $@);
    &MyCGI::outputHtml("utf-8", &OpenUGAI::SampleApp::Guide);
}

