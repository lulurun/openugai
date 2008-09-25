#!/usr/bin/perl -w

use strict;
use Carp;
use XML::RPC;
use MyCGI;
use OpenUGAI::Util;
use OpenUGAI::GridServer;
require "config.pl";

my $param = &MyCGI::getParam();
my $request = $param->{'POSTDATA'};
&OpenUGAI::Util::Log("grid", "request", $request);
my $xmlrpc = new XML::RPC();
my $response = $xmlrpc->receive($request, \&XMLRPCHandler);
&OpenUGAI::Util::Log("grid", "response", $response);
&MyCGI::outputXml("utf-8", $response);

sub XMLRPCHandler {
    my ($methodname, @param) = @_;
    my $handler_list = &OpenUGAI::GridServer::getHandlerList();
    if (!$handler_list->{$methodname}) {
	Carp::croak("?"); # @@@ TODO: handle bad xmlrpc
    } else {
	my $handler = $handler_list->{$methodname};
	return $handler->(@param);
    }
}
