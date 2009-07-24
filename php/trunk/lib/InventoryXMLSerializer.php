<?php

Class InventoryFolderXMLSerializer {

	public static function serialize($folder) {
		if (!isset($folder)) {
			return "";
		}
		if (is_array($folder)) {
			$xml = "";
			foreach($folder as $obj) {
				$xml .= InventoryFolderXMLSerializer::serialize($obj);
			}
			return "<ArrayOfInventoryFolderBase>" . $xml . "</ArrayOfInventoryFolderBase>";
		} else {
			return <<< FOLDER_XML
<InventoryFolderBase>
    <Name>$folder->folderName</Name>
    <Owner>
        <Guid>$folder->agentID</Guid>
    </Owner>
    <ParentID>
        <Guid>$folder->parentFolderID</Guid>
    </ParentID>
    <ID>
        <Guid>$folder->folderID</Guid>
    </ID>
    <Type>$folder->type</Type>
    <Version>$folder->version</Name>
</InventoryFolderBase>
FOLDER_XML;
		}
	}

	public static function deserialize(/* string */ $xmlstr) {
		$xmlobj = new SimpleXMLElement($xmlstr);
		$asset = new Asset();
		$asset->name = $xmlobj->Name;
		$asset->description = $xmlobj->Description;
		$asset->assetType = $xmlobj->Type;
		$asset->local = $xmlobj->Local;
		$asset->temporary = $xmlobj->Temporary;
		$asset->data = base64_decode($xmlobj->Data);
		$asset->id = $xmlobj->FullID->Guid;
		//$asset->create_time = $xmlobj->Data;
		//$asset->access_time = $xmlobj->Data;
		return $asset;
	}

}

Class InventoryItemXMLSerializer {

	public static function serialize(Asset $asset) {
		if (!isset($asset)) {
			return "";
		}
		$asset_data = base64_encode($asset->data);
		return <<< ASSET_XML
<AssetBase>
    <Data>$asset_data</Data>
    <FullID>
        <Guid>$asset->id</Guid>
    </FullID>
    <Type>$asset->assetType</Type>
    <Name>$asset->name</Name>
    <Description>$asset->description</Description>
    <Local>$asset->local</Local>
    <Temporary>$asset->temporary</Temporary>
</AssetBase>
ASSET_XML;
	}

	public static function deserialize(/* string */ $xmlstr) {
		$xmlobj = new SimpleXMLElement($xmlstr);
		$asset = new Asset();
		$asset->name = $xmlobj->Name;
		$asset->description = $xmlobj->Description;
		$asset->assetType = $xmlobj->Type;
		$asset->local = $xmlobj->Local;
		$asset->temporary = $xmlobj->Temporary;
		$asset->data = base64_decode($xmlobj->Data);
		$asset->id = $xmlobj->FullID->Guid;
		//$asset->create_time = $xmlobj->Data;
		//$asset->access_time = $xmlobj->Data;
		return $asset;
	}

}

?>

