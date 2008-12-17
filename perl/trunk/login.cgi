#!/usr/bin/perl -w

use strict;
use Carp;
use MyCGI;
use Template;
use OpenUGAI::Util;
use OpenUGAI::LoginServer;
use Data::Dump;
use LWPx::ParanoidAgent;
use Net::OpenID::Consumer;
require "config.pl";

my $param = &MyCGI::getParam();
if ($ENV{"REQUEST_METHOD"} eq "GET") {
    my $method = $param->{method} || "";
    if ($method eq "loginpage") { # secondlife viewer login page
	&MyCGI::outputHtml("utf-8", &login_form($param));
    } elsif ($method eq "go") { # login from secondlife viewer by specify first+last+password
	my %auth_param = (
			  "first" => $param->{username},
			  "last"  => $param->{lastname},
			  "passwd" => $param->{password},
			  "weblogin" => $param->{weblogin},
			  );
	my $userinfo = &OpenUGAI::LoginServer::Authenticate(\%auth_param);
	if (!$userinfo) {
	    &MyCGI::outputHtml("utf-8", &login_form($param, "wrong password"));
	} else {
	    my $auth_key = $userinfo->{webLoginKey};
	    my $redirect_url = &create_client_login_trigger($param, $auth_key); 
	    &OpenUGAI::Util::Log("login", "redirect", $redirect_url);
	    &MyCGI::redirect($redirect_url);
	}
    } elsif ($method eq "openid_request") { # OPENID LOGIN step 1 - request authentication
	eval {
	    my $check_url = &OpenUGAI::LoginServer::OpenIDRequestHandler($param);
	    &MyCGI::redirect($check_url);
	};
	if ($@) {
	    &MyCGI::outputHtml("utf-8", $@);	    
	}
    } elsif ($method eq "openid_verify") { # OPENID LOGIN step 2 - verify
	eval {
	    my ($action, $vident) = &OpenUGAI::LoginServer::OpenIDVerifyHandler($param);
	    if ($action eq "redirect") {
		&MyCGI::redirect($vident);
	    } else { # verified OK
		# @@@ this is verify OK
		if (0) { # DEBUG
		    my $params_text = Data::Dump::dump($param);
		    my $extinfo;
		    if ($OpenUGAI::Global::USE_AX) {
			$extinfo = $vident->extension_fields($OpenUGAI::Global::OPENID_NS_SREG_1_1);
		    } else {
			$extinfo = $vident->extension_fields($OpenUGAI::Global::OPENID_NS_AX_1_0);			
		    }
		    my $verify_text = Data::Dump::dump($extinfo);
		    &MyCGI::outputHtml("utf-8", $verify_text . "<br><br><pre>" . $params_text . "</pre>");	
		} else {
		    my $extinfo;
		    if ($OpenUGAI::Global::USE_AX) {
			$extinfo = $vident->extension_fields($OpenUGAI::Global::OPENID_NS_SREG_1_1);
		    } else {
			$extinfo = $vident->extension_fields($OpenUGAI::Global::OPENID_NS_AX_1_0);			
		    }
		    my $userinfo = &OpenUGAI::LoginServer::OpenIDVerifyOK($extinfo);
		    my $auth_key = $userinfo->{webLoginKey};
		    my $redirect_url = &create_client_login_trigger($userinfo, $auth_key); 
		    &OpenUGAI::Util::Log("login", "redirect", $redirect_url);
		    &MyCGI::redirect($redirect_url);
		}
	    }
	};
	if ($@) {
	    &MyCGI::outputHtml("utf-8", $@);	    
	}
    } else {
	&MyCGI::outputHtml("utf-8", &guide);
    }
} else { # POST method, XMLRPC
    my $postdata = $param->{'POSTDATA'};
    if (!$postdata) {
	&MyCGI::outputHtml("utf-8", "");
    } else {
	&OpenUGAI::Util::Log("login", "request", $postdata);
	my $xmlrpc = new XML::RPC();
	my $response = $xmlrpc->receive($postdata, \&XMLRPCHandler);
	&OpenUGAI::Util::Log("login", "response", Data::Dump::dump($response));
	&MyCGI::outputXml("utf-8", $response);
    }
}

sub XMLRPCHandler {
    my ($methodname, @param) = @_;
    my $handler_list = &OpenUGAI::LoginServer::getHandlerList();
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
    $login_form_tmpl =~ s/\[\$firstname\]/$param->{username}/g;
    $login_form_tmpl =~ s/\[\$lastname\]/$param->{lastname}/g;
    $login_form_tmpl =~ s/\[\$password\]/$param->{password}/g;
    $login_form_tmpl =~ s/\[\$remember_password\]/$param->{remember}/g; # TODO
    $login_form_tmpl =~ s/\[\$grid\]/$param->{grid}/g;
    $login_form_tmpl =~ s/\[\$region\]/$param->{region}/g;
    $login_form_tmpl =~ s/\[\$location\]/$param->{location}/g;
    $login_form_tmpl =~ s/\[\$channel\]/$param->{channel}/g;
    $login_form_tmpl =~ s/\[\$version\]/$param->{version}/g;
    $login_form_tmpl =~ s/\[\$lang\]/$param->{lang}/g;
    # openid
    $login_form_tmpl =~ s/\[\$openid_errors\]/$msg/;
    $login_form_tmpl =~ s/\[\$openid_identifier\]/$param->{openid_identifier}/;

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

