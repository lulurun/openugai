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
    &OpenUGAI::Util::Log("grid", "postdata", $postdata);
    if (!$postdata) {
	Carp::croak("no post data");
    } else {
	my $xmlrpc = new XML::RPC();
	my $response = $xmlrpc->receive($postdata, \&OpenUGAI::GridServer::DispatchXMLRPCHandler);
	&MyCGI::outputXml("utf-8", $response);
    }
}
};
if ($@) {
    &OpenUGAI::Util::Log("grid", "error", $@);
    &MyCGI::outputHtml("utf-8", &OpenUGAI::SampleApp::Guide);
}

