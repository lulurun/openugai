package OpenUGAI::AssetServer::Storage::Gmail;

use strict;
use OpenUGAI::Global;
use OpenUGAI::Gmail::Account;
use OpenUGAI::Util;
use XML::Simple;

our $GMAIL_ACCOUNT = "luluasset";
our $GMAIL_PASSWORD = "1u1u\@sset";
our $ASSET_FOLDER = "drafts";


sub new {
    my $this = shift;
    &OpenUGAI::Util::Log("startup", "AssetServer::Gmail", "startup ... $$");
    my $ga = new OpenUGAI::Gmail::Account($GMAIL_ACCOUNT, $GMAIL_PASSWORD);
    &OpenUGAI::Util::Log("startup", "AssetServer::Gmail", "create ga $$");
    $ga->login();
    &OpenUGAI::Util::Log("startup", "AssetServer::Gmail", "login success $$");
    my $draft_list = $ga->getMessage( {folder => $ASSET_FOLDER} );
    my %asset_list = ();
    foreach (@$draft_list) {
	$asset_list{$_->{subject}} = $_->{m_id};
    }
    my %fields = (
		  Connection => $ga,
		  AssetList => \%asset_list,
	);
    &OpenUGAI::Util::Log("startup", "AssetServer::Gmail", "initialized $$");
    return bless \%fields , $this;
}

sub getAsset {
    my ($this, $uuid) = @_;
    my $conn = $this->{Connection};
    Carp::croak("can not find asset $uuid") if ( !($this->{AssetList}->{$uuid}) );
    my $m_id = $this->{AssetList}->{$uuid};
    my $draft_mail = $conn->getMessage( {folder => "draft", msg_id => $m_id } );
    my $asset_xml = $draft_mail->{body};
    return $asset_xml;
}

sub saveAsset {
    my ($this, $asset_xml) = @_;
    my $conn = $this->{Connection};
    my $asset_id = &_get_asset_id($asset_xml);
    $conn->sendMessage($GMAIL_ACCOUNT . "\@gmail.com", $asset_id, $asset_xml);
    return;
}

sub _get_asset_id {
    my $xml = shift;
    if ($xml =~ /<ID>([^<]+)<\/ID>/) {
	return $1;
    }
    Carp::croak("can not get asset id: unknown asset format");
}

1;

