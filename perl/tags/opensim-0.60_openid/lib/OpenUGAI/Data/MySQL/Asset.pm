package OpenUGAI::Data::MySQL::Asset;

use strict;
use MIME::Base64;
use XML::Simple;
use OpenUGAI::Data::MySQL;
use OpenUGAI::Global;
use OpenUGAI::Util;

our %SQL = (
	    select_asset_by_uuid =>
	    "SELECT * FROM assets WHERE id=?",
	    insert_asset =>
	    "INSERT INTO assets VALUES (?,?,?,?,?,?,?,?,?)",
	    delete_asset =>
	    "DELETE FROM assets WHERE id=?",
	    );

our @ASSETS_COLUMNS = (
    "name",
    "description",
    "assetType",
    "local",
    "temporary",
    "data",
    "id",
    "create_time",
    "access_time",
    );

sub new {
    my $this = shift;
    # Do nothing here
    # MySql Connection is managed by Apache::DBI
    return bless {};
}

sub getAsset {
    my ($this, $uuid) = @_;
    my $result = undef;
    $result = &OpenUGAI::Data::MySQL::SimpleQuery( $SQL{select_asset_by_uuid}, [$uuid] );
    if ($result) {
	my $count = @$result;
	if ($count > 0) {
	    my $xml = &_asset_to_xml($result->[0]);
	    return $xml;
	}
    }
    Carp::croak("can not find asset $uuid");
    return ""; # TODO: failed xml
}

sub saveAsset {
    my ($this, $asset_xml) = @_;
    my $asset = &_xml_to_asset($asset_xml);
    my @asset_args;
    foreach(@ASSETS_COLUMNS) {
	push @asset_args, $asset->{$_};
    }
    my $result = undef;
    $result = &OpenUGAI::Data::MySQL::SimpleQuery( $SQL{select_asset_by_uuid}, \@asset_args);
    return $result;
}

sub delelteAsset {
    my ($this, $uuid) = @_;
    my $result = undef;
    $result = &OpenUGAI::Data::MySQL::SimpleQuery( $SQL{delete_asset}, [$uuid] );
    return $result;
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

sub _xml_to_asset {
    my $xml = shift;
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

