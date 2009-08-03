<?php

Class GridMySQLStorage extends MySQLStorageBase {

	public function __construct($host, $user, $pass, $db) {
		parent::__construct($host, $user, $pass, $db);
	}

	const SELECT_REGION_BY_ID = "SELECT * FROM regions WHERE uuid=?";
	const SELECT_REGION_BY_HANDLE = "SELECT * FROM regions WHERE regionHandle=?";
	const SELECT_REGION_BLOCK = "SELECT * FROM regions WHERE locX>=? AND locX<? AND locY>=? AND locY<?";
	const INSERT_REGION = "INSERT INTO regions VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
	const UPDATE_REGION_BY_HANDLE =
    "UPDATE regions SET uuid=?,regionHandle=?,regionName=?,regionRecvKey=?,regionSendKey=?,
regionSecret=?,regionDataURI=?,serverIP=?,serverPort=?,serverURI=?,locX=?,locY=?,locZ=?,
eastOverrideHandle=?,westOverrideHandle=?,southOverrideHandle=?,northOverrideHandle=?,
regionAssetURI=?,regionAssetRecvKey=?,regionAssetSendKey=?,regionUserURI=?,regionUserRecvKey=?,
regionUserSendKey=?,regionMapTexture=?,serverHttpPort=?,serverRemotingPort=?,owner_uuid=?,
originUUID=?,access=? WHERE regionHandle=?";
	const DELETE_ALL_REGIONS = "DELETE FROM regions";
	const DELETE_REGION_BY_ID = "DELETE FROM regions WHERE uuid=?";

	public function addRegion(Region $region) {
		$result = $this->db_conn->query(
		self::INSERT_REGION,
		array( $region->uuid, $region->regionHandle, $region->regionName,
		$region->regionRecvKey, $region->regionSendKey, $region->regionSecret,
		$region->regionDataURI, $region->serverIP, $region->serverPort, $region->serverURI,
		$region->locX, $region->locY, $region->locZ, $region->eastOverrideHandle,
		$region->westOverrideHandle, $region->southOverrideHandle,
		$region->northOverrideHandle, $region->regionAssetURI,
		$region->regionAssetRecvKey, $region->regionAssetSendKey,
		$region->regionUserURI, $region->regionUserRecvKey, $region->regionUserSendKey,
		$region->regionMapTexture, $region->serverHttpPort, $region->serverRemotingPort,
		$region->owner_uuid, $region->originUUID, $region->access
		)
		);
		if ($result == 1) {
			return true;
		} else {
			return false;
		}
	}

	public function updateRegionByHandle(Region $region) {
		$result = $this->db_conn->query(
		self::UPDATE_REGION_BY_HANDLE,
		array( $region->uuid, $region->regionHandle, $region->regionName,
		$region->regionRecvKey, $region->regionSendKey, $region->regionSecret,
		$region->regionDataURI, $region->serverIP, $region->serverPort, $region->serverURI,
		$region->locX, $region->locY, $region->locZ, $region->eastOverrideHandle,
		$region->westOverrideHandle, $region->southOverrideHandle,
		$region->northOverrideHandle, $region->regionAssetURI,
		$region->regionAssetRecvKey, $region->regionAssetSendKey,
		$region->regionUserURI, $region->regionUserRecvKey, $region->regionUserSendKey,
		$region->regionMapTexture, $region->serverHttpPort, $region->serverRemotingPort,
		$region->owner_uuid, $region->originUUID, $region->access,
		$region->regionHandle
		)
		);
		if ($result == 1) {
			return true;
		} else {
			return false;
		}
	}

	public function getRegionByUUID( /* string */ $region_uuid) {
		$result = $this->db_conn->query( self::SELECT_REGION_BY_ID, array( $region_uuid ) );
		if (is_array($result) && count($result) == 1) {
			return new Asset($result[0]);
		}
		return null;
	}

	public function getRegionByHandle( /* string */ $region_handle) {
		$result = $this->db_conn->query( self::SELECT_REGION_BY_HANDLE, array( $region_handle ) );
		if (is_array($result) && count($result) == 1) {
			return new Asset($result[0]);
		}
		return null;
	}

	public function getRegionList(/* int */ $xmin, /* int */ $ymin, /* int */ $xmax, /* int */ $ymax) {
		$result = $this->db_conn->query(
		self::SELECT_REGION_BY_HANDLE,
		array( $xmin, $ymin, $xmax, $ymax )
		);
		if (is_array($result) && count($result) > 0) {
			return new Asset($result[0]);
		}
		return null;
	}

	public function deleteAllRegions() {
		$result = $this->db_conn->query( self::DELETE_ALL_REGIONS, array() );
		if ($result == 1) {
			return true;
		} else {
			return false;
		}
	}

	public function deleteRegionByUUID( /* string */ $region_uuid ) {
		$result = $this->db_conn->query( self::DELETE_REGION_BY_ID, array( $region_uuid ) );
		if ($result == 1) {
			return true;
		} else {
			return false;
		}
	}

}

?>
