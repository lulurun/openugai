package OpenUGAI::SampleApp;

use strict;
use Template;

sub LoginForm {
    my ($param, $msg) = @_;
    my $login_form_tmpl = &Template::Get("login_form");
    $login_form_tmpl =~ s/\[\$errors\]/$msg/;
    $login_form_tmpl =~ s/\[\$firstname\]/$param->{username}/g;
    $login_form_tmpl =~ s/\[\$lastname\]/$param->{lastname}/g;
    $login_form_tmpl =~ s/\[\$password\]/$param->{password}/g;
    $login_form_tmpl =~ s/\[\$remember_password\]/$param->{remember}/g; # TODO
    $login_form_tmpl =~ s/\[\$grid\]/$param->{grid}/g;
    $login_form_tmpl =~ s/\[\$region\]/$param->{region}/g;
    $login_form_tmpl =~ s/\[\$location\]/$param->{location}/g;
    $login_form_tmpl =~ s/\[\$channel\]/$param->{channel}/g;
    $login_form_tmpl =~ s/\[\$version\]/$param->{version}/g;
    $login_form_tmpl =~ s/\[\$lang\]/$param->{lang}/g;
    # openid
    $login_form_tmpl =~ s/\[\$openid_errors\]/$msg/;
    $login_form_tmpl =~ s/\[\$openid_identifier\]/$param->{openid_identifier}/;

    return $login_form_tmpl;
}

sub Guide {
    return &Template::Get("guide");
}

1;
