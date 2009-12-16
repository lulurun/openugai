<?php

static $document_root = ".";
if (isset($_SERVER["DOCUMENT_ROOT"])) {
	$document_root = $_SERVER["DOCUMENT_ROOT"];
}

function __autoload($class_name)
{
	global  $document_root;
	require_once($document_root .  "../lib/$class_name.php");
}

?>
