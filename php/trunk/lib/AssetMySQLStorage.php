<?php

Class AssetMySQLStorage {

	private $db_conn;

	const SELECT_ASSET = "select * from assets where id=?";
	const INSERT_ASSET = "insert into assets values(?,?,?,?,?,?,?,?,?)";
	const DELETE_ASSET = "delete from assets where id=?";

	public function __construct($host, $user, $pass, $db) {
		$this->db_conn = new DBConnection($host, $user, $pass, $db);
	}

	public function fetch(/* uuid */ $asset_id) {
		$asset_rows = $this->db_conn->query(self::SELECT_ASSET, array($asset_id), true);
		if (is_array($asset_rows) && count($asset_rows) == 1) {
			return new Asset($asset_rows[0]);
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

	public function delete(Asset $asset) {
		$result = $this->db_conn->query(self::DELETE_ASSET, array($asset->id));
		if ($result == 1) {
			return true;
		} else {
			return false;
		}
	}
}

?>
