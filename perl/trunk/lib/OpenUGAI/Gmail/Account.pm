package OpenUGAI::Gmail::Account;

use strict;
use Carp;
use LWP::UserAgent;
use HTTP::Headers;
use HTTP::Cookies;

use OpenUGAI::Gmail::Message;

use Data::Dump;

our $GMAIL_URL_LOGIN = "https://www.google.com/accounts/ServiceLoginBoxAuth";
our $GMAIL_URL_GMAIL = "https://mail.google.com/mail/?ui=1&";
our $USER_AGENT = "OpenUGAI::AssetServer::Gmail";
our $TIMEOUT = 5;
our $COOKIE_CACHE = ".cookies";

sub new {
    my ($this, $name, $pass) =@_;
    # create agent
    my $ua = new LWP::UserAgent( agent => $USER_AGENT, keep_alive => 1 );
    $ua->cookie_jar( {file => $COOKIE_CACHE, auto_save => 1} );
    $ua->timeout($TIMEOUT);

    my %fields = (
		  name => $name,
		  passwd => $pass,
		  login => 0,
		  _ua => $ua,
		  );

    bless \%fields, $this;
}

sub login {
    my $this = shift;
    return if ($this->{login});
    my $req = HTTP::Request->new( POST => $GMAIL_URL_LOGIN);
    $req->content_type( "application/x-www-form-urlencoded" );
    my %postdata = (
		     "continue" => $GMAIL_URL_GMAIL,
		     "Email" => $this->{name},
		     "Passwd" => $this->{passwd},
		     );
    $req->content(&_make_req_string(\%postdata));
    my $pagedata = $this->_request_page($req);
    if ($pagedata =~ /CheckCookie\?continue=([^\"\']+)/) {
	my $link = $1;
	$link = &_url_decode($link);
	$link =~ s/\\x26/\&/g;
	$req = HTTP::Request->new( GET => $link);
	$pagedata = $this->_request_page($req);
    } else {
	Carp::croak("can not login, check your name and password, or ask wolfdrawer to ask lulurun to update me");
    }
    $this->{login} = 1;
}

sub _get_GMAILAT {
    my $this = shift;
    my $cookie_jar = $this->{_ua}->cookie_jar();
    # print Data::Dump::dump($cookie_jar) . "\n\n";
    # TODO @@@ is there any other way ?
    my $at_string = "";
    eval {
	my $mail_cookie = $cookie_jar->{"COOKIES"}->{"mail.google.com"};
	$at_string = $mail_cookie->{"/mail"}->{"GMAIL_AT"}->[1];
    };
    if ($@) {
	Carp::croak("get_GMAILAT failed: " . $@);
    }
    return $at_string;
}

sub sendMessage {
    my ($this, $to, $subject, $body, $opt) = @_;
    my $at = $this->_get_GMAILAT();
    my $msg = new OpenUGAI::Gmail::Message($to, $subject, $body, $at, $opt);
    my $mheader = $msg->getHeader();
    my $mbody = $msg->getBody();
    # TODO: $mbody needs to be encoded
    my $req = HTTP::Request->new("POST", $GMAIL_URL_GMAIL);
    $req->header("Content-Type" => $mheader->{"Content-Type"});
    $req->content($mbody);
    my $pagedata = $this->_request_page($req);
    # print $pagedata . "\n\n";
    # check returned data
    my $send_success = 0;
    if ($pagedata =~ /\[\"drafts\",(\d+)\]/) {
	my $drafts = $1;
	# if ($drafts > $this->{drafts}) {
	#     $send_success = 1;
        # }
    }
    if (!$send_success) {
	Carp::croak("failed to save message");
    }
}

sub readMessage {
}

sub _request_page {
    my ($this, $req) = @_;
    my $res = $this->{_ua}->request( $req );
    if ( !$res->is_success() ) {
	Carp::croak("HttpRequest failed:\n\t" . $res->status_line);
    }
    return $res->content();
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

