<?php
class DBConnection {

	private $connection;

	public function __construct($host, $user, $pass, $db) {
		$this->connection = new mysqli($host, $user, $pass, $db);
		if (mysqli_connect_errno()) {
			throw new Exception("Connect failed: " . mysqli_connect_error());
		}
	}

	public function __destruct() {
		$this->connection->close();
	}

	public function query(/*string */ $sql, /* array */ $args, /* bool */ $store_result = false) {
		if ($stmt = $this->connection->prepare($sql)) {
			array_unshift($args, self::get_prepared_type_string($args));
			call_user_func_array(array($stmt, 'bind_param'), $args);
			if ($stmt->execute()) {
				if (preg_match('/^select/i', $sql)) {
					if ($store_result) {
						$stmt->store_result();
					}
					$result = self::get_result($stmt);
					return $result;
				} else {
					return $stmt->affected_rows;
				}
			} else {
				throw new Exception("Can not execute Statement: " . $sql);
			}
			$stmt->close();
		} else {
			throw new Exception("Can not prepare Statement: " . $this->connection->error);
		}
		return null;
	}

	// private utility functions
	private static function get_result($stmt)
	{
		$result = array();		 
		$metadata = $stmt->result_metadata();
		$fields = $metadata->fetch_fields();

		for (;;) {
			$pointers = array();
			$row = new stdClass();

			foreach ($fields as $field) {
				$fieldname = $field->name;
				$pointers[] = &$row->$fieldname;
			}
			call_user_func_array(array($stmt, 'bind_result'), $pointers);
			 
			if (!$stmt->fetch()) break;
			$result[] = $row;
		}

		$metadata->free();
		return $result;
	}

	private static function get_prepared_type_string(&$saParams) {
		$sRetval = '';
		if (!is_array($saParams) || !count($saParams)) {
			return $sRetval;
		}

		foreach ($saParams as $Param) {
			if (is_int($Param)) {
				$sRetval .= 'i';
			} else if (is_double($Param)) {
				$sRetval .= 'd';
			} else if (is_string($Param)) {
				$sRetval .= 's';
			}
		}
		return $sRetval;
	}
}

?>