package OpenUGAI::AvatarSelectorServer;

use strict;
use Carp;
use OpenUGAI::RestService;
our @ISA = qw(OpenUGAI::RestService);
use OpenUGAI::Global;
use OpenUGAI::Data::Avatar;
use OpenUGAI::Data::Assets;
use OpenUGAI::Util;

our $AssetStorage;
our $AssetPresentation;
our $Instance;

sub StartUp {
    $Instance = OpenUGAI::AvatarSelectorServer->new( { log_name => "asset", } );
    $Instance->init();
}

sub new {
    my $this = shift;
    my $options = shift;
    my $super = OpenUGAI::RestService->new($options);
    return bless $super, $this;
}

sub init {
    my $this = shift;
    # register handlers
    $this->registerHandler( "GET", qr{^/AvatarSelector.New$}, \&_get_authtoken_handler );
    $this->registerHandler( "POST", qr{^/AvatarSelector.SaveAvatarData/([0-9a-f\-]{36})$}, \&_store_avatardata_handler );
    #$this->registerHandler( "POST", qr{^/AvatarSelector.SetAvatar/([0-9a-f\-]{36})$}, \&_store_asset_handler );
    Apache2::ServerRec::warn("avatarselectorserver initialized $$");
}

sub handler {
    my $this = shift;
    $this->run();
}

# Handler Functions
sub _get_authtoken_handler {
    my ($this, $cgi) = @_;
    print $cgi->header( -type => 'text/plain', -charset => "utf-8" ), &OpenUGAI::Util::GenerateUUID();
}

sub _store_avatardata_handler {
    my ($this, $cgi, $user_id, $auth_token) = @_; 
    my $auth_token = $cgi->param('auth_token');
    my $data = $cgi->param('POSTDATA');
    my $asset = {
	"id" => &OpenUGAI::Util::GenerateUUID(),
	"name" => $user_id . " avatar_irr",
	"description" => $user_id . " customized",
	"assetType" => 70,
	"local" => 0,
	"temporary" => 0,
	"data" => &MIME::Base64::decode_base64($data),
	};

    Apache2::ServerRec::warn("new asset id: " . $asset->{id});

    OpenUGAI::Data::Assets::UpdateAsset($asset);
    Apache2::ServerRec::warn("asset stored");
    OpenUGAI::Data::Avatar::UpdateAvatar3Di($user_id, $asset->{id});
    Apache2::ServerRec::warn("user avatar updated");

    my $response = "OK";
    print $cgi->header( -type => 'text/plain', -charset => "utf-8" ), $response;
}

1;

