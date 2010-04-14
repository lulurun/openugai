package OpenUGAI::Data::DynamicGridData;

use strict;
use OpenUGAI::DBData;

our %SQL = (
    select_region_by_uuid =>
    "SELECT * FROM LiveRegions WHERE client_uuid=?",
    insert_region =>
    "REPLACE INTO LiveRegions VALUES (?,?,?,?,?,?)",
    delete_region =>
    "DELETE from LiveRegions WHERE client_uuid=?",
    # contents
    insert_contents =>
    "REPLACE INTO Contents VALUES (?,?,?,?)",
    insert_contents_data =>
    "REPLACE INTO ContentsData VALUES (?,?,?,?)",
    select_contents_with_data =>
    "select * from Contents inner join ContentsData using(contents_uuid)",
    );

our @LIVEREGIONS_COLUMNS =
    (
     "client_uuid",
     "ip_addr",
     "udp_port",
     "api_port",
     "current_contents_uuid",
     "online_avatar",
     );

our @CONTENTS_COLUMNS =
    (
     "contents_uuid",
     "name",
     "description",
     "related_url",
     );

our @CONTENTSDATA_COLUMNS =
    (
     "contents_uuid",
     "data_uuid",
     "size",
     "type",
     );

sub GetContentsList {
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{select_contents_with_data});
    return $res;
}

sub saveContentsData {
    my $contents = shift;
    my @args;
    push @args, $contents->{contents_uuid};
    push @args, $contents->{data_uuid};
    push @args, $contents->{size};
    push @args, $contents->{type};
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{insert_contents_data}, \@args);
    return $res;
}

sub saveContentsInfo {
    my $contents = shift;
    my @args;
    push @args, $contents->{UUID};
    push @args, $contents->{name};
    push @args, $contents->{desc};
    push @args, $contents->{url};
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{insert_contents}, \@args);
    return $res;
}

sub saveRegion {
    my $region = shift;
    my @args;

    push @args, $region->{UUID};
    push @args, $region->{ip};
    push @args, $region->{udp_port};
    push @args, $region->{api_port};
    push @args, "";
    push @args, 0;

    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{insert_region}, \@args);
    return $res;
}

sub deleteRegion {
    my $id = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{delete_region}, $id);
    return $res;
}

sub updateCurrentContents {
}

sub incrementOnlineAvatar {
}

1;

