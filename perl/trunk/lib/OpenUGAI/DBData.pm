package OpenUGAI::DBData;

use DBHandler;

our $DSN = "dbi:mysql:opensim;host=localhost;";
our $DBUSER = "opensim";
our $DBPASS = "opensim";

sub getSimpleResult {
    my ($sql, @args) = @_;
    my $dbh = undef;
    my $result = undef;
    eval {
	$dbh = &DBHandler::getConnection($DSN, $DBUSER, $DBPASS);
	my $st = new Statement($dbh, $sql);
	$result = $st->exec(@args);
    };
    if ($@) {
	Carp::croak("getsimpleresult failed: $sql -> " . $@);	
    }
    return $result;
}

1;

