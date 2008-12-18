#!/usr/bin/perl -w

use strict;
use Carp;
use MyCGI;
use OpenUGAI::Util;
use OpenUGAI::AssetServer;
require "config.pl";

# !!
# TODO: ERROR code
# MEMO: AssetServer is a internal server *NOW*, need not to show a guide
my $param = &MyCGI::getParam();

my $response = "<ERROR />";
if ($ENV{REQUEST_METHOD} eq "POST") {
    my $request = $param->{'POSTDATA'};
#	&OpenUGAI::Util::Log("asset", "request", $ENV{REQUEST_URI}, $request);
    eval {
	$response = &OpenUGAI::AssetServer::saveAsset($request);
    };
    if ($@) {
	$response = "<ERROR>$@</ERROR>"; # TODO: better return message needed.
	&OpenUGAI::Util::Log("asset", "postasset_error", $@);
    }
} else { # get
    eval {
	my $rest_param = &getRestAssetParam();
	$response = &OpenUGAI::AssetServer::getAsset($rest_param->[$#$rest_param]);
    };
    if ($@) {
	$response = "<ERROR>$@</ERROR>"; # TODO: better return message needed.
	&OpenUGAI::Util::Log("asset", "getasset_error", $@);
    }
}
&MyCGI::outputXml("utf-8", $response);

sub getRestAssetParam {
    my $uri = $ENV{REQUEST_URI} || Carp::croak("You must have been eaten by a wolf.");
    my ($request_uri, undef) = split(/\?/, $uri);
    $request_uri =~ s/\/$//;
    my @param = split(/\//, $request_uri);
    my $rest_param_count = @param;
    if ($rest_param_count < 2) {
	Carp::croak("Probably bad settings");
    }
    return \@param;
}

