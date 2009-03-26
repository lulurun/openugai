package OpenUGAI::Packets::Generator;

use strict;

my $packet_template;
my $block_template;
my $impl_template;
my %data_type_table;
my %packet_freq_table;
my $output_dir;
my $SecondlifePacketCommonHeaderFile;

BEGIN {
	my $data_dir = "/srv/www/htdocs/opensim/data";
	my $packet_template_file = $data_dir . "/packet_class_template.txt";
	my $block_template_file = $data_dir . "/packet_block_template.txt";
	my $impl_template_file = $data_dir . "/packet_impl_template.txt";
	# init packet_template
	$packet_template = "";
	open(FILE, $packet_template_file) || die "can not open $packet_template_file";
	while(<FILE>) {
		$packet_template .= $_;
	}
	close(FILE);
	# init block_template
	$block_template = "";
	open(FILE, $block_template_file) || die "can not open $block_template_file";
	while(<FILE>) {
		$block_template .= $_;
	}
	close(FILE);
	# init impl_template
	$impl_template = "";
	open(FILE, $impl_template_file) || die "can not open $impl_template_file";
	while(<FILE>) {
		$impl_template .= $_;
	}
	close(FILE);
	# init tables
	%data_type_table = (
		BOOL			=> "uint8_t",
		F32				=> "float",
		F64				=> "double",
		Fixed			=> undef,
		IPADDR			=> undef,
		IPPORT			=> undef,
		LLQuaternion	=> undef,
		LLUUID			=> "SERIALIZABLE_UUID",
		LLVector3		=> undef,
		LLVector3d		=> undef,
		LLVector4		=> undef,
		S16				=> "int16_t",
		S32				=> "int32_t",
		S8				=> "int8_t",
		U16				=> "uint16_t",
		U32				=> "uint32_t",
		U64				=> "uint64_t",
		U8				=> "uint8_t",
		Variable		=> "SERIALIZABLE_STRING",
	);
	%packet_freq_table = (
		Low =>		"0x0001",
		Medium =>	"0x0002",
		High =>	"0x0003",
	);
	# generated file's output_dir
	$output_dir = "$data_dir";
	# packet ID definition file
	$SecondlifePacketCommonHeaderFile = "/export/workspace/Jinsei/include/SecondlifePacketCommon.h";
};

sub generate {
	my $packet = shift;
	my $option = shift;
	my $class_name = $packet->{name};
	my $packet_freq = $packet->{freq};
	$packet_freq = "Low" if ($packet_freq eq "Fixed");
	my $packet_id = $packet->{id};
	if ($packet_id =~ /^0x/) {
		print "WARN $class_name $packet_id\n";
		$packet_id = hex(substr($packet_id, 6, 4));
	}
	my $packet_reliable = $packet->{reliable};
	print "generating $class_name $packet_freq $packet_id\n";
	# generate header
	{
		# generate block list
		my $block_list = $packet->{block_list};
		my $block_definition = "";
		my $class_member_list = "";
		foreach my $block (@$block_list) {
			$block_definition .= &_generate_block($block);
			$block_definition .= "\n";
			$class_member_list .= "SERIALIZABLE_CLASS(" . $class_name . "_" . $block->{name} . ", " . $block->{name} . ") \\\n";
		}
		my $text = $packet_template;
		$text =~ s/{\$BLOCK_DEFINITION}/$block_definition/g;
		$text =~ s/{\$CLASS_NAME}/$class_name/g;
		$text =~ s/{\$UPPER_CLASS_NAME}/uc($class_name)/eg;
		$text =~ s/{\$CLASS_MEMBER_LIST}/$class_member_list/g;
		my $file_name = $output_dir . "/" . $class_name . "Packet" . ".h";
		open(FILE, ">$file_name") || die "can not write $file_name";
		print FILE $text . "\n";
		close(FILE);
	}
	# generate impl
	{
		my $text = $impl_template;
		$text =~ s/{\$CLASS_NAME}/$class_name/g;
		$text =~ s/{\$UPPER_CLASS_NAME}/uc($class_name)/eg;
		$text =~ s/{\$PACKET_FREQ}/uc($packet_freq)/eg;
		$text =~ s/{\$PACKET_RELIABLE}/$packet_reliable/eg;
		my $file_name = $output_dir . "/" . $class_name . "Packet" . ".cpp";
		open(FILE, ">$file_name") || die "can not write $file_name";
		print FILE $text . "\n";
		close(FILE);
	}
	# add Id to "SecondlifePakcetCommon"
	my $target_line = "// {\$" . uc($packet_freq) . "_PACKET_TAIL} // do not delete this line !";
	my $packet_id_define = uc($class_name) . " = " . $packet_freq_table{$packet_freq} . sprintf("%04x", $packet_id) . ",\n";
	my $error = 0;
	open(FILE, $SecondlifePacketCommonHeaderFile) || die "can not open $SecondlifePacketCommonHeaderFile";
	my @lines = ();
	while (<FILE>) {
		if ($_ =~ /$packet_id_define/) {
			print "WARN !! existed $packet_id_define skip header auto-edit ...\n";
			$error = 1;
			last;
		}
		my $line = $_;
		$_ =~ s/^\s+//g;
		$_ =~ s/\s+$//g;
		if ($_ eq $target_line) {
			push @lines, "\t\t" . $packet_id_define;
		}
		push @lines, $line;
	}
	close(FILE);
	if ($error) {
		return; # TODO: skip CommonHeaderFile editing
	}
	if ($option->{test}) {
		print @lines;
	} else {
		open(FILE, ">" . $SecondlifePacketCommonHeaderFile) || die "can not write $SecondlifePacketCommonHeaderFile";
		print FILE @lines;
		close(FILE);
	}
}

sub _generate_block {
	my $block = shift;
	my $block_name = $block->{name};
	my $block_number = $block->{number};
	my $block_member_list = "";
	foreach (@{$block->{members}}) {
		my ($name, $type) = split(/\s+/, $_);
		if ($data_type_table{$type} =~ /^SERIALIZABLE/) {
			$block_member_list .= $data_type_table{$type} . "(" . $name . ")" . "\t\\\n";
		} else {
			$block_member_list .= "SERIALIZABLE_INT(" . $data_type_table{$type} . ", " . $name . ")" . "\t\\\n";
		}
	}
	my $text = $block_template;
	$text =~ s/\{\$BLOCK_NAME\}/$block_name/g;
	$text =~ s/\{\$BLOCK_MEMBER_LIST\}/$block_member_list/g;
	return $text;
}

1;
