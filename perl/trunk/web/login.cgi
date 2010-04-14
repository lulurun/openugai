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
    &OpenUGAI::Util::Log("login", "req", $postdata);

    if (!$postdata) {
	Carp::croak("no post data");
    } else {
	my $request_content_type = $ENV{CONTENT_TYPE} || ""; 
	my $response = "";
	if ($request_content_type eq "application/xml+llsd") {
	    $response = &OpenUGAI::LoginServer::LLSDLoginHandler($postdata);
	} else {
	    my $xmlrpc = new XML::RPC();
	    $response = $xmlrpc->receive($postdata, \&OpenUGAI::LoginServer::DispatchXMLRPCHandler);
	}
	&OpenUGAI::Util::Log("login", "resp", $response);
	&MyCGI::outputXml("utf-8", $response);
    }
}
};
if ($@) {
    &OpenUGAI::Util::Log("login", "error", $@);
    &MyCGI::outputHtml("utf-8", &OpenUGAI::SampleApp::Guide);
}

