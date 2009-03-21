package OpenUGAI::SimpleRestService;

use CGI;
use strict;
use Data::Dump;

sub new {
    my $this = shift;
    bless {
	GET => {},
	POST => {},
	PUT => {},
	DELETE => {},
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
   while ( my ($path_pattern, $handler) = each(%{$this->{$cgi->request_method}}) ) {
	if ($cgi->path_info =~ $path_pattern) {
	    $handler->($1, $cgi);
	    return;
	}
    }
    Carp::croak("404 not found");    
}

1;

