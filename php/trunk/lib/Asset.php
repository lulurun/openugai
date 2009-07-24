<?php

Class Asset extends DataObjectBase {

	public function __construct($asset_row = null) {
		$this->arr = array(
			"name" => "",
			"description" => "",
			"assetType" => "",
			"local" => 0,
			"temporary" => 0,
			"data" => "",
			"id" => "",
			"create_time" => 0,
			"access_time" => 0,
		);
		parent::__construct($asset_row);
	}

}

?>
