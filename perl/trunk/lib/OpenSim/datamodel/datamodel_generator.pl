#!/usr/bin/perl

use strict;
use DBHandler;
use Data::Dump qw (dump);

my $db_name = "opensim";
my $DSN = "dbi:mysql:$db_name;";
my $DBUSER = "lulu";
my $DBPASS = undef;
my $LIB_PREFIX = "OpenSim::DataModel::";
my $TEMPLATE = "Table.pm";

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
    my $package_name = $LIB_PREFIX . $table;
    my $constructor = &generateConstructor($table, $fields);
    my $insert_func = &generateInsert($table, $fields);
    my $update_func = &generateUpdate($table, $fields);
    my $delete_func = &generateDelete($table, $fields);
    my $select_func = &generateSelect($table, $fields);
    my $model_tmpl = &getModelTemplate();
    $model_tmpl =~ s/<% PACKAGE_NAME %>/$package_name/;
    $model_tmpl =~ s/<% CONSTRUCTOR %>/$constructor/;
    $model_tmpl =~ s/<% INSERT %>/$insert_func/;
    $model_tmpl =~ s/<% UPDATE %>/$update_func/;
    $model_tmpl =~ s/<% DELETE %>/$delete_func/;
    $model_tmpl =~ s/<% SELECT %>/$select_func/;
    return $model_tmpl;
}

sub generateConstructor {
    my ($table, $fields) = @_;
    my @member_assign = map { $_->{Field} . " => \$struct{" . $_->{Field} . "} || undef," } @$fields;
    my $assignment = join "\n\t", @member_assign;

    return << "SUB_NEW";
sub new {
    my \$class = shift;
    my \$obj = shift;
    my \%struct = ref \$obj ? \%\$obj : ();
    my \%fields = (
	$assignment
	);
    return bless \\\%fields, \$class;
}
SUB_NEW
}

sub generateInsert {}

sub generateUpdate {}

sub generateDelete {}

sub generateSelect {}


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

sub getModelTemplate {
    open(FILE, $TEMPLATE);
    my @data = <FILE>;
    close(FILE);
    return join "", @data;
}
