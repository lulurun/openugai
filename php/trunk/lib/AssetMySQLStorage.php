<?php

Class AssetMySQLStorage extends MySQLStorageBase {

	public function __construct($host, $user, $pass, $db) {
		parent::__construct($host, $user, $pass, $db);
	}

	const SELECT_ASSET = "select * from assets where id=?";
	const INSERT_ASSET = "insert into assets values(?,?,?,?,?,?,?,?,?)";
	const DELETE_ASSET = "delete from assets where id=?";

	public function fetch(/* uuid */ $asset_id) {
		$result = $this->db_conn->query(self::SELECT_ASSET, array($asset_id), true);
		if (is_array($result) && count($result) == 1) {
			return new Asset($result[0]);
		}
		return null;
	}

	public function save(Asset $asset) {
		$result = $this->db_conn->query(
		self::INSERT_ASSET,
		array( $asset->name, $asset->description, $asset->assetType,
		$asset->local, $asset->temporary, $asset->data, $asset->id,
		$asset->create_time, $asset->access_time)
		);
		if ($result == 1) {
			return true;
		} else {
			return false;
		}
	}

	public function delete(/* uuid */ $asset_id) {
		$result = $this->db_conn->query(self::DELETE_ASSET, array($asset_id));
		if ($result == 1) {
			return true;
		} else {
			return false;
		}
	}
}

?>
