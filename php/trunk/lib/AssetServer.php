<?php

Class AssetServer extends RestServerBase {

	public function init() {
		$this->registerHander("GET", "/^\/assets\/([0-9a-zA-Z\-]{36})/", new FetchAssetHandler($this->storage));
		$this->registerHander("POST", "/^\/assets/", NotImplementedHandler::GetInstance());
		$this->registerHander("DELETE", "/^\asets\/[0-9a-zA-Z\-]{36}/", NotImplementedHandler::GetInstance());
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
