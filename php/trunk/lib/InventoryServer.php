<?php

require_once "../lib/Inventory.php";
require_once "../lib/InventoryXMLSerializer.php";
require_once "../lib/InventoryMySQLStorage.php";

// TODO @@@ too bad interface, stop until ...
Class InventoryServer extends RestServerBase {

	public function init() {
		$this->registerHander("POST", "/^\/GetInventory/", NotImplementedHandler::GetInstance());
		$this->registerHander("POST", "/^\/CreateInventory/", NotImplementedHandler::GetInstance());
		$this->registerHander("POST", "/^\/NewFolder/", NotImplementedHandler::GetInstance());
		$this->registerHander("POST", "/^\/MoveFolder/", NotImplementedHandler::GetInstance());
		$this->registerHander("POST", "/^\/NewItem/", NotImplementedHandler::GetInstance());
		$this->registerHander("POST", "/^\/DeleteItem/", NotImplementedHandler::GetInstance());
		$this->registerHander("POST", "/^\/RootFolders/", NotImplementedHandler::GetInstance());
		$this->registerHander("POST", "/^\/UpdateFolder/", NotImplementedHandler::GetInstance());
		$this->registerHander("POST", "/^\/PurgeFolder/", NotImplementedHandler::GetInstance());
	}

}

Class GetInventoryHandler extends RestHandlerBase {

	// waitting
	public function handle($arg_list) {
		if (count($arg_list) == 1) {
			$asset = $this->storage->fetch($arg_list[1]);
			if (isset($asset)) {
				header("Content-type: text/xml");
				echo(AssetXMLSerializer::serialize($asset));
			} else {
				header("HTTP/1.1 404 Asset Not Found");
			}
		} else {
			header("HTTP/1.1 400 Bad Request");
		}
	}

}

?>
