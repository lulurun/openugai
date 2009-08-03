<?php

Class Region extends DataObjectBase {

	public function __construct($region_row = null) {
		$this->arr = array(
			"uuid" => "",
			"regionHandle" => 0,
			"regionName" => "",
			"regionRecvKey" => "",
			"regionSendKey" => "",
			"regionSecret" => "",
			"regionDataURI" => "",
			"serverIP" => "",
			"serverPort" => 0,
			"serverURI" => "",
			"locX" => 0,
			"locY" => 0,
			"locZ" => 0,
			"eastOverrideHandle" => 0,
			"westOverrideHandle" => 0,
			"southOverrideHandle" => 0,
			"northOverrideHandle" => 0,
			"regionAssetURI" => "",
			"regionAssetRecvKey" => "",
			"regionAssetSendKey" => "",
			"regionUserURI" => "",
			"regionUserRecvKey" => "",
			"regionUserSendKey" => "",
			"regionMapTexture" => "",
			"serverHttpPort" => 0,
			"serverRemotingPort" =>0,
			"owner_uuid" => "",
			"originUUID" => "",
			"access" => 0,
		);
		parent::__construct($region_row);
	}

}

?>
