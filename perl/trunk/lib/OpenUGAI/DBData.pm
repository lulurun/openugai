package OpenUGAI::DBData;

use DBHandler;

our $DSN = "dbi:mysql:openasset3;host=192.168.50.3;";
our $DBUSER = "liu";
our $DBPASS = undef;

sub getSimpleResult {
	my ($sql, @args) = @_;
	my $dbh = &DBHandler::getConnection($DSN, $DBUSER, $DBPASS);
	my $st = new Statement($dbh, $sql);
	return $st->exec(@args);
}

1;

