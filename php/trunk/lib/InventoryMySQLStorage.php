<?php

Class InventoryMySQLStorage extends MySQLStorageBase {

	public function __construct($host, $user, $pass, $db) {
		parent::__construct($host, $user, $pass, $db);
	}

	/*
	 * Inventory Folders
	 */
	const SAVE_INVENTORY_FOLDER = "REPLACE INTO inventoryfolders VALUES (?,?,?,?,?,?)";
	const GET_ROOT_FOLDER =
    "SELECT * FROM inventoryfolders WHERE parentFolderID='00000000-0000-0000-0000-000000000000' AND agentId=?";
	const GET_CHILDREN_FOLDERS = "SELECT * FROM inventoryfolders WHERE parentFolderID=?";
	const GET_USER_FOLDERS = "SELECT * FROM inventoryfolders WHERE agentID=?";
	const MOVE_FOLDER = "UPDATE inventoryfolders SET parentFolderID=? WHERE folderID=?";
	const DELETE_FOLDER = "DELETE FROM inventoryfolders WHERE folderID=?";

	public function move(/* string */ $parent_folder_id, /* string */ $folder_id ) {
		$result = $this->db_conn->query(
		self::MOVE_FOLDER,
		array( $parent_folder_id, $folder_id )
		);
		if ($result == 1) {
			return true;
		} else {
			return false;
		}
	}

	public function delete(/* string */ $folder_id) {
		$result = $this->db_conn->query(
		self::DELETE_FOLDER,
		array( $folder_id )
		);
		if ($result == 1) {
			return true;
		} else {
			return false;
		}
	}

	public function save(InventoryFolder  $folder) {
		$result = $this->db_conn->query(
		self::SAVE_INVENTORY_FOLDER,
		array( $folder->folderName, $folder->type, $folder->version,
		$folder->folderID, $folder->agentID, $folder->parentFolderID )
		);
		if ($result == 1) {
			return true;
		} else {
			return false;
		}
	}

	public function getChildrenFolders(/* string */ $parent_folder_id) {
		$result = $this->db_conn->query(
		self::GET_CHILDREN_FOLDERS,
		array( $parent_folder_id )
		);
		$inventory_folders = array();
		if ( is_array($result) ) {
			foreach($result as $folder_row) {
				array_push($inventory_folders, new InventoryFolder($folder_row));
			}
		}
		return $inventory_folders;
	}

	public function getUserFolders(/* string */ $user_id) {
		$result = $this->db_conn->query(
		self::GET_USER_FOLDERS,
		array( $user_id )
		);
		$inventory_folders = array();
		if ( is_array($result) ) {
			foreach($result as $folder_row) {
				array_push($inventory_folders, new InventoryFolder($folder_row));
			}
		}
		return $inventory_folders;
	}

	public function getRootFolder(/* string */ $user_id) {
		$result = $this->db_conn->query(
		self::GET_ROOT_FOLDER,
		array( $user_id )
		);
		if ( is_array($result) && count($result) == 1 ) {
			return new InventoryFolder($result[0]);
		}
		return null;
	}


	/*
	 * Inventory Items
	 */
	const SAVE_ITEM = "REPLACE INTO inventoryitems VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
	const DELETE_ITEM = "DELETE FROM inventoryitems WHERE inventoryID=?";
	const GET_USER_ITEMS = "SELECT * FROM inventoryitems WHERE avatarID=?";
	const DELETE_FOLDER_ITEMS = "DELETE FROM inventoryitems WHERE parentFolderID=?";

	public function delete(/* string */ $item_id) {
		$result = $this->db_conn->query(
		self::DELETE_ITEM,
		array( $item_id )
		);
		if ($result == 1) {
			return true;
		} else {
			return false;
		}
	}

	public function save(InventoryItem  $item) {
		$result = $this->db_conn->query(
		self::SAVE_ITEM,
		array( $folder->assetID, $folder->assetType, $folder->inventoryName,
		$folder->inventoryDescription, $folder->inventoryNextPermissions,
		$folder->inventoryCurrentPermissions, $folder->invType, $folder->creatorID,
		$folder->inventoryBasePermissions, $folder->inventoryEveryOnePermissions, $folder->salePrice,
		$folder->saleType, $folder->creationDate, $folder->groupID, $folder->groupOwned,
		$folder->flags, $folder->inventoryID, $folder->avatarID,
		$folder->parentFolderID, $folder->inventoryGroupPermissions )
		);
		if ($result == 1) {
			return true;
		} else {
			return false;
		}
	}


	public function getUserItems(/* string */ $user_id) {
		$result = $this->db_conn->query(
		self::GET_USER_ITEMS,
		array( $user_id )
		);
		$inventory_items = array();
		if ( is_array($result) ) {
			foreach($result as $item_row) {
				array_push($inventory_items, new InventoryItem($item_row));
			}
		}
		return $inventory_items;
	}

	public function deleteFolderItems(/* string */ $folder_id) {
		$result = $this->db_conn->query(
		self::DELETE_FOLDER_ITEMS,
		array( $folder_id )
		);
		return true;
	}

}

?>
