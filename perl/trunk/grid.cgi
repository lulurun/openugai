#!/usr/bin/perl -w

use strict;
use OpenUGAI::Util;
use OpenUGAI::GridServer;
require "config.pl";

my $config = undef; # TODO @@@ : = OpenUGAI::Config::GetConfig();
my $server = new OpenUGAI::GridServer();
$server->init($config);
$server->run();

