#!/usr/bin/perl -w

use strict;
use OpenUGAI::Util;
use OpenUGAI::InventoryServer;
require "config.pl";

my $config = undef; # TODO @@@ : = OpenUGAI::Config::GetConfig();
my $server = new OpenUGAI::InventoryServer();
$server->init($config);
$server->run();

