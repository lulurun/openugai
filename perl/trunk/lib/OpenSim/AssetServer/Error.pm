package OpenSim::AssetServer::Error;

sub NotFound {
    my $assetid = shift;
    return << "NOT_FOUND";
<AssetBase>
	<Data/>
	<FullID/>
</AssetBase>
NOT_FOUND
}

1;
