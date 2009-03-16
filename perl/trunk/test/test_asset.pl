#!/usr/bin/perl

use strict;
use OpenUGAI::AssetServer;

my $script = "test_asset.pl";
my $sample_asset_xml =<< "ASSET_XML";
<AssetBase>
    <Data>aabbcc</Data>
    <FullID>
        <Guid>12345678-1234-1234-1234-1234567890ab</Guid>
    </FullID>
    <Type>70</Type>
    <Name>test asset</Name>
    <Description>this is a test</Description>
    <Local>0</Local>
    <Temporary>0</Temporary>
</AssetBase>
ASSET_XML

# set ENV{REQUEST_URI}
$ENV{PATH_INFO} = $ARGV[0] || "no request_uri";
$ENV{REQUEST_METHOD} = $ARGV[1];
my $postdata = undef;
if ($ENV{REQUEST_METHOD} eq "POST") {
    $postdata = "POSTDATA=" . ($ARGV[2] eq "default" ? $sample_asset_xml : $ARGV[2]);
}

my $server = new OpenUGAI::AssetServer();
$server->init();
$server->run($postdata);

