<?php

require_once "../lib/Asset.php";
require_once "../lib/AssetXMLSerialzier.php";
require_once "../lib/AssetMySQLStorage.php";

Class AssetServer extends RestServerBase {

	public function init() {
		$this->registerHander("GET", "/^\/assets\/([0-9a-zA-Z\-]{36})/", new FetchAssetHandler($this->storage));
		$this->registerHander("POST", "/^\/assets/", new SaveAssetHandler($this->storage));
		$this->registerHander("DELETE", "/^\asets\/[0-9a-zA-Z\-]{36}/", new DeleteAssetHandler($this->storage));
	}

}

Class DeleteAssetHandler extends RestHandlerBase {

	public function handle($arg_list) {
		if (count($arg_list) == 1) {
			if ($this->storage->delete($arg_list[0])) {
				// TODO @@@ need a better response
				echo("true");
			} else {
				header("HTTP/1.1 507 Failed to delete asset");
			}
		} else {
			header("HTTP/1.1 400 Bad Request");
		}
	}

}

Class SaveAssetHandler extends RestHandlerBase {

	public function handle($arg_list) {
		if (count($arg_list) == 1) {
			$asset = AssetXMLSerializer::deserialize($arg_list[0]);
			if ($this->storage->save($asset)) {
				// TODO @@@ need a better response
				echo("true");
			} else {
				header("HTTP/1.1 507 Failed to save asset");
			}
		} else {
			header("HTTP/1.1 400 Bad Request");
		}
	}

}

Class FetchAssetHandler extends RestHandlerBase {

	public function handle($arg_list) {
		if (count($arg_list) == 2) {
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

