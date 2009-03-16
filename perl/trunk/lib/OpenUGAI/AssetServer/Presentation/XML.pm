package OpenUGAI::AssetServer::Presentation::XML;

use MIME::Base64;
use XML::Simple;

sub serialize {
    my ($this, $asset) = @_;
    return "" if !$asset;
    my $asset_data = &MIME::Base64::encode_base64($asset->{data});
    return << "ASSET_XML";
<AssetBase>
    <Data>$asset_data</Data>
    <FullID>
        <Guid>$asset->{id}</Guid>
    </FullID>
    <Type>$asset->{assetType}</Type>
    <Name>$asset->{name}</Name>
    <Description>$asset->{description}</Description>
    <Local>$asset->{local}</Local>
    <Temporary>$asset->{temporary}</Temporary>
</AssetBase>
ASSET_XML
}

sub deserialize {
    my ($this, $xml) = @_;
    my $xs = new XML::Simple();
    my $obj = $xs->XMLin($xml);
    my %asset = (
	"id" => $obj->{FullID}->{Guid},
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

