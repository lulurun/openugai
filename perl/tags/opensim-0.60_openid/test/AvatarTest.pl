# make assetset for avatarappearance
#
#!/usr/bin/perl -w

use strict;
use OpenUGAI::Avatar::Appearance;
use OpenUGAI::Utility;

# use fixed file name
my %te_name2idx = (
		   eye => 3,
		   hair => 4,
		   jacket_top => 13,
		   jacket_lower => 14,
		   pants => 2,
		   shoes => 7,
		   skin_face => 0,
		   skin_upper => 5,
		   skin_lower => 6,
		   underwear => 17,
		   );

# get asset file list
my $base_dir = $ARGV[0] || "";
my $out_dir = $ARGV[1] || "";
opendir(DIR, $base_dir) || die "can not open $base_dir";
my @file_list = readdir(DIR);
closedir(DIR);
my %file2uuid = ();
my %teidx2uuid = ();
my %appearances = ();
foreach (@file_list) {
    next if ($_ eq ".");
    next if ($_ eq "..");
    my $uuid = &OpenUGAI::Utility::GenerateUUID;
    $file2uuid{$_} = $uuid;
    # texture file
    if ($_ =~ /\.jp2$/) {
	$teidx2uuid{&GuessTextureIndex($_)} = $uuid;
    }
    # param file
    if ($_ =~ /\.dat$/) {
        $appearances{$_} = &ParseLLWearableFile($base_dir . "/" . $_);
    }
}

# reassign texutures uuid
foreach my $filename (keys %appearances) {
    my $appea = $appearances{$filename};
    my $textures = $appea->{textures};
    foreach (keys %$textures) {
	$textures->{$_} = $teidx2uuid{$_};
    }
    $appea->{textures} = $textures;
    # update appearance file
    my $app_file = "$out_dir/$filename";
    open(FILE, ">$app_file") || die "can not open $app_file";
    print FILE $appea->ToLLFormat();
    close(FILE);
}

# make assetset xml
my $xml = "<Nini>\n";
foreach(keys %file2uuid) {
    my $filename = $_;
    my ($asset_name, undef) = split(/\./, $filename);
    my $uuid = $file2uuid{$filename};
    $xml .= << "XML_SECTION";
 <Section Name="$asset_name">
    <Key Name="assetID" Value="$uuid" />
    <Key Name="name" Value="$asset_name" />
    <Key Name="assetType" Value="0" />
    <Key Name="inventoryType" Value="0" />
    <Key Name="fileName" Value="$filename" />
  </Section>
XML_SECTION
}
$xml .= "</Nini>\n";
my $assetset_file = "$out_dir/new.xml";
open(FILE, ">$assetset_file") || die "can not open $assetset_file";
print FILE $xml;
close(FILE);

# end ...


# #####################
# guess texture index
sub GuessTextureIndex {
    my $filename = shift;
    foreach (keys %te_name2idx) {
	my $pattern = $_;
	my $index = $te_name2idx{$pattern};
	if ($filename =~ /$pattern/i) {
	    print "Guess $index $filename\n";
	    return $index;
	}
    }
    # must die
    die "WARN guess failed for $filename";
}

# #####################
# parse appearance file
sub ParseLLWearableFile {
    my $file = shift;
    open(FILE, $file) || die "can not open $file";
    my @data = <FILE>;
    close(FILE);
    my $appearance_string = join "", @data;
    my $appearance = new OpenUGAI::Avatar::Appearance($appearance_string);
    return $appearance;
}
