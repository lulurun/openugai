package OpenUGAI::SpaceWeb;

use strict;
use Carp;
use OpenUGAI::RestService;
our @ISA = qw(OpenUGAI::RestService);
use OpenUGAI::Global;
use Template;

our $Instance;

sub StartUp {
    $Instance = OpenUGAI::SpaceWeb->new( { log_name => "spaceweb", } );
    $Instance->init();
}

sub new {
    my $this = shift;
    my $options = shift;
    my $super = OpenUGAI::RestService->new($options);
    return bless $super, $this;
}

sub init {
    my $this = shift;

    # register handlers
    $this->registerHandler( "GET", qr{^/contents/info/([0-9a-f\-]{36})$}, \&_get_contents_info_handler );
}

sub _get_contents_info_handler {
    my ($this, $cgi, $id) = @_; 
 
    Apache2::ServerRec::warn("test::: " . $id);
    my $html = Template::Get("contents_info.html");
    $html =~ s/{%CONTENTS_UUID%}/$id/;
    print $cgi->header( -type => 'text/html', -charset => "utf-8" ), $html;
}

1;

