package OpenUGAI::AssetServer::Storage::FS;

use strict;
use Carp;
use File::Path;

use constant {
    DEFAULT_ROOT_DIR => "/tmp",
    MAX_ASSET_SIZE => "5M",
    MAX_TOTAL_SIZE => "5G",
    ASSOCIATIVE => 8,
    UUID_LENGTH => 32,
};

sub new {
    my ($this, $option) = @_;
    # config.assoc
    Carp::croak("bad assoc number") if ($option->{assoc} && UUID_LENGTH % $option->{assoc} != 0);
    my $assoc = $option->{assoc} || ASSOCIATIVE;
    my $path_length = UUID_LENGTH / $assoc;
    # config.root_dir
    my $root_dir = $option->{root_dir} || DEFAULT_ROOT_DIR;
    $root_dir =~ s/\/+$//;
    # config.presentation
    my $presen_class = $option->{presentation} || Carp::croak("no presentation class");

    my %fields = (
		  root_dir => $root_dir,
		  presen_class => $presen_class,
		  associative => $assoc,
		  path_length => $path_length,
		  );
    return bless \%fields, $this;
}

sub fetchAsset {
    my ($this, $id) = @_;
    my $file = $this->_getAbsolutePathbyID($id);
    if (-e $file) {
	return $this->{presen_class}->deserialize(&_read_file($file));
    }
    return 0;
}

sub storeAsset {
    my ($this, $asset) = @_;
    my $file = $this->_getAbsolutePathbyID($asset->{id});
    return &_save_file($file, $this->{presen_class}->serialize($asset));
}

sub deletAsset {
    my ($this, $id) = @_;
    my $file = $this->_getAbsolutePathbyID($id);
    if (-e $file && unlink($file)) {
	return 1;
    }
    return 0;    
}

# ##############
# sub functions
sub _getAbsolutePathbyID {
    my ($this, $id) = @_;
    $id =~ s/\-//g;
    $id = lc($id);
    # check
    if (length($id) != UUID_LENGTH || $id !~ /^[0-9a-f]+$/) {
	Carp::croak("not an UUID");
    }
    my @path = ();
    my $pos = 0;
    while ($pos < UUID_LENGTH) {
	push @path, substr($id, $pos, $this->{path_length});
	$pos += $this->{path_length};
    }
    pop @path;
    my $folder = $this->{root_dir} . "/" . join("/", @path);
    # create dir here
    if (! -d $folder) {
	File::Path::mkpath($folder);
    }
    return $folder . "/" . $id;
}

sub _read_file {
    my $file = shift;
    open(FILE, $file) || return 0;
    my @lines = <FILE>;
    close(FILE);
    return join("\n", @lines);
}

sub _save_file {
    my ($file, $contents) = @_;
    open(FILE, ">$file") || return 0;
    print FILE $contents; # TODO @@@ : Lock ?
    close(FILE);
    return 1;
}

1;


