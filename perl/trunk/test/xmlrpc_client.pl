#!/usr/bin/perl -w

use strict;
use Data::Dump;
use OpenUGAI::Util;

my $url = shift @ARGV || "http://10.0.1.125:10001";
my $method = shift @ARGV || "GetAvatarDataID";
my $params = &getParams();
if ($params) {
    my $res =  &OpenUGAI::Util::XMLRPCCall($url, $method, $params);    
    print Data::Dump::dump $res;
}
print "\nend of response.\n\n";

sub getParams {
    my %xml_rpc_params = ();
    while (1) {
	my $name = shift @ARGV || last;
	my $value = shift @ARGV || die "not enough args";
	$xml_rpc_params{$name} = $value;
    }
}

