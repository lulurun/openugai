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
		if (isset($asset_row)) {
			$this->name = $asset_row->name;
			$this->description = $asset_row->description;
			$this->assetType = $asset_row->assetType;
			$this->local = $asset_row->local;
			$this->temporary = $asset_row->temporary;
			$this->data = $asset_row->data;
			$this->id = $asset_row->id;
			$this->create_time = $asset_row->create_time;
			$this->access_time = $asset_row->access_time;
		}
	}

}

?>
