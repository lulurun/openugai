#!/usr/bin/perl -w

use strict;
use Carp;
use MyCGI;
use Template;
use lib "/srv/www/openugai/perl/trunk/test";

use OpenUGAI::Util;
use FanniTester::UserServer;
use Data::Dump;
require "/srv/www/openugai/perl/trunk/config.pl";

my $param = &MyCGI::getParam();
if ($ENV{"REQUEST_METHOD"} eq "GET") {
    my $method = $param->{method} || "";
    if ($method eq "login") {
	&MyCGI::outputHtml("utf-8", &login_form($param));
    } elsif ($method eq "go") {
	my %auth_param = (
	    first => $param->{username},
	    last  => $param->{lastname},
	    passwd => $param->{password},
	    weblogin => $param->{weblogin},
	    );
	my $auth_key = &OpenUGAI::UserServer::Authenticate(\%auth_param);
	if (!$auth_key) {
	    &MyCGI::outputHtml("utf-8", &login_form($param, "wrong password"));
	} else {
	    my $redirect_url = &create_client_login_trigger($param, $auth_key); 
	    &OpenUGAI::Util::Log("user", "redirect", $redirect_url);
	    &MyCGI::redirect($redirect_url);
	}
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
    my $handler_list = &OpenUGAI::UserServer::getHandlerList();
    if (!$handler_list->{$methodname}) {
	Carp::croak("?");
    } else {
	my $handler = $handler_list->{$methodname};
	$handler->(@param);
    }
}

sub login_form {
    my ($param, $msg) = @_;
    my $login_form_tmpl = &Template::Get("login_form");
    $login_form_tmpl =~ s/\[\$errors\]/$msg/;
    $login_form_tmpl =~ s/\[\$firstname\]/$param->{username}/;
    $login_form_tmpl =~ s/\[\$lastname\]/$param->{lastname}/;
    $login_form_tmpl =~ s/\[\$password\]/$param->{password}/;
    $login_form_tmpl =~ s/\[\$remember_password\]/$param->{remember}/; # TODO
    $login_form_tmpl =~ s/\[\$grid\]/$param->{grid}/;
    $login_form_tmpl =~ s/\[\$region\]/$param->{region}/;
    $login_form_tmpl =~ s/\[\$location\]/$param->{location}/;
    $login_form_tmpl =~ s/\[\$channel\]/$param->{channel}/g;
    $login_form_tmpl =~ s/\[\$version\]/$param->{version}/g;
    $login_form_tmpl =~ s/\[\$lang\]/$param->{lang}/g;
    return $login_form_tmpl;
}

sub create_client_login_trigger {
    my ($param, $auth_key) = @_;
    my $location = $param->{location} || "last";
    my $command = $param->{command} || "login";
    my $secondlife_url = "secondlife:///app/" . $command . "?first_name=" .
	$param->{username} ."&last_name=" . $param->{lastname} .
	"&location=" . $location . "&grid=Other&web_login_key=" .
	$auth_key;
    return "about:blank?redirect-http-hack=" .
	&MyCGI::urlEncode($secondlife_url);
}

sub guide {
    return &Template::Get("guide");
}

