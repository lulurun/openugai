package OpenUGAI::AssetServer::Storage::File;

sub new {
    my ($this, $options) = @_;
    return bless { db_info => $db_info }, $this;
}

sub fetchAsset {
    my ($this, $id) = @_;
    return &OpenUGAI::DBData::Assets::fetchAsset($this->{db_info}, $id);
}

sub storeAsset {
    my ($this, $asset) = @_;
    return &OpenUGAI::DBData::Assets::storeAsset($this->{db_info}, $asset);
}

sub deletAsset {
    my ($this, $id) = @_;
    return &OpenUGAI::DBData::Assets::deleteAsset($this->{db_info}, $id);
}

1;

