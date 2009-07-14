<?php

Class AssetServer extends RestServerBase {

	private $storage;
	
	public function __construct(AssetMySQLStorage $storage) {
		parent::__construct();
		$this->storage = $storage;
	}
	
	public function init() {
		$this->registerHander("GET", "/^\/assets\/([0-9a-zA-Z\-]{36})/", new FetchAssetHandler($this->storage));
		$this->registerHander("POST", "/^\/assets/", new StoreAssetHandler($this->storage));
		$this->registerHander("DELETE", "/^\asets\/[0-9a-zA-Z\-]{36}/", new DeleteAssetHandler($this->storage));
	}

}

Class AssetServerHandlerBase {

	protected $storage;
	
	public function __construct(AssetMySQLStorage $storage) {
		$this->storage = $storage;
	}
	
}

Class FetchAssetHandler extends AssetServerHandlerBase Implements RestHandlerBase {

	function handle($arg_list) {
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

Class StoreAssetHandler extends AssetServerHandlerBase Implements RestHandlerBase {

	function handle($arg_list) {
		return "";
	}

}

Class DeleteAssetHandler extends AssetServerHandlerBase Implements RestHandlerBase {

	function handle($arg_list) {
		return "";
	}

}

?>
