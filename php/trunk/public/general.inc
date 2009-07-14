<?php

static $document_root = "/srv/www/htdocs/php/public";

/*
if (isset($_SERVER["DOCUMENT_ROOT"])) {
	$document_root = $_SERVER["DOCUMENT_ROOT"];
}
*/

function __autoload($class_name)
{
	global  $document_root;
	require_once($document_root .  "/../lib/$class_name.php");
}

?>
