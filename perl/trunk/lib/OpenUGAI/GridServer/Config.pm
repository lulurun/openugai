package OpenUGAI::GridServer::Config;

use strict;

our %SYS_SQL = (
	select_region_by_uuid =>
	"SELECT * FROM regions WHERE uuid=?",
	select_region_by_handle =>
	"SELECT * FROM regions WHERE regionHandle=?",
	select_region_list =>
	"SELECT * FROM regions WHERE locX>=? AND locX<? AND locY>=? AND locY<?",
	select_region_list2 =>
	"SELECT * FROM regions WHERE locX>=? AND locX<? AND locY>=? AND locY<?",
	insert_region =>
	"INSERT INTO regions VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
	update_region_by_handle =>
	"UPDATE regions set uuid=?,regionHandle=?,regionName=?,regionRecvKey=?,regionSendKey=?,
	regionSecret=?,regionDataURI=?,serverIP=?,serverPort=?,serverURI=?,locX=?,locY=?,locZ=?,
	eastOverrideHandle=?,westOverrideHandle=?,southOverrideHandle=?,northOverrideHandle=?,
	regionAssetURI=?,regionAssetRecvKey=?,regionAssetSendKey=?,regionUserURI=?,regionUserRecvKey=?,
	regionUserSendKey=?,regionMapTexture=?,serverHttpPort=?,serverRemotingPort=?,owner_uuid=?,originUUID=? where regionHandle=?",
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

1;
