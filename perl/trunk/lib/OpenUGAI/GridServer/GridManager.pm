package OpenUGAI::GridServer::GridManager;

use strict;
use Carp;
use OpenUGAI::DBData;
use OpenUGAI::GridServer::Config;

sub addRegion {
    my $region_data = shift;
    my $result = &OpenUGAI::DBData::getSimpleResult($OpenUGAI::GridServer::Config::SYS_SQL{insert_region},
		$region_data->{uuid},
		$region_data->{regionHandle},
		$region_data->{regionName},
		$region_data->{regionRecvKey},
		$region_data->{regionSendKey},
		$region_data->{regionSecret},
		$region_data->{regionDataURI},
		$region_data->{serverIP},
		$region_data->{serverPort},
		$region_data->{serverURI},
		$region_data->{locX},
		$region_data->{locY},
		$region_data->{locZ},
		$region_data->{eastOverrideHandle},
		$region_data->{westOverrideHandle},
		$region_data->{southOverrideHandle},
		$region_data->{northOverrideHandle},
		$region_data->{regionAssetURI},
		$region_data->{regionAssetRecvKey},
		$region_data->{regionAssetSendKey},
		$region_data->{regionUserURI},
		$region_data->{regionUserRecvKey},
		$region_data->{regionUserSendKey},
		$region_data->{regionMapTexture},
		$region_data->{serverHttpPort},
		$region_data->{serverRemotingPort},
		$region_data->{owner_uuid},
		$region_data->{originUUID},
    );
}

sub updateRegionByHandle {
    my $region_data = shift;
    my $result = &OpenUGAI::DBData::getSimpleResult($OpenUGAI::GridServer::Config::SYS_SQL{update_region_by_handle},
		$region_data->{uuid},
		$region_data->{regionHandle},
		$region_data->{regionName},
		$region_data->{regionRecvKey},
		$region_data->{regionSendKey},
		$region_data->{regionSecret},
		$region_data->{regionDataURI},
		$region_data->{serverIP},
		$region_data->{serverPort},
		$region_data->{serverURI},
		$region_data->{locX},
		$region_data->{locY},
		$region_data->{locZ},
		$region_data->{eastOverrideHandle},
		$region_data->{westOverrideHandle},
		$region_data->{southOverrideHandle},
		$region_data->{northOverrideHandle},
		$region_data->{regionAssetURI},
		$region_data->{regionAssetRecvKey},
		$region_data->{regionAssetSendKey},
		$region_data->{regionUserURI},
		$region_data->{regionUserRecvKey},
		$region_data->{regionUserSendKey},
		$region_data->{regionMapTexture},
		$region_data->{serverHttpPort},
		$region_data->{serverRemotingPort},
		$region_data->{owner_uuid},
		$region_data->{originUUID},
		$region_data->{regionHandle},
    );
}

sub getRegionByUUID {
    my $uuid = shift;
    my $result = &OpenUGAI::DBData::getSimpleResult($OpenUGAI::GridServer::Config::SYS_SQL{select_region_by_uuid}, $uuid);
    my $count = @$result;
    if ($count > 0) {
		return $result->[0];
    }
    return undef;
}

sub getRegionByHandle {
    my $handle = shift;
    my $result = &OpenUGAI::DBData::getSimpleResult($OpenUGAI::GridServer::Config::SYS_SQL{select_region_by_handle}, $handle);
    my $count = @$result;
    if ($count > 0) {
	return $result->[0];
    }
    return undef;
}

sub getRegionList {
    my ($xmin, $ymin, $xmax, $ymax) = @_;
    my $result = &OpenUGAI::DBData::getSimpleResult($OpenUGAI::GridServer::Config::SYS_SQL{select_region_list}, $xmin, $xmax, $ymin, $ymax);
    my $count = @$result;
    if ($count > 0) {
		return $result;
    }
	return ();
}

sub getRegionList2 {
    my ($xmin, $ymin, $xmax, $ymax) = @_;
    my $result = &OpenUGAI::DBData::getSimpleResult($OpenUGAI::GridServer::Config::SYS_SQL{select_region_list2}, $xmin, $xmax, $ymin, $ymax);
    my $count = @$result;
    if ($count > 0) {
	return $result;
    }
    Carp::croak("can not find region");
}

sub deleteRegions {
    my $result = &OpenUGAI::DBData::getSimpleResult($OpenUGAI::GridServer::Config::SYS_SQL{delete_all_regions});
    my $count = @$result;
    if ($count > 0) {
		return $result;
    }
    Carp::croak("failed to delete regions");
}

sub deleteRegionByUUID {
	my $uuid = shift;
    my $result = &OpenUGAI::DBData::getSimpleResult($OpenUGAI::GridServer::Config::SYS_SQL{delete_region_by_uuid}, $uuid);
}

1;
