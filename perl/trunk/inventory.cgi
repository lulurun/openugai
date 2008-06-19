#!/usr/bin/perl -w

use strict;
use MyCGI;
use OpenUGAI::InventoryServer;
use Carp;

my $request_uri = $ENV{REQUEST_URI} || Carp::croak("You must have been eaten by a wolf.");
my $request_method = "";
if ($request_uri =~ /([^\/]+)\/$/) {
    $request_method = $1;
} else {
    &MyCGI::outputXml("utf-8", "You must have been eaten by a wolf.");
}
my $param = &MyCGI::getParam();
my $post_data = $param->{'POSTDATA'};
&OpenUGAI::Utility::Log("inventory", "request", $request_uri, $post_data);
my $response = "";
eval {
    $response = &handleRequest($request_method, $post_data);
};
if ($@) {
    $response = "<ERROR>$@</ERROR>";
}
&OpenUGAI::Utility::Log("inventory", "response", $response);
&MyCGI::outputXml("utf-8", $response);

sub handleRequest {
    my ($methodname, $post_data) = @_;
    my $handler_list = &OpenUGAI::InventoryServer::getHandlerList();
    if (!$handler_list->{$methodname}) {
	Carp::croak("?");
    } else {
	my $handler = $handler_list->{$methodname};
	return $handler->($post_data);
    }
}

