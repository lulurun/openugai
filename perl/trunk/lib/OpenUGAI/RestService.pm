package OpenUGAI::RestService;

use CGI;
use strict;
use OpenUGAI::Util::Logger;
use OpenUGAI::Global; # temporary!

sub new {
    my $this = shift;
    bless {
	GET => {},
	POST => {},
	PUT => {},
	DELETE => {},
	logger => new OpenUGAI::Util::Logger($OpenUGAI::Global::LOGDIR, "REST"),
    }, $this;
}

sub registerHandler {
    my ($this, $method, $path, $handler) = @_;
    return 0 if (! $this->{$method});
    $this->{$method}->{$path} = $handler;
    return 1;
}

sub run {
    my ($this, $arg) = @_;
    $arg = undef if (!$arg);
    my $cgi = new CGI($arg);

    $this->{logger}->log("path_info", $cgi->path_info);
    $this->{logger}->log("in coming postdata", $cgi->param("POSTDATA"));

    while ( my ($path_pattern, $handler) = each(%{$this->{$cgi->request_method}}) ) {
	if ($cgi->path_info =~ $path_pattern) {
	    eval {
		$handler->($1, $cgi);
	    };
	    if ($@) {
		$this->{logger}->log("error", $@);
	    }
	    return;
	}
    }
    Carp::croak("404 not found");    
}

1;

