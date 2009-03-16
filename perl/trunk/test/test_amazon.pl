#!/usr/bin/perl

use strict;

use Net::Amazon;
use Net::Amazon::Request::ASIN;
use Data::Dump;

my $token = "0ZTP8S29WJMEXNCWQ182";
my $asin = "0201360683";

my $ua = Net::Amazon->new(
			  token => $token,
			  max_pages => 5,
			  );
&search($ua);

sub keyword {
    my $req = Net::Amazon::Request::Keyword->new(
						 keyword   => $ARGV[0],
						 mode      => $ARGV[1],
						 );

 # Response: Net::Amazon::Keyword::Response
my $resp = $ua->request($req);

for ($resp->properties) {
   print $_->Asin(), " ",
   $_->OurPrice(), "\n";
}

}

sub search {
    my $ua = shift;
    my $resp = $ua->search(
			   asin  => $asin,
			   );

    print Data::Dump::dump $resp;
    if($resp->is_success()) {
	print $resp->as_string(), "\n";
    } else {
	print "Error: ", 
	$resp->message(), "\n";
    }
}

sub request {
    my $ua = shift;
    my $req = Net::Amazon::Request::ASIN->new(
					      asin => $asin,
					      );

    my $resp = $ua->request($req);
    print Data::Dump::dump $resp;
    
    if ($resp->is_success()) {
	print $resp->as_string() . "\n";
    } else {
	print "Error: ", $resp->message(), "\n";
    }
}


