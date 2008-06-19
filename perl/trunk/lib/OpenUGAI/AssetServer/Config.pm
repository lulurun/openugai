package OpenUGAI::AssetServer::Config;

use strict;

our %SYS_SQL = (
	select_asset_by_uuid =>
		"SELECT * FROM assets WHERE id=X?",
	insert_asset =>
		"REPLACE INTO assets VALUES (?,?,?,?,?,?,?,?)"
);


our @ASSETS_COLUMNS = (
	"id",
	"name",
	"description",
	"assetType",
	"invType",
	"local",
	"temporary",
	"data",
);

1;
