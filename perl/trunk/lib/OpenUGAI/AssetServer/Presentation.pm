package OpenUGAI::AssetServer::Presentation;

use Carp;

sub new {
    my ($this, $presentation_name) = @_;
    if ($presentation_name eq "XML" || $presentation_name eq "OpenSim") {
	my $class_name = $this . "::XML";
	eval "require $class_name";
	if ($@) {
	    Carp::croak("FATAL: $@");
	}
	my $obj = undef;
	return bless \$obj, "OpenUGAI::AssetServer::Presentation::XML";
    } else {
	Carp::croak("unknown presentation name");
    }
    return undef;
}

1;


