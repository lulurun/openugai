package OpenUGAI::AssetServer::Storage::MySQL;

use strict;
use MIME::Base64;
use XML::Simple;
use DBHandler;
use OpenUGAI::Global;
use OpenUGAI::Util;

our %SQL = (
    select_asset_by_uuid =>
    "SELECT * FROM assets WHERE id=?",
    insert_asset =>
    "REPLACE INTO assets VALUES (?,?,?,?,?,?,?)"
    );

our @ASSETS_COLUMNS = (
    "name",
    "description",
    "assetType",
    "local",
    "temporary",
    "data",
    "id",
    );

sub new {
    my $this = shift;
    my %fields = (
	Connection => &DBHandler::getConnection($OpenUGAI::Global::DSN,
						$OpenUGAI::Global::DBUSER,
						$OpenUGAI::Global::DBPASS),
	);
    &OpenUGAI::Util::Log("startup", "AssetServer::MySQL", "initialized");
    return bless \%fields , $this;
}

sub getAsset {
    my ($this, $uuid) = @_;
    my $conn = $this->{Connection};
    my $result = undef;
    my $sql = $SQL{select_asset_by_uuid};
    eval {
	my $st = new Statement($conn, $sql);
	$result = $st->exec($uuid);
    };
    if ($@) {
	Carp::croak("MySQL statement failed: $sql -> " . $@);	
    }
    if ($result) {
	my $count = @$result;
	if ($count > 0) {
	    my $xml = &_asset_to_xml($result->[0]);
	    return $xml;
	}
    }
    return ""; # TODO: failed xml
}

sub saveAsset {
    my ($this, $asset_xml) = @_;
    my $asset = &_xml_to_asset($asset_xml);
    my @asset_args;
    foreach(@ASSETS_COLUMNS) {
	push @asset_args, $asset->{$_};
    }
    my $conn = $this->{Connection};
    my $result = undef;
    my $sql = $SQL{insert_asset};
    eval {
	my $st = new Statement($conn, $sql);
	$result = $st->exec(@asset_args);
    };
    if ($@) {
	Carp::croak("MySQL statement failed: $sql -> " . $@);	
    }
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
