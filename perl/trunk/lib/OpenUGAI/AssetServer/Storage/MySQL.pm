package OpenUGAI::AssetServer::Storage::MySQL;

use DBHandler;
use OpenUGAI::DBData::Assets;

sub new {
    my ($this, $db_info) = @_;
    my $dbh = new DBHandler($db_info);
    bless { dbh => $dbh }, $this;
}

sub fetchAsset {
    my ($this, $id) = @_;
    return &OpenUGAI::DBData::Assets::fetchAsset($this->{dbh}, $id);
}

sub storeAsset {
    my ($this, $asset) = @_;
    return &OpenUGAI::DBData::Assets::storeAsset($this->{dbh}, $asset);
}

sub deletAsset {
    my ($this, $id) = @_;
    return &OpenUGAI::DBData::Assets::deleteAsset($this->{dbh}, $id);
}

1;

