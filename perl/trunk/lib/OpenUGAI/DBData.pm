package OpenUGAI::DBData;

use DBHandler;

our $DSN = "dbi:mysql:opensim;host=localhost;";
our $DBUSER = "opensim";
our $DBPASS = "opensim";

sub getSimpleResult {
    my ($sql, $args) = @_;
    my $dbh = undef;
    my $result = undef;
    my $args_type = ref $args;
    my @db_args;
    if ($args_type eq "HASH") {
	@db_args = keys %$args;
    } elsif ($args_type eq "ARRAY") {
	@db_args = @$args;
    } else {
	push @db_args, $args;
    }
    eval {
	$dbh = &DBHandler::getConnection($DSN, $DBUSER, $DBPASS);
	my $st = new Statement($dbh, $sql);
	$result = $st->exec(@db_args);
    };
    if ($@) {
	Carp::croak("getsimpleresult failed: $sql -> " . $@);	
    }
    return $result;
}

1;

