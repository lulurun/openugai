<?php

Class RestHandlerBase {

	protected $storage;
	
	public function __construct(MySQLStorageBase $storage) {
		$this->storage = $storage;
	}
	
	protected function handle(/* array */ $arg_list) {}

}

Class RestServerBase {
	
	private $handlers = array();
	protected $storage;

	public function __construct(MySQLStorageBase $storage) {
		$this->handlers = array(
			"GET" => array(),
			"POST" => array(),
			"PUT" => array(),
			"DELETE" => array(),
			"HEAD" => array(),
		);
		$this->storage = $storage;
	}	
	
	protected function registerHander(/* string */ $http_method, /* regexp */ $path_pattern, /* function */ $handler){
		if (isset($this->handlers[$http_method])) {
			$this->handlers[$http_method][$path_pattern] = $handler;
		}
	}

	public function run(/* string */ $method = null, /* string */ $path_info = null) {
		if (!isset($method)) $method = $_SERVER['REQUEST_METHOD'];
		$script_name = $_SERVER["SCRIPT_NAME"];
		if (!isset($path_info)) $path_info = str_replace($script_name, "", $_SERVER['REQUEST_URI']);		
		
		$handlers = $this->handlers[$method];
		$found_method = false;
		foreach($handlers as $url_pattern => $handler){
			if (preg_match($url_pattern, $path_info, $matches)) {
				$found_method = true;
				// TODO @@@ try ... catch
				$handler->handle($matches);
			}
		}
		if (!$found_method) {
			header('HTTP/1.1 404 Method Not Found');
		}
	}
}

?>
