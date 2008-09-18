package Gmail::Account;

use strict;
use Carp;
use LWP::UserAgent;
use HTTP::Headers;
use HTTP::Cookies;
use Data::Dump;

our $GMAIL_URL_LOGIN = "https://www.google.com/accounts/ServiceLoginBoxAuth";
our $GMAIL_URL_GMAIL = "https://mail.google.com/mail/?ui=1&";
our $USER_AGENT = "OpenUGAI::AssetServer::Gmail";
our $TIMEOUT = 5;

sub new {
    my ($this, $name, $pass) =@_;
    my $ua = new LWP::UserAgent( agent => $USER_AGENT, keep_alive => 1 );
    $ua->timeout($TIMEOUT);

    my %fields = (
		  name => $name,
		  passwd => $pass,
		  _ua => $ua,
		  _cookies => undef,
		  );

    bless \%fields, $this;
}

sub login {
    my $this = shift;
    my $req = HTTP::Request->new( POST => $GMAIL_URL_LOGIN);
    $req->header( 'Cookie' => $this->{_cookie} );
    $req->content_type( "application/x-www-form-urlencoded" );
    my %postdata = (
		     "continue" => $GMAIL_URL_GMAIL,
		     "Email" => $this->{name},
		     "Passwd" => $this->{passwd},
		     );
    $req->content(&_make_req_string(\%postdata));
    my $pagedata = $this->_request_gmail_page($req);

    if ($pagedata =~ /CheckCookie\?continue=([^\"\']+)/) {
	my $link = $1;
	$link = &_url_decode($link);
	$link =~ s/\\x26/\&/g;
	print $link . "\n\n";
	$req = HTTP::Request->new( GET => $link);
	$pagedata = $this->_request_gmail_page($req);
    } else {
	Carp::croak("can not login, check your name and password, or ask wolfdrawer to ask lulurun to update me");
    }
    print $pagedata . "\n";
    
}

sub _request_gmail_page {
    my ($this, $req) = @_;
    my $res = $this->{_ua}->request( $req );
    if ( !$res->is_success() ) {
	Carp::croak("HttpRequest failed: " . $res->status_line);
    }
    $this->_get_response_cookie($res);
    return $res->content();
}

sub _get_response_cookie {
    my ($this, $res) = @_;
    my $header = $res->header( 'Set-Cookie' );
    if ( defined( $header ) ) {
        my ( @cookies ) = split( ',', $header );
        foreach( @cookies ) {
            $_ =~ s/^\s*//;
            if ( $_ =~ /(.*?)=(.*?);/ ) {
                if ( $2 eq '' ) {
                    delete( $this->{_cookies}->{$1} );
                } else {
                    unless ( $1 =~ /\s/ ) {
                        if ( $1 ne '' ) {
                            $this->{_cookies}->{$1} = $2;
                        } else {
                            $this->{_cookies}->{'Session'} = $2;
                        }
                    }
                }
            }
        }
        $this->{_cookie} = join( '; ', map{ "$_=" . $this->{_cookies}->{$_} }( sort keys %{ $this->{_cookies} } ) );
    }
}


# ############
# util functions
sub _make_req_string {
    my $data = shift;
    my $str = "";
    foreach (keys %$data) {
	$str .= $_ . "=" . &_url_encode($data->{$_}) . "\&";
    }
    return $str;
}

sub _url_encode($) {
    my $str = shift;
    $str =~ s/([^\w ])/'%'.unpack('H2', $1)/eg;
    $str =~ tr/ /+/;
    return $str;
}

sub _url_decode($) {
    my $str = shift;
    $str =~ tr/+/ /;
    $str =~ s/%([0-9A-Fa-f][0-9A-Fa-f])/pack('H2', $1)/eg;
    return $str;
}
1;

