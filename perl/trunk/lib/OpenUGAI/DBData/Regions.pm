package OpenUGAI::DBData::Regions;

use strict;

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
    my ($conn, $region_data) = @_;
    my @region_args;
    foreach(@REGIONS_COLUMNS) {
	push @region_args, $region_data->{$_};
    }
    return $conn->query($SQL{insert_region}, \@region_args);
}

sub updateRegionByHandle {
    my $conn = shift;
    my $region_data = shift;
    my @region_args;
    foreach(@REGIONS_COLUMNS) {
	push @region_args, $region_data->{$_};
    }
    push(@region_args, $region_data->{"regionHandle"});
    my $res = $conn->query($SQL{update_region_by_handle}, \@region_args);
    return $res;
}

sub getRegionByUUID {
    my $conn = shift;
    my $res = $conn->query($SQL{select_region_by_uuid}, \@_);
    my $count = @$res;
    if ($count > 0) {
	return $res->[0];
    }
    return undef;
}

sub getRegionByHandle {
    my $conn = shift;
    my $res = $conn->query($SQL{select_region_by_handle}, \@_);
    my $count = @$res;
    if ($count > 0) {
	return $res->[0];
    }
    return undef;
}

sub getRegionList {
    my $conn = shift;
    my $res = $conn->query($SQL{select_region_list}, \@_ );
    my $count = @$res;
    if ($count > 0) {
	return $res;
    }
    return undef;
}

sub deleteAllRegions {
    my $conn = shift;
    return $conn->($SQL{delete_all_regions});
}

sub deleteRegionByUUID {
    my $conn = shift;
    my $res = $conn->query($SQL{delete_region_by_uuid}, \@_);
    return $res;
}

1;

