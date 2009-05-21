#!/usr/bin/perl

use strict;
use CGI;
use JSON;

my %friend_list = (
    lulurun => "11299304",
    wolfdrawer => "11299305",
    opensim => "11299306",
);

my %menu_data = (
    "lulurun" => {
	href => "http://yahoo.co.jp",
	msg => "lulurun is in Region1/20/30/70, go to beat him",
    },
    "wolfdrawer" => {
	href => "http://yahoo.com",
	msg => "wolfdrawer is in Region2/128/128/90, go to eat him",    
    },
    "opensim" => {
	"error_loading" => "",
    },
);

my %error_resp = (
    error => "kuku",
);

my $q = new CGI;
my $method = $q->param("method") || "unknown";
my $cb_func =$q->param("callback") || "unknown";

my $ret_obj = undef;
if ($method eq "friend_list") {
    $ret_obj = \%friend_list;
} elsif ($method eq "friend_status") {
    my $id = $q->param("id") || "default";
    $ret_obj = {id => "#" . $id, data => $menu_data{$id}};
} else {
    $ret_obj = \%error_resp;
}

print $q->header(-type => "text/plain");
my $json_presen = JSON::objToJson( $ret_obj );
print "$cb_func($json_presen);";


