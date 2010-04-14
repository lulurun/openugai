# waiting for better solution
package Template;

use strict;
use Carp;
use OpenUGAI::Global;

our %OPENSIM_TEMPLATE = ();

sub Get {
    my $tmpl_name = shift;
    my $cache = shift;
    return $OPENSIM_TEMPLATE{$tmpl_name} if $OPENSIM_TEMPLATE{$tmpl_name};
    return &_load($tmpl_name, $cache);
}

sub _load {
    my $tmpl_name = shift;
    my $cache = shift;
    my $file = $OpenUGAI::Global::TMPLDIR . "/" . $tmpl_name;
    open(FILE, $file) || croak("can not open $file"); # fatal,need no error handle
    my @lines = <FILE>;
    close(FILE);
    my $contents = join("", @lines);
    if ($cache) {
	$OPENSIM_TEMPLATE{$tmpl_name} = $contents;
    }
    return $contents;
}

1;
