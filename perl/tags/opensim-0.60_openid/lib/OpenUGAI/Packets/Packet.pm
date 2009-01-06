package Packet;

use strict;
use constant {
	OUT_BLOCK => 1,
	IN_BLOCK => 2,
};

sub new {
	my $this = shift;
	my %fields = (
		name => undef,
		freq => undef,
		id => undef,
		reliable => undef,
		zerocoded => undef,
		block_list => undef,
	);
	return bless \%fields, $this;
}

sub parse_template {
	my ($this, $text) = @_;
	my @lines = split(/\n/, $text);
	my $title = shift @lines;
	$title =~ s/^\s+//;
	my ($name, $freq, $id, $reliable, $zerocoded) = split(/\s+/, $title);
	$this->{name} = $name || die "bad template, not name: $text";
	$this->{freq} = $freq || die "bad template, not freq: $text";
	$this->{id} = $id || die "bad template, not id: $text";
	$this->{reliable} = $reliable eq "NotTrusted" ? "false" : "true";
	$this->{zerocoded} = $zerocoded || die "bad template, not name: $text";
	my $state = OUT_BLOCK;
	my $count = 0;
	my $current_block = "";
	foreach (@lines) {
		$count++;
		if ($_ =~ /^\s+{\s*$/) {
			die "bad template 1: error at: $count\n$text" if ($state != OUT_BLOCK);
			$state = IN_BLOCK;
			next;
		}
		if ($_ =~ /^\s+}\s*$/) {
			die "bad template 2: error at: $count\n$text" if ($state != IN_BLOCK);
			$state = OUT_BLOCK;
			next;
		}
		if ($_ =~ /^\s+\{([^\}]+)\}.*$/) {
			# member
			my $member_text = $1;
			$member_text =~ s/^\s*//;
			$member_text =~ s/\s*$//;
			my ($name, $type) = split(/\s+/, $member_text);
			push @{$current_block->{members}}, $member_text;
			next;
		} else {
			$_ =~ s/^\s*//;
			$_ =~ s/\s*$//;
			my ($name, $type, $number) = split(/\s+/, $_);
			my %block = (
				name => $name,
				number => $number || $type,
			);
			$current_block = \%block;
			push @{$this->{block_list}}, \%block;
		}
	}
}

sub _parse_template_block {
	my $text = shift;
	
}

sub toString {
	my $this = shift;
	my $ret_string = $this->{name} . "\t" . $this->{freq} . "\t" . $this->{id} . "\n";
	my $block_list = $this->{block_list};
	foreach my $block (@$block_list) {
		$ret_string .= "\t" . $block->{name} . "\t" . $block->{number} . "\n";
		foreach (@{$block->{members}}) {
			$ret_string .= "\t\t$_\n";
		}
	}
	return $ret_string;
}

1;



