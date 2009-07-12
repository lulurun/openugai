<?php

class Util {

	public static function CreateUUID() {
		return uuid_create ();
	}

	public static function ZeroUUID() {
		return "00000000-0000-0000-0000-000000000000";
	}	

}

?>
