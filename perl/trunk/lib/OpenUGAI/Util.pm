package OpenUGAI::Util;

use strict;
use XML::RPC;
use XML::Simple;
use Data::UUID;
use OpenUGAI::Global;
use Socket;
use Math::BigInt;
use LWP::UserAgent;

sub HttpRequest {
	my ($method, $url, $data) = @_;
	my $ua = LWP::UserAgent->new;
	my $request = new HTTP::Request($method => $url);
	if ($data) {
		$request->content_type("text/xml");
		$request->content($data);
	}
	my $res = $ua->request($request);
	if (! $res->is_success) {
		Carp::croak("HttpRequest failed: " . $res->code . " " . $res->message);
	}
	return $res->content;
}

sub XMLRPCCall {
    my ($url, $methodname, $param) = @_;
    my $xmlrpc = new XML::RPC($url);
    my $result = $xmlrpc->call($methodname, $param);
    return $result;
}

sub UIntsToLong {
	my ($high, $low) = @_;
	return Math::BigInt->new($high)->blsft(32)->bxor($low);
}

sub GenerateUUID {
	my $ug = new Data::UUID();
	my $uuid = $ug->create();
	return lc($ug->to_string($uuid));
}

sub ZeroUUID {
	return "00000000-0000-0000-0000-000000000000";
}

sub HEX2UUID {
	my $hex = shift;
	Carp::croak("$hex is not a uuid") if (length($hex) != 32);
	my @sub_uuids = ($hex =~ /(\w{8})(\w{4})(\w{4})(\w{4})(\w{12})/);
	return join("-", @sub_uuids);
}

sub BIN2UUID {
	# TODO:
}

sub UUID2HEX {
	my $uuid = shift;
	$uuid =~ s/-//g;
	return $uuid;
}

sub UUID2BIN {
	my $uuid = shift;
	return pack("H*", &UUID2HEX($uuid));
}

sub XML2Obj {
	my $xml = shift;
	my $xs = new XML::Simple( keyattr=>[] );
	return $xs->XMLin($xml);
}

sub Log {
	my $server_name = shift;
	my @param = @_;
    open(FILE, ">>" . $OpenUGAI::Global::LOGDIR . "/" . $server_name . ".log");
	foreach(@param) {
    	print FILE $_ . "\n";
	}
    print FILE "<<<<<<<<<<<=====================\n\n";
    close(FILE);
}

1;
