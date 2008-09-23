package OpenUGAI::AssetServer::Storage::Gmail;

use strict;
use OpenUGAI::Global;
use OpenUGAI::Gmail::Account;

our @ASSETS_COLUMNS = (
    "name",
    "description",
    "assetType",
    "local",
    "temporary",
    "data",
    "id",
    );

our $GMAIL_ACCOUNT = "luluasset";
our $GMAIL_PASSWORD = "1u1u\@sset";

sub new {
    my $this = shift;
    my $ga = new OpenUGAI::Gmail::Account($GMAIL_ACCOUNT, $GMAIL_PASSWORD);
    $ga->login();
    my $draft_list = $ga->getMessage( {folder => "draft"} );
    my %asset_list = ();
    foreach (@$draft_list) {
	$asset_list{$_->{subject}} = $_->{m_id};
    }
    my %fields = (
		  Connection => $ga,
		  AssetList => \%asset_list,
	);
    return bless \%fields , $this;
}

sub getAsset {
    my ($this, $uuid) = @_;
    my $conn = $this->{Connection};
    Carp::croak("can not find asset $uuid") if ( !($this->{AssetList}->{$uuid}) );
    my $m_id = $this->{AssetList}->{$uuid};
    my %att_args = (
		    a_id => "0.1", # TODO: fix me !!
		    m_id => $m_id,
		    );
    my $asset_text = undef;
    eval {
	$asset_text = $gacc->getAttachment(\%att_args);
    };
    if ($@) {
	Carp::croak("can not get asset $uuid: $@");	
    }
    my $asset = "";
    my $get_asset = "\$asset = " . $asset_text;
    eval {
	\$get_asset;
    };
    return $asset;
}

sub saveAsset {
    my ($this, $asset_xml) = @_;
    my $conn = $this->{Connection};
    $conn->sendMessage($GMAIL_ACCOUNT . "\@gmail.com", $asset->{id}, $asset_xml);
    return $result;
}

1;

