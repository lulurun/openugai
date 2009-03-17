package OpenUGAI::AssetServer::Storage::Gmail;

use strict;
use Gmail::Account;
use Carp;
use OpenUGAI::Util;

sub new {
    my ($this, $option) = @_;
    # gmail settings
    my $account = $option->{account} || Carp::croak("account  not set");
    my $password = $option->{password} || Carp::croak("password not set");
    my $mail_folder = $option->{folder} || Carp::croak("mail folder not set");
    # config.presentation
    my $presen_class = $option->{presentation} || Carp::croak("no presentation class");
    # get gmail connection
    my $ga = new OpenUGAI::Gmail::Account($account, $password);
    &OpenUGAI::Util::Log("startup", "AssetServer::Gmail", "create ga $$");
    $ga->login();
    &OpenUGAI::Util::Log("startup", "AssetServer::Gmail", "login success $$");
    # get asset list (for speedup)
    my $draft_list = $ga->getMessage( {folder => $mail_folder} );
    my %asset_list = ();
    foreach (@$draft_list) {
	$asset_list{$_->{subject}} = $_->{m_id};
    }

    my %fields = (
		  connection => $ga,
		  asset_list => \%asset_list,
		  presen_class => $presen_class,
		  account => $account,
		  password => $password,
		  mail_folder => $mail_folder,
	);
    &OpenUGAI::Util::Log("startup", "AssetServer::Gmail", "initialized $$");
    return bless \%fields , $this;
}

sub fetchAsset {
    my ($this, $id) = @_;
    my $conn = $this->{connection};
    return 0 if ( !($this->{asset_list}->{$id}) );
    my $m_id = $this->{asset_list}->{$id};
    my $draft_mail = $conn->getMessage( {folder => "draft", msg_id => $m_id } );
    return $this->{presen_class}->deserialize($draft_mail->{body});
}

sub storeAsset {
    my ($this, $asset) = @_;
    my $conn = $this->{Connection};
    my $asset_contents = $this->{presen_class}->serialize($asset);
    $conn->sendMessage($this->{account} . "\@gmail.com", $asset->{id}, $asset_contents);
    return 1;
}

sub deletAsset {
    Carp::croak("not implemented");
}

1;
