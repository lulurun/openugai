<?php

Class InventoryFolder extends DataObjectBase {

	public function __construct($inventory_folder_row = null) {
		$this->arr = array(
			"folderName" => "",
			"type" => 0,
			"version" => 0,
			"folderID" => "",
			"agentID" => "",
			"parentFolderID" => "",
		);
		parent::__construct($inventory_folder_row);
	}

}

Class InventoryItem extends DataObjectBase {

	public function __construct($inventory_item_row = null) {
		$this->arr = array(
			"assetID" => "",
			"assetType" => 0,
			"inventoryName" => "",
			"inventoryDescription" => "",
			"inventoryNextPermissions" => 0,
			"inventoryCurrentPermissions" => 0,
			"invType" => 0,
			"creatorID" => "",
			"inventoryBasePermissions" => 0,
			"inventoryEveryOnePermissions" => 0,
			"salePrice" => 0,
			"saleType" => 0,
			"creationDate" => 0,
			"groupID" => "",
			"groupOwned" => 0,
			"flags" => 0,
			"inventoryID" => "",
			"avatarID" => "",
			"parentFolderID" => "",
			"inventoryGroupPermissions" => 0,
		);
		parent::__construct($inventory_folder_row);
	}

}

?>
