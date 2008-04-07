#!/usr/bin/perl -w

use strict;
use Carp;
use XML::RPC;
use MyCGI;
use OpenSim::Utility;
use OpenSim::UserServer;
use Data::Dump;

my $param = &MyCGI::getParam();
my $postdata = $param->{'POSTDATA'};
Carp::croak("no postdata") if (!$postdata);
&OpenSim::Utility::Log("user", "request", $postdata);
my $xmlrpc = new XML::RPC();
my $response = $xmlrpc->receive($postdata, \&XMLRPCHandler);
&OpenSim::Utility::Log("user", "response", Data::Dump::dump $response);
&MyCGI::outputXml("utf-8", $response);

sub XMLRPCHandler {
    my ($methodname, @param) = @_;
    my $handler_list = &OpenSim::UserServer::getHandlerList();
    if (!$handler_list->{$methodname}) {
		Carp::croak("?");
    } else {
		my $handler = $handler_list->{$methodname};
		$handler->(@param);
    }
}

