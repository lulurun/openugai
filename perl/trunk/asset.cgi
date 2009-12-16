#!/usr/bin/perl -w

use strict;
use OpenUGAI::Util;
use OpenUGAI::AssetServer;
require "config.pl";

my $config = undef; # TODO @@@ : = OpenUGAI::Config::GetConfig();
my $options = {
    has_memcached => 1,
    memcached_server_addr => "127.0.0.1:11211",
};

my $server = new OpenUGAI::AssetServer();
$server->init($config);
$server->run();



