use strict;
use DBI;
use Carp;

package DBHandler;

sub getConnection {
	my ($dsn, $user, $pass) = @_;
	#return $DB_CONNECTION if ($DB_CONNECTION);
	my $dbh = DBI->connect($dsn, $user, $pass);
	$dbh->{AutoCommit} = 1;
	$dbh->{RaiseError} = 1;
	return $dbh;
}

# #############
# Simple statement
package Statement;

sub new {
	my ( $this, $dbh, $sql, $is_trans ) = @_;
	# @@@ sql should be tested OK, so here just die
	my $sth = $dbh->prepare($sql) || Carp::croak( $dbh->errstr );
	my %fields = (
		dbh => $dbh,
		sql => $sql,
		sth => $sth,
		is_trans => $is_trans,
	);
	return bless \%fields, $this;
}

sub exec {
	my ( $this, @param ) = @_;
	my $dbh = $this->{dbh};
	my $sth = $this->{sth};
	my $sql = $this->{sql};

	if ( !$sth->execute(@param) ) {
		if ( $this->{is_trans} ) {
			$dbh->rollback();
		}
		Carp::croak( $dbh->errstr );
	}
	my @ret = ();
	if ( $sql =~ /^select|show|desc/i ) {
		# @@@ get result object
		while ( my $res = $sth->fetchrow_hashref() ) {
			push @ret, $res;
		}
	}
	# @@@ $sth->finish();
	return \@ret;
}

sub last_id {
	my $this = shift;
	my $dbh = $this->{dbh};
	return $dbh->last_insert_id(undef, undef, undef, undef);
}

sub DESTROY {
	my $this = shift;
	my $sth  = $this->{sth};
	$sth->finish();
}

# #############
# Transaction
package Transaction;

my $IS_TRANS = 1;

sub new {
	my ( $this, $dbh ) = @_;
	# @@@ fatal error, just die
	$dbh->begin_work() || Carp::croak( $dbh->errstr );
	my %fields = (
		dbh    => $dbh,
		Active => 1,
	);
	return bless \%fields, $this;
}

sub createStatement {
	my ( $this, $sql) = @_;
	# @@@ fatal error, just die
	Carp::croak("transaction not begin") if ( !$this->{Active} );
	my $dbh    = $this->{dbh};
	return new Statement($dbh, $sql, $IS_TRANS);
}

sub commit {
	my $this = shift;
	my $dbh  = $this->{dbh};
	if ( $this->{Active} && !$dbh->{AutoCommit} ) {
		$dbh->commit || Carp::croak( $dbh->errstr );
	}
	$this->{Active} = 0;
}

sub rollback {
	my $this = shift;
	my $dbh  = $this->{dbh};
	if ( $this->{Active} && !$dbh->{AutoCommit} ) {
		$dbh->rollback || Carp::croak( $dbh->errstr );
	}
	$this->{Active} = 0;
}

sub DESTROY {
	my $this = shift;
	$this->rollback;
}

1;    
