package OpenUGAI::RestService;

use CGI;
use strict;

sub new {
    my $this = shift;
    bless {
	hGET => undef,
	hPOST => undef,
	hPUT => undef,
	hDELETE => undef,
    }, $this;
}

sub registerHandler {
    my ($this, $method, $path, $handler) = @_;
    my $method_key = "h" . $method;
    $this->{$method_key}->{$path} = $handler;
    return 1;
}

sub run {
    my ($this, $arg) = @_;
    $arg = undef if (!$arg);
    my $cgi = new CGI($arg);

    my $method_key = "h" . $cgi->request_method;
    my $handlers = $this->{$method_key};
    foreach ( keys %$handlers ) {
	if (my @m = $cgi->path_info =~ $_) {
	    eval {
		$handlers->{$_}->($this, $cgi, @m);
	    };
	    if ($@) {
		Apache2::ServerRec::warn("RestService error: " . $@);
	    }
	    return;
	}
    }
    # not found handler
    print $cgi->header( -type => 'text/xml', -charset => "utf-8", -status => "404 Not Found" ), "";
}

1;

