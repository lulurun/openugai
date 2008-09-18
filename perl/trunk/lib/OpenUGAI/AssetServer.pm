package OpenUGAI::AssetServer;

use strict;
use Carp;
use MIME::Base64;
use XML::Simple;
use OpenUGAI::AssetServer::Storage;

our $AssetStorage;
BEGIN {
    eval {
	$AssetStorage = &OpenUGAI::AssetServer::Storage::GetInstance();
    };
    if ($@) {
	$AssetStorage = undef;
	Carp::croak("can not start AssetServer: $@");
    }
}

# !!
# TODO: delete asset
#

sub getAsset {
    my ($asset_id, $param) = @_;
    # get asset
    my $asset = $AssetStorage->getAsset($asset_id);
    # make response
    return &_asset_to_xml($asset);
}

sub saveAsset {
    my $xml = shift;
    my $asset = &_xml_to_asset($xml);
    $AssetStorage->saveAsset($asset);
    return "";
    # TODO: temporary solution of "success!"
    # TODO: message for save failed
}

# ##################
# private functions
sub _asset_to_xml {
    my $asset = shift;
    return "" if !$asset;
    my $asset_data = &MIME::Base64::encode_base64($asset->{data});
    return << "ASSET_XML";
<AssetBase>
    <Data>$asset_data</Data>
    <FullID>
        <UUID>$asset->{id}</UUID>
    </FullID>
    <Type>$asset->{assetType}</Type>
    <Name>$asset->{name}</Name>
    <Description>$asset->{description}</Description>
    <Local>$asset->{local}</Local>
    <Temporary>$asset->{temporary}</Temporary>
</AssetBase>
ASSET_XML
}

sub _xml_to_asset {
    my $xml = shift;
    my $xs = new XML::Simple();
    my $obj = $xs->XMLin($xml);
    my %asset = (
	"id" => $obj->{FullID}->{UUID},
	"name" => $obj->{Name},
	"description" => $obj->{Description},
	"assetType" => $obj->{Type},
	"local" => $obj->{Local},
	"temporary" => $obj->{Temporary},
	"data" => &MIME::Base64::decode_base64($obj->{Data}),
	);
    return \%asset;
}

1;

