package OpenUGAI::DynamicGridHandler;

use strict;
use OpenUGAI::Global;
use OpenUGAI::Util;
use OpenUGAI::Data::DynamicGridData;

sub AddRegion {
    my $req_data = shift;
    my ($x, $y) = &_find_available_coord();
    # generate regioninfo
    my $region_info = {
	UUID => OpenUGAI::Util::GenerateUUID(),
	SimName => $req_data->{IP} . ":" . $req_data->{UDP_PORT},
	LocX => hex($x),
	LocY => hex($y),
	ip => $req_data->{IP},
	api_port => $req_data->{API_PORT},
	udp_port => $req_data->{UDP_PORT},
    };
    # save regioninfo

    # TODO @@@ should be like:
    # select * from LiveRegions for update;
    # find_ava_coord
    # insert into LiveRegions

    OpenUGAI::Data::DynamicGridData::saveRegion($region_info);
    my $file = &_get_region_file("", $x, $y);    
    open(FILE, ">$file") || Carp::croak("can not write to $file");
    close(FILE);

    return $region_info;
}

sub DeleteRegion {
    my $req_data = shift;

    # TODO @@@ should be like:
    # delete from LiveRegions where client_id=?;
    OpenUGAI::Data::DynamicGridData::deleteRegion($req_data->{UUID});
    my $file = &_get_region_file("", $req_data->{LocX}, $req_data->{LocY});    
    if (-e $file) {
	unlink($file);
    }
}

sub SaveContentsData {
    my ($cgi, $form_name, $contents_uuid, $type) = @_;
    my $file = $cgi->param($form_name);
    return if (!$file);
    my $fh = $cgi->upload($form_name) or Carp::croak("Invalid file handle returned");
    my $file_uuid = OpenUGAI::Util::GenerateUUID();
    my $file_name = $OpenUGAI::Global::Contents_Dir . "/" . $file_uuid;
    open(OUT, ">$file_name") or Carp::croak("Can't open $file_name");
    binmode OUT;
    my $buffer;
    while (read($fh, $buffer, 1024)) { # Read from $fh insted of $file
	print OUT $buffer;
    }
    close OUT;
    Apache2::ServerRec::warn("file saved: " . $file_name);
    my $file_size = -s $file_name;
    my $req = {
	contents_uuid => $contents_uuid,
	data_uuid => OpenUGAI::Util::GenerateUUID(),
	size => $file_size,
	type => $type,
    };
    &OpenUGAI::Data::DynamicGridData::saveContentsData($req);
}

sub AddContentsInfo {
    my $req = shift;
    &OpenUGAI::Data::DynamicGridData::saveContentsInfo($req);
}

# ############
# Subs
sub _get_region_file {
    my ($ip, $x, $y) = @_;
    return $OpenUGAI::Global::Region_Dir . "/" . $x . "_" . $y;
}

sub _get_coord() {
    my $x = "";
    my $first = int(rand(7));
    $first += 8;
    $x .= sprintf("%x", $first);
    for(1..7) {
	$x .= sprintf("%x", int(rand(16)));
    }
    return $x;
}

sub _find_available_coord() {
    # TODO @@@ infinite loop, danger !, find a better way !!
    while(1) {
	my $x = &_get_coord();
	my $y = &_get_coord();	
	if (!-e &_get_region_file("", $x, $y)) {
	    return ($x, $y);
	}
    }
}

1;

