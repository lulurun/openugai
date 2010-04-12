package OpenUGAI::AssetServer::Memcached;

use strict;
use Cache::Memcached;

sub new {
    my $this = shift;
    my $memcached_server_list = shift;
    my $storage = shift;
    my $memcached = Cache::Memcached->new({
        servers => $memcached_server_list,
        #compress_threshold => 10_000,
					  });
    my $fields = {
        memcached => $memcached,
        storage => $storage,
    };
    return bless $fields, $this;
}

sub fetchAsset {
    my $this = shift;
    my $key = shift;
    my $val = $this->{memcached}->get($key);
    return $val if ($val);
    $val = $this->{storage}->fetchAsset($key);
    return undef if (!$val);
    $this->{memcached}->set($key, $val);
    return $val;
}

sub storeAsset {
    my $this = shift;
    my $key = shift;
    my $val = shift;
    $this->{storage}->storeAsset($key, $val);
    $this->{memcached}->set($key, $val);
}

sub getCacheStatus {
    my $this = shift;
    my $stats = $this->{memcached}->stats;
    return Data::Dump::dump $stats;
}


1;
