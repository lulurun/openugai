package OpenUGAI::AssetServer::Config;

use strict;

our %SYS_SQL = (
	select_asset_by_uuid =>
		"SELECT * FROM assets WHERE id=?",
	insert_asset =>
		"REPLACE INTO assets VALUES (?,?,?,?,?,?,?)"
);


our @ASSETS_COLUMNS = (
	"name",
	"description",
	"assetType",
	"local",
	"temporary",
	"data",
	"id",
);

1;
