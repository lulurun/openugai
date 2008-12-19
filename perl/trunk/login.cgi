#!/usr/bin/perl -w

use strict;
use Carp;
use MyCGI;
use OpenUGAI::Util;
use OpenUGAI::LoginServer;
use OpenUGAI::SampleApp;
require "config.pl";

my $param = &MyCGI::getParam();
eval {
if ($ENV{"REQUEST_METHOD"} eq "GET") {
    my $method = $param->{method} || "";
    my ($response, $act) = &OpenUGAI::LoginServer::DispatchHTTPHandler($method, $param);
    if ($act eq "redirect") {
	&MyCGI::redirect($response);
    } else {
	&MyCGI::outputHtml("utf-8", $response);	
    }
} else { # POST method, XMLRPC
    my $postdata = $param->{'POSTDATA'};
    if (!$postdata) {
	Carp::croak("no post data");
    } else {
	my $xmlrpc = new XML::RPC();
	my $response = $xmlrpc->receive($postdata, \&OpenUGAI::LoginServer::DispatchXMLRPCHandler);
	&MyCGI::outputXml("utf-8", $response);
    }
}
};
if ($@) {
    &OpenUGAI::Util::Log("login", "error", $@);
    &MyCGI::outputHtml("utf-8", &OpenUGAI::SampleApp::Guide);
}

