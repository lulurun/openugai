package OpenUGAI::GridServer2;

use strict;
use Carp;
use JSON;
use Data::Dump;
use CGI;
use OpenUGAI::RestService;
our @ISA = qw(OpenUGAI::RestService);
use OpenUGAI::Global;
use OpenUGAI::DynamicGridHandler;
use OpenUGAI::Data::DynamicGridData;

our $Instance;

sub StartUp {
    $Instance = OpenUGAI::GridServer2->new( { log_name => "grid2", } );
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
    my $options = shift;

    # init dir
    if (! -d $OpenUGAI::Global::Region_DIR) {
	mkdir($OpenUGAI::Global::Region_DIR) || Apache2::ServerRec::warn("grid2 server RegionDIR " . $OpenUGAI::Global::Region_DIR);
    }
    if (! -d $OpenUGAI::Global::Contents_DIR) {
	mkdir($OpenUGAI::Global::Contents_DIR) || Apache2::ServerRec::warn("grid2 server ContentsDIR " . $OpenUGAI::Global::Contents_DIR);
    }
    # register handlers
    # called from region server
    $this->registerHandler( "POST", qr{^/region/info$}, \&_add_region_handler );
    # TODO @@@ fix the url after finish "select random coord"
    $this->registerHandler( "POST", qr{^/region/info/delete/([0-9a-f\-]{36})$}, \&_delete_region_handler );
    $this->registerHandler( "GET", qr{^/contents/data/([0-9a-f\-]{36})$}, \&_get_contents_data_handler );

    # called from web
    $this->registerHandler( "GET", qr{^/region/info/([0-9a-f\-]{36})$}, \&_get_region_handler );
    $this->registerHandler( "GET", qr{^/region/list$}, \&_get_region_list_handler );
    # TODO @@@ move to other server ?? asset ??? 
    $this->registerHandler( "GET", qr{^/contents/list$}, \&_get_contents_list_handler );
    $this->registerHandler( "GET", qr{^/contents/info/([0-9a-f\-]{36})$}, \&_get_contents_info_handler );
    $this->registerHandler( "POST", qr{^/contents/info$}, \&_add_contents_info_handler );
}

# ### From OpenSim ###
sub _add_region_handler {
    my ($this, $cgi) = @_; 
    my $req = &__getRegionRequestObj($cgi->param('POSTDATA'));
    my $res = &OpenUGAI::DynamicGridHandler::AddRegion($req);
    my $response = &__createRegionResponse($res);
    Apache2::ServerRec::warn(Data::Dump::dump $res);
    print $cgi->header( -type => 'text/plain', -charset => "utf-8" ), $response;
}

sub _delete_region_handler {
    my ($this, $cgi, $id) = @_;
    my $req = &__getRegionRequestObj($cgi->param('POSTDATA'));
    &OpenUGAI::DynamicGridHandler::DeleteRegion($req);
    print $cgi->header( -type => 'text/plain', -charset => "utf-8" ), "OK";
}

sub _get_contents_data_handler {
    my ($this, $cgi, $id) = @_;
    my $contents_file = $OpenUGAI::Global::Contents_DIR . "/" . $id;
    if (!-e $contents_file) {
	print $cgi->header( -type => 'text/plain', -charset => "utf-8", -status => "404 Not Found"), "";
    }
    &OpenUGAI::DynamicGridHandler::UpdateContentsDownloadStatus($id);
    my $contents_url = $OpenUGAI::Global::Contents_URL . "/" . $id;
    
    Apache2::ServerRec::warn($contents_url);
    print $cgi->redirect( $contents_url );
}

# ### LiveRegions ###
sub _get_region_list_handler {
    my ($this, $cgi) = @_;
    my $region_list = &OpenUGAI::Data::DynamicGridData::GetRegionList();
    my $region_count = @$region_list;
    my $res = {
	count => $region_count,
	list => $region_list,
    };
    Apache2::ServerRec::warn(Data::Dump::dump $res);
    print $cgi->header( -type => 'text/plain', -charset => "utf-8" ), JSON::to_json($res);
}

sub _get_region_handler {
    my ($this, $cgi, $id) = @_;
    my $region = &OpenUGAI::DynamicGridHandler::GetRegion($id);
    print $cgi->header( -type => 'text/plain', -charset => "utf-8" ), JSON::to_json($region);
}

# ### Contents ###
sub _add_contents_info_handler {
    my ($this, $cgi) = @_; 
 
    my $contents_uuid = OpenUGAI::Util::GenerateUUID();
    &OpenUGAI::DynamicGridHandler::SaveContentsData($cgi, "file_0", $contents_uuid, 0);
    &OpenUGAI::DynamicGridHandler::SaveContentsData($cgi, "file_16", $contents_uuid, 16);

    my $req = {
	UUID => $contents_uuid,
	name => $cgi->param("name"),
	desc => $cgi->param("description"),
	url => $cgi->param("related_url"),
    };
    my $res = &OpenUGAI::DynamicGridHandler::AddContentsInfo($req);

    print $cgi->header( -type => 'text/plain', -charset => "utf-8" ), "OK";
}

sub _get_contents_list_handler {
    my ($this, $cgi) = @_;
    my $contents_list = &OpenUGAI::Data::DynamicGridData::GetContentsList();

    my $list = {};
    foreach my $contents (@$contents_list) {
	$list->{$contents->{contents_uuid}}->{id} = $contents->{contents_uuid};
	$list->{$contents->{contents_uuid}}->{url} = $contents->{related_url};
	$list->{$contents->{contents_uuid}}->{name} = $contents->{name};
	$list->{$contents->{contents_uuid}}->{desc} = $contents->{description};
	my $data = {
	    id => $contents->{id},
	    size => $contents->{size},
	    type => $contents->{type},
	};
	push @{$list->{$contents->{contents_uuid}}->{data}}, $data;
    }

    my $count = keys %$list;
    my $res = {
	count => $count,
	list => $list,
    };

    #Apache2::ServerRec::warn(Data::Dump::dump $res);
    print $cgi->header( -type => 'text/plain', -charset => "utf-8" ), JSON::to_json($res);
}

sub _get_contents_info_handler {
    my ($this, $cgi, $id) = @_;
    my $contents_list = &OpenUGAI::Data::DynamicGridData::GetContentsInfo($id);

    my $list = {};
    foreach my $contents (@$contents_list) {
	$list->{$contents->{contents_uuid}}->{id} = $contents->{contents_uuid};
	$list->{$contents->{contents_uuid}}->{url} = $contents->{related_url};
	$list->{$contents->{contents_uuid}}->{name} = $contents->{name};
	$list->{$contents->{contents_uuid}}->{desc} = $contents->{description};
	my $data = {
	    id => $contents->{id},
	    size => $contents->{size},
	    type => $contents->{type},
	};
	push @{$list->{$contents->{contents_uuid}}->{data}}, $data;
    }

    my $count = keys %$list;
    my $res = {
	count => $count,
	list => $list,
    };

    print $cgi->header( -type => 'text/plain', -charset => "utf-8" ), JSON::to_json($res);
}

# Private Functions
sub __getRegionRequestObj {
    my $data = shift;
    my $req_data = {};
    my @lines = split(/\n/, $data);
    foreach (@lines) {
	my ($key, $value) = split(/\t/, $_);
	$req_data->{$key} = $value;
    }
    return $req_data;
}

sub __createRegionResponse {
    my $region = shift;
    my $res_data = "";
    foreach(keys %$region) {
	$res_data .= $_ . "\t" . $region->{$_} .  "\n";
    }
    return $res_data;
}

sub __parseFormData {
    my $form_data = shift;
    my @data = split(/=/, $form_data);
    my $res = {};
    foreach(@data) {
	my ($k, $v) = split(/&/, $_);
	$res->{$k} = $v;
    }
    return $res;
}

1;

