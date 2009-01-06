#!/usr/bin/perl

use strict;
use warnings;

use Cache::File;
use LWP::UserAgent;
use Net::OpenID::Consumer;
use OpenUGAI::Global;
use LWPx::ParanoidAgent;
use CGI;

my $USER_SREG = 0;

my $claimed_id = $ARGV[0] || "lulurun.myopenid.com";

my $csr = new Net::OpenID::Consumer(
				    ua    => new LWPx::ParanoidAgent(),
				    args  => new CGI, # TODO: should be $param
				    consumer_secret => $OpenUGAI::Global::OPENID_CONSUMER_SECRET,
				    );

if (my $cident = $csr->claimed_identity($claimed_id)) {
    if ($USER_SREG) {
	# sreg
	$cident->set_extension_args("http://openid.net/extensions/sreg/1.1", {
	    required => join(",", qw/email nickname/)
	    });
    } else {
	# ax
	$cident->set_extension_args($OpenUGAI::Global::OPENID_NS_AX_1_0, {
	    mode => 'fetch_request',
	    "type.nickname" => "http://schema.openid.net/namePerson/friendly",
	    "type.email" => "http://schema.openid.net/contact/email",
	    "type.firstname" => "http://schema.openid.net/namePerson/first",
	    "type.lastname" => "http://schema.openid.net/namePerson/last",
	    required => 'nickname,email,firstname,lastname',
	});
    }
    my $check_url = $cident->check_url(
				       return_to => "http://openugai.wolfdrawer.net/perl/trunk/login.cgi?method=openid_verify",
				       trust_root => "http://openugai.wolfdrawer.net/",
				       delayed_return => "checkid_setup",
				       );
    
    print "[check_url]\n";
    print $check_url . "\n\n";
}

__END__

#!/usr/bin/perl

use strict;
use warnings;

use LWP::UserAgent;
use Net::OpenID::Consumer;

my $claimed_id = $ARGV[0] || "lulurun.myopenid.com";
my $csr = Net::OpenID::Consumer->new(
				     ua => LWP::UserAgent->new,
				     consumer_secret => 'lulurun',
				     args => {},
				     required_root => 'http://localhost:3000/',
				     debug => 1,
				     );

if (my $cident = $csr->claimed_identity($claimed_id)) {
    $cident->set_extension_args("http://openid.net/extensions/sreg/1.1", {
        required => join(",", qw/email nickname/)
	});
    
    my $check_url = $cident->check_url(
				       return_to => "http://localhost:3000/login/handler",
				       trust_root => "http://localhost:3000/",
				       delayed_return => "checkid_setup",
				       );
    print "[check_url]\n";
    print $check_url;
}


