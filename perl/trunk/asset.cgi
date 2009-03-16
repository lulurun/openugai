#!/usr/bin/perl -w

use strict;
use OpenUGAI::Util;
use OpenUGAI::AssetServer;
require "config.pl";

my $config = undef; # TODO @@@ : = OpenUGAI::Config::GetConfig();
my $server = new OpenUGAI::AssetServer();
$server->init($config);
$server->run();

