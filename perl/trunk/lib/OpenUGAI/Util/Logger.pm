package OpenUGAI::Util::Logger;

# @@@ this should be destoryed

use strict;
use Carp;
use Data::Dump;

sub new {
    my ($this, $log_dir, $name) = @_; 
    if (! -d $log_dir) {
	Carp::croak("$log_dir not avaliable");
    }
    my $log_file = $log_dir . "/" . $name . ".log";
    my %fields = (
		  _dir => $log_dir,
		  _name => $name, # @@@ will be used for advanced logger
		  _log_file => $log_file,
		  );
    return bless \%fields, $this;
}

sub log {
    # TODO @@@ High priority: move to Apache ErrorLog Handler
    my ($this, $event_name, $msg) = @_;
    if (ref $msg) {
	$msg = Data::Dump::dump($msg);
    }
    open(FILE, ">>" . $this->{_log_file}); # do not die, infinit loop !
    print FILE $event_name . "\n";
    print FILE $msg . "\n";
    print FILE "<<=====================\n\n";
    close(FILE);
}

1;

