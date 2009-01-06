# waiting for better solution
package Template;

use strict;
use Carp;
use OpenUGAI::Global;

our %OPENSIM_TEMPLATE = (
    login_form => "",
    guide => "",
);

sub Get {
    my $tmpl_name = shift;
    return $OPENSIM_TEMPLATE{$tmpl_name} if $OPENSIM_TEMPLATE{$tmpl_name};
    return &_load($tmpl_name);
}

sub _load {
    my $tmpl_name = shift;
    my $file = $OpenUGAI::Global::TMPLDIR . "/" . $tmpl_name;
    open(FILE, $file) || croak("can not open $file"); # fatal,need no error handle
    my @lines = <FILE>;
    close(FILE);
    my $contents = join("", @lines);
    $OPENSIM_TEMPLATE{$tmpl_name} = $contents;
    return $contents;
}
