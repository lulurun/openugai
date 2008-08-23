package OpenUGAI::DBData;

use OpenUGAI::Global;
use DBHandler;

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
	$dbh = &DBHandler::getConnection($OpenUGAI::Global::DSN, $OpenUGAI::Global::DBUSER, $OpenUGAI::Global::DBPASS);
	my $st = new Statement($dbh, $sql);
	$result = $st->exec(@db_args);
    };
    if ($@) {
	Carp::croak("getsimpleresult failed: $sql -> " . $@);	
    }
    return $result;
}

1;

