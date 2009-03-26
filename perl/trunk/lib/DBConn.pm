package Statement;

use strict;
use DBI;
use Carp;

sub new {
    my ( $this, $db_info, $sql) = @_;
    # connect
    my $dbh = DBI->connect($db_info->{dsn}, $db_info->{user}, $db_info->{pass});
    $dbh->{AutoCommit} = 1;
    $dbh->{RaiseError} = 1;
    # @@@ why ?
    my $sth = $dbh->prepare($sql) || Carp::croak( $dbh->errstr );
    my %fields = (
		  dbh => $dbh,
		  sql => $sql,
		  sth => $sth,
		  );
    return bless \%fields, $this;
}

sub execute {
    my ( $this, @param ) = @_;
    my $dbh = $this->{dbh};
    my $sth = $this->{sth};
    my $sql = $this->{sql};
    
    Carp::croak( $dbh->errstr ) unless $sth->execute(@param);

    if ( $sql =~ /^select|show|desc/i ) {
	my @ret = ();
	# @@@ get result object
	while ( my $res = $sth->fetchrow_hashref() ) {
	    push @ret, $res;
	}
	return \@ret;
    }
    # @@@ $sth->finish();
    return 1;
}

sub DESTROY {
    my $this = shift;
    my $sth  = $this->{sth};
    $sth->finish();
}

package DBConn;

sub new {
    my ($this, $db_info) = @_;
    Carp::croak("not enough db info") unless ($db_info->{dsn} && $db_info->{user} && $db_info->{pass});
    my %fields = (
		  db_info => $db_info,
		  );
    return bless \%fields, $this;
}

sub query {
    my ($this, $sql, $args) = @_;
    Carp::croak("bad type of args") if (ref $args ne "ARRAY");
    my $st = new Statement($this->{db_info}, $sql);
    my $res = $st->execute(@$args);
    return $res;
}

1;

__END__

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

