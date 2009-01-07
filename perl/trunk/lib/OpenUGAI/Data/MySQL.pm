package OpenUGAI::Data::MySQL;

sub GetConnection {
	my ($dsn, $user, $pass) = @_;
	my $dbh = DBI->connect($dsn, $user, $pass);
	$dbh->{AutoCommit} = 1;
	$dbh->{RaiseError} = 1;
	return $dbh;
}

sub SimpleQuery {
    my ($sql, $args) = @_;
    my $dbh = undef;
    my $result = undef;
    my $args_type = ref $args;
    eval {
	$dbh = &GetConnection($OpenUGAI::Global::DSN, $OpenUGAI::Global::DBUSER, $OpenUGAI::Global::DBPASS);
	my $st = new OpenUGAI::Statement($dbh, $sql);
	if ($args) { # TODO: WD did this
	    if (ref $args ne "ARRAY") {
		Carp::croak("invalid type of args: " . ref $args);
	    }
	    $result = $st->exec(@$args);
	} else {
	    $result = $st->exec();
	}
    };
    if ($@) {
	Carp::croak("SimpleQuery failed: $sql -> " . $@);	
    }
    return $result;
}

# #############
# Simple statement TODO @@@ delete this class later
package OpenUGAI::Data::MySQL::Statement;

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

sub DESTROY {
    my $this = shift;
    my $sth  = $this->{sth};
    $sth->finish();
}

# #############
# Transaction
package OpenUGAI::Data::MySQL::Transaction;

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

