<?php

Class InventoryServer extends RestServerBase {

	public function init() {
		$this->registerHander("POST", "/^\/GetInventory/", new GetInventoryHandler($this->storage));
		$this->registerHander("POST", "/^\/CreateInventory/", new CreateInventoryHandler($this->storage));
		$this->registerHander("POST", "/^\/NewFolder/", new NewFolderHandler($this->storage));
		$this->registerHander("POST", "/^\/MoveFolder/", new MoveFolderHandler($this->storage));
		$this->registerHander("POST", "/^\/NewItem/", new NewItemHandler($this->storage));
		$this->registerHander("POST", "/^\/DeleteItem/", new DeleteItemHandler($this->storage));
		$this->registerHander("POST", "/^\/RootFolders/", new RootFoldersHandler($this->storage));
		$this->registerHander("POST", "/^\/UpdateFolder/", new UpdateFolderHandler($this->storage));
		$this->registerHander("POST", "/^\/PurgeFolder/", new PurgeFolderHandler($this->storage));
	}

}

Class GetInventoryHandler extends RestHandlerBase {
}

Class CreateInventoryHandler extends RestHandlerBase {
}

Class NewFolderHandler extends RestHandlerBase {
}

Class MoveFolderHandler extends RestHandlerBase {
}

Class NewItemHandler extends RestHandlerBase {
}

Class DeleteItemHandler extends RestHandlerBase {
}

Class RootFoldersHandler extends RestHandlerBase {
}

Class UpdateFolderHandler extends RestHandlerBase {
}

Class PurgeFolderHandler extends RestHandlerBase {
}

?>
