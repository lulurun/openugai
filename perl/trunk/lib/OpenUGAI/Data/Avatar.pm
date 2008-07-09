package OpenUGAI::Data::Avatar;

use strict;
use OpenUGAI::Utility;

my %SQL = (
    get_avatar_appearance => "select * from avatarappearance where owner=?",
    save_avatar_appearance => "insert into avatarappearance values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
);

sub SelectAppearance {
    my $owner = shift;
    my $res = &OpenUGAI::DBData::getSimpleResult($SQL{get_avatar_appearance}, $owner);
    my $count = @$res;
    if ($count == 1) {
    	my $appearance = $res->[0];
	my %xmlrpc_obj = ();
	$xmlrpc_obj{visual_params} = RPC::XML::base64->new($appearance->{Visual_Params});
	delete $appearance->{Visual_Params};
	$xmlrpc_obj{texture} = RPC::XML::base64->new($appearance->{Texture});
	delete $appearance->{Texture};
	map { $xmlrpc_obj{lc($_)} = RPC::XML::string->new($appearance->{$_}); } keys %$appearance;
	return \%xmlrpc_obj;
    } else {
    	return undef;
    }
}

sub SaveAppearance {
}

