package OpenUGAI::LoginServer::Auth::OpenID;

use strict;
use OpenUGAI::Util;
# OpenID
use CGI;
use LWPx::ParanoidAgent;
use Net::OpenID::Consumer;

# ##################
# OpenID authentication request
sub openid_request_handler {
    my $param = shift;
    my $openid = $param->{openid_identifier};
    my $csr = new Net::OpenID::Consumer(
					ua    => new LWPx::ParanoidAgent(),
					args  => new CGI, # TODO: should be $param
					consumer_secret => $OpenUGAI::Global::OPENID_CONSUMER_SECRET,
					);

    my $claimed_identity = $csr->claimed_identity($openid);
    if (!$claimed_identity) {
	Carp::croak("not a valid openid");
    }
    if ($OpenUGAI::Global::USER_AX) {
	# sreg
	$claimed_identity->set_extension_args($OpenUGAI::Global::OPENID_NS_SREG_1_1, {
	    required => join(",", qw/email nickname/)
	    });
    } else {
	# ax
	$claimed_identity->set_extension_args($OpenUGAI::Global::OPENID_NS_AX_1_0, {
	    mode => 'fetch_request',
	    "type.nickname" => "http://schema.openid.net/namePerson/friendly",
	    "type.email" => "http://schema.openid.net/contact/email",
	    "type.firstname" => "http://schema.openid.net/namePerson/first",
	    "type.lastname" => "http://schema.openid.net/namePerson/last",
	    required => 'nickname,email,firstname,lastname',
	});
    }
    my $check_url = $claimed_identity->check_url(
						 return_to  => $OpenUGAI::Global::OPENID_RETURN_TO_URL,
						 trust_root => $OpenUGAI::Global::OPENID_TRUST_ROOT_URL,
						 delayed_return => "checkid_setup",
						 );
    return wantarray ? ( $check_url, "redirect" ) : $check_url;
}

# ##################
# OpenID authentication verification
sub openid_verify_handler {
    my $param = shift;
    my $csr = new Net::OpenID::Consumer(
					ua    => new LWPx::ParanoidAgent(),
					args  => new CGI, # TODO: should be $param
					consumer_secret => $OpenUGAI::Global::OPENID_CONSUMER_SECRET,
					);

    $csr->handle_server_response(
				 not_openid => sub {
				     Carp::croak("Not an OpenID message");
				 },
				 setup_required => sub {
				     my $setup_url = shift;
				     # Redirect the user to $setup_url
				     #&MyCGI::redirect($setup_url);				     
                                     return wantarray ? ( $setup_url, "redirect" ) : $setup_url;
				 },
				 cancelled => sub {
				     # Do something appropriate when the user hits "cancel" at the OP
				 },
				 verified => sub {
				     my $vident = shift;
				     # Do something with the VerifiedIdentity object $vident
				     my $extinfo;
				     if ($OpenUGAI::Global::USE_AX) {
					 $extinfo = $vident->extension_fields($OpenUGAI::Global::OPENID_NS_SREG_1_1);
				     } else {
					 $extinfo = $vident->extension_fields($OpenUGAI::Global::OPENID_NS_AX_1_0);			
				     }
				     my $userinfo = &_openid_verified_ok($extinfo);
				     my $auth_key = $userinfo->{webLoginKey};
				     my $redirect_url = &OpenUGAI::Util::client_login_trigger($userinfo, $auth_key); 
				     return wantarray ? ( $redirect_url, "redirect" ) : $vident;
				 },
				 error => sub {
				     my $err = shift;
				     Carp::croak($err);
				 },
				 );
}

# ##################
# private method
sub _openid_verified_ok {
    my $param = shift;
    my $firstname = "User";
    my $lastname = "@ OpenID";
    if ($param && $param->{"value.nickname.1"}) {
	$firstname = $param->{"value.nickname.1"};
    }
    my $key = &OpenUGAI::Util::GenerateUUID();
    my %userinfo = (
		    UUID => $key,
		    username => $firstname,
		    lastname => $lastname,
		    webLoginKey => $key,
		    );
    my $user = &OpenUGAI::Data::Users::CreateTemporaryUser(\%userinfo);
    Storable::store($user, $OpenUGAI::Global::LOGINKEYDIR . "/" . $key);
    return $user;
}

1;

