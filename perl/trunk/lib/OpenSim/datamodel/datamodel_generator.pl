#!/usr/bin/perl

use strict;
use DBHandler;
use Data::Dump qw (dump);

my $db_name = "appearance";
my $DSN = "dbi:mysql:appearance;host=192.168.50.3;";
my $DBUSER = "liu";
my $DBPASS = undef;
my $LIB_PREFIX = "OpenSim::DataModel::";

my $res = getSimpleResult("show tables");
my $key = "Tables_in_" . $db_name;
foreach (@$res) {
    my $table_name = $_->{$key};
    my $pm = &generateTableMapper($table_name);
    print $pm;
    last;
}

# ##########
#
sub generateDataModel {
    my ($table, $fields) = @_;
    my $constructor = &generateConstructor($table, $fileds);
    my $insert_func = &generateInsert($table, $fields);
    my $update_func = &generateUpdate($table, $fields);
    my $delete_func = &generateDelete($table, $fields);
    my $select_func = &generateSelect($table, $fields);
    my $model_tmpl = &getModelTemplate();
    $model_tmpl =~ s/<% CONSTRUCTOR %>/$constructor/;
    $model_tmpl =~ s/<% INSERT %>/$insert_func/;
    $model_tmpl =~ s/<% UPDATE %>/$update_func/;
    $model_tmpl =~ s/<% DELETE %>/$delete_func/;
    $model_tmpl =~ s/<% SELECT %>/$select_func/;
    return $model_tmpl;
}

sub generateTableMapper {
    my $table = shift;
    my $sql = "desc " . $table;
    my $fields = &getSimpleResult($sql);
    return &generateDataModel($table, $fields);
}

sub getSimpleResult {
    my ($sql, $args) = @_;
    my @sql_args = $args ? @$args : ();
    my $dbh = &DBHandler::getConnection($DSN, $DBUSER, $DBPASS);
    my $st = new Statement($dbh, $sql);
    my $res = $st->exec(@sql_args);
}


