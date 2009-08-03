<?php

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

?>
