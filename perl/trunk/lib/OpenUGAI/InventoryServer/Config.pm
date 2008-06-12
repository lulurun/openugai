package OpenUGAI::InventoryServer::Config;

use strict;

our %SYS_SQL = (
	save_inventory_folder =>
		"REPLACE INTO inventoryfolders VALUES (?,?,?,?,?,?)",
	save_inventory_item =>
		"REPLACE INTO inventoryitems VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
	get_root_folder =>
		"SELECT * FROM inventoryfolders WHERE parentFolderID=? AND agentId=?",
	get_children_folders =>
		"SELECT * FROM inventoryfolders WHERE parentFolderID=?",
	get_user_inventory_folders =>
		"SELECT * FROM inventoryfolders WHERE agentID=?",
	get_user_inventory_items =>
		"SELECT * FROM inventoryitems WHERE avatarID=?",
	delete_inventory_item =>
		"DELETE FROM inventoryitems WHERE inventoryID=?",
	move_inventory_folder =>
		"UPDATE inventoryfolders SET parentFolderID=? WHERE folderID=?",
);


our @INVENTORYFOLDERS_COLUMNS = (
				 "folderID",
				 "agentID",
				 "parentFolderID",
				 "folderName",
				 "type",
				 "version",
				 );

our @INVENTORYITEMS_COLUMNS = (
			       "inventoryID",
			       "assetID",
			       "assetType",
			       "parentFolderID",
			       "avatarID",
			       "inventoryName",
			       "inventoryDescription",
			       "inventoryNextPermissions",
			       "inventoryCurrentPermissions",
			       "invType",
			       "creatorID",
			       "inventoryBasePermissions",
			       "inventoryEveryOnePermissions",
			       "salePrice",
			       "saleType",
			       "creationDate",
			       "groupID",
			       "groupOwned",
			       "flags",
);

1;
