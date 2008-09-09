package OpenUGAI::Avatar::Appearance;

use constant VersionString => "LLWearable version 22";
use constant WearableType => {
    Shape => 0,
    Skin => 1,
    Hair => 2,
    Eyes => 3,
    Shirt => 4,
    Pants => 5,
    Shoes => 6,
    Socks => 7,
    Jacket => 8,
    Gloves => 9,
    Undershirt => 10,
    Underpants => 11,
    Skirt => 12,
    Invalid => 255,
};
use constant TextureIndex => {
    Unknown => -1,
    HeadBodypaint => 0,
    UpperShirt => 1,
    LowerPants => 2,
    EyesIris => 3,
    Hair => 4,
    UpperBodypaint => 5,
    LowerBodypaint => 6,
    LowerShoes => 7,
    HeadBaked => 8,
    UpperBaked => 9,
    LowerBaked => 10,
    EyesBaked => 11,
    LowerSocks => 12,
    UpperJacket => 13,
    LowerJacket => 14,
    UpperGloves => 15,
    UpperUndershirt => 16,
    LowerUnderpants => 17,
    Skirt => 18,
    SkirtBaked => 19,
};

use constant ParserHandler => {
    permissions => \&_parse_permissions,
    sale_info => \&_parse_sale_info,
    type => \&_parse_type,
    parameters => \&_parse_parameters,
    textures => \&_parse_textures,
    null => \&_parse_null,
};

sub new {
    my ($this, $appearance_string) = @_;
    my $fields = &FromLLFormat($appearance_string);
    return bless $fields, $this;
}

sub ToLLFormat {
    my $this = shift;
    my $text = "";
    $text .= $this->{version} . "\n";
    $text .= $this->{name} . "\n";
    $text .= $this->{description} . "\n";
    $text .= $this->{permissions};
    $text .= $this->{sale_info};
    $text .= "type " . $this->{type} . "\n";
    $text .= $this->{parameters};
    $text .= &_textures_to_string($this->{textures});
    return $text;
}

sub FromLLFormat {
    my $appearance_string = shift;
    $appearance_string =~ s/\r+//g;
    my @lines = split(/\n/, $appearance_string);
    my %appearance = ();

    $appearance{version} = shift @lines;
    if ($appearance{version} ne VersionString) {
	Carp::croak("unknown version! " . $appearance{version});
      }
    $appearance{name} = shift @lines;
    $appearance{description} = shift @lines;

    my $state = "null";
    my $buffer = "";
    foreach (@lines) {
	if ($_ =~ /^\s*permissions/i) {
	    $appearance{$state} = ParserHandler->{$state}->($buffer);
	    $buffer = "";
	    $state = "permissions";
	}
	if ($_ =~ /^\s*sale_info/i) {
	    $appearance{$state} = ParserHandler->{$state}->($buffer);
	    $buffer = "";
	    $state = "sale_info";
	}
	if ($_ =~ /^\s*type/i) {
	    $appearance{$state} = ParserHandler->{$state}->($buffer);
	    $buffer = "";
	    $state = "type";
	}
	if ($_ =~ /^\s*parameters/i) {
	    $appearance{$state} = ParserHandler->{$state}->($buffer);
	    $buffer = "";
	    $state = "parameters";
	}
	if ($_ =~ /^\s*textures/i) {
	    $appearance{$state} = ParserHandler->{$state}->($buffer);
	    $buffer = "";
	    $state = "textures";
	}
	$buffer .= $_ . "\n";
    }
    $appearance{$state} = ParserHandler->{$state}->($buffer);
    delete $appearance{null};
    return \%appearance;
}

sub _parse_permissions {
    my $buffer= shift;
    return $buffer;
}

sub _parse_sale_info {
    my $buffer= shift;
    return $buffer;
}

sub _parse_type {
    my $text = shift;
    my (undef, $type) = split(/\s+/, $text);
    return $type;
}

sub _parse_parameters {
    return shift;
}

sub _parse_textures {
    my $buffer = shift;
    my @lines = split(/\n/, $buffer);
    my %texture = ();
    foreach (@lines) {
	my ($type, $uuid) = split(/\s+/, $_);
	$textures{$type} = $uuid;
    }
    return shift;
}

sub _textures_to_string {
    my $textures = shift;
    my $buffer = "";
    foreach (keys %$textures) {
	$buffer = $_ . " " . $textures->{$_} . "\n";
    }
    return $buffer;
}

sub _parse_null {
    return "";
}

1;

