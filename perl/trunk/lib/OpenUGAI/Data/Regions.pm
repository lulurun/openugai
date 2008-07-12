package OpenUGAI::Data::Regions;

use strict;
use OpenUGAI::DBData;
use OpenUGAI::Utility;

our %SQL = (
    select_region_by_uuid =>
    "SELECT * FROM regions WHERE uuid=?",
    select_region_by_handle =>
    "SELECT * FROM regions WHERE regionHandle=?",
    select_region_list =>
    "SELECT * FROM regions WHERE locX>=? AND locX<? AND locY>=? AND locY<?",
    insert_region =>
    "INSERT INTO regions VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
    update_region_by_handle =>
    "UPDATE regions set uuid=?,regionHandle=?,regionName=?,regionRecvKey=?,regionSendKey=?,
regionSecret=?,regionDataURI=?,serverIP=?,serverPort=?,serverURI=?,locX=?,locY=?,locZ=?,
eastOverrideHandle=?,westOverrideHandle=?,southOverrideHandle=?,northOverrideHandle=?,
regionAssetURI=?,regionAssetRecvKey=?,regionAssetSendKey=?,regionUserURI=?,regionUserRecvKey=?,
regionUserSendKey=?,regionMapTexture=?,serverHttpPort=?,serverRemotingPort=?,owner_uuid=?,
originUUID=? where regionHandle=?",
    delete_all_regions =>
    "delete from regions",
    delete_region_by_uuid =>
    "delete from regions where uuid=?",
    );


our @REGIONS_COLUMNS = (
    "uuid",
    "regionHandle",
    "regionName",
    "regionRecvKey",
    "regionSendKey",
    "regionSecret",
    "regionDataURI",
    "serverIP",
    "serverPort",
    "serverURI",
    "locX",
    "locY",
    "locZ",
    "eastOverrideHandle",
    "westOverrideHandle",
    "southOverrideHandle",
    "northOverrideHandle",
    "regionAssetURI",
    "regionAssetRecvKey",
    "regionAssetSendKey",
    "regionUserURI",
    "regionUserRecvKey",
    "regionUserSendKey",
    "regionMapTexture",
    "serverHttpPort",
    "serverRemotingPort",
    "owner_uuid",
    "originUUID",
    );

sub addRegion {
    my $region_data = shift;
    my @region_args;
    foreach(@REGIONS_COLUMNS) {
	push @region_args, $region_data->{$_};
    }
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{insert_region}, \@region_args);
    return $res;
}

sub updateRegionByHandle {
    my $region_data = shift;
    my @region_args;
    foreach(@REGIONS_COLUMNS) {
	push @region_args, $region_data->{$_};
    }
    push(@region_args, $region_data->{"regionHandle"});
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{update_region_by_handle}, \@region_args);
    return $res;
}

sub getRegionByUUID {
    my $uuid = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{select_region_by_uuid}, $uuid);
    my $count = @$res;
    if ($count > 0) {
	return $res->[0];
    }
    return undef;
}

sub getRegionByHandle {
    my $handle = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{select_region_by_handle}, $handle);
    my $count = @$res;
    if ($count > 0) {
	return $res->[0];
    }
    return undef;
}

sub getRegionList {
    my ($xmin, $ymin, $xmax, $ymax) = @_;
    my @args = ($xmin, $ymin, $xmax, $ymax);
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{select_region_list}, \@args );
    my $count = @$res;
    if ($count > 0) {
	return $res;
    }
    return undef;
}

sub deleteAllRegions {
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{delete_all_regions});
    return $res;
}

sub deleteRegionByUUID {
    my $uuid = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{delete_region_by_uuid}, $uuid);
    return $res;
}

1;

