<?php

class MySQLStorageBase {

	protected $db_conn;
	
	protected function __construct($host, $user, $pass, $db) {
		$this->db_conn = new DBConnection($host, $user, $pass, $db);
	}

}

?>
