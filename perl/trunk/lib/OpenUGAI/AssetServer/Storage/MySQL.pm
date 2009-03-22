package OpenUGAI::AssetServer::Storage::MySQL;

use OpenUGAI::DBData;

sub new {
    my ($this, $option) = @_;
    my $db_info = $option->{db_info} || Carp::croak("db_info not set");
    return new OpenUGAI::DBData($db_info);
}

1;

