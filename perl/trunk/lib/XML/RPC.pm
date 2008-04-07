package XML::RPC;

use strict;
use Carp;
use RPC::XML;
use RPC::XML::Parser;
use RPC::XML::Client;

sub new {
    my ($this, $url) = @_;
    my %fields = (
	parser => new RPC::XML::Parser(),
	url => $url,
	);
    return bless \%fields, $this;
}

sub receive {
    my ($this, $xmldata, $handler) = @_;
    my $request = $this->{parser}->parse($xmldata);
    my @args = map {$_->value} @{$request->args};
    my $response = undef;
    eval {
	$response = $handler->($request->{name}, @args);
    };
    if ($@) {
	my %error = (
	    "error" => "ERROR: " . $request->{name},
	    "message" => $@,
	    );
	$response = \%error;
    }
    return RPC::XML::response->new($response)->as_string;
}

sub call {
    my ($this, $method_name, $param) = @_;
    my $client = RPC::XML::Client->new($this->{url});
    my $request_param = undef;
    my $req = undef;
    if (ref $param eq "ARRAY") {
	$request_param = &_make_array_param($param);
	$req = RPC::XML::request->new(
	    $method_name,
	    @$request_param,
	    );
    } elsif (ref $param eq "HASH"){
	$request_param = &_make_hash_param($param);
	$req = RPC::XML::request->new(
	    $method_name,
	    $request_param,
	    );
    } else {
	Carp::croak("unexpected param type");
    }
    my $rpc_res = $client->send_request($req);
    return $rpc_res if (!ref($rpc_res));
    my %res = map { $_ => $rpc_res->{$_}->value } keys %$rpc_res; # remember good perl !!
    return \%res;
}

sub _make_array_param {
    my $param = shift;
    my @array_param = ();
    foreach (@$param) {
	push @array_param, RPC::XML::string->new($_); # @@@ only string type
    }
    return \@array_param;
}

sub _make_hash_param {
    my $param = shift;
    my %hash_param = ();
    foreach (keys %$param) {
	$hash_param{$_} = RPC::XML::string->new($param->{$_}); # @@@ only string type
    }
    return RPC::XML::struct->new(\%hash_param);
}

1;

