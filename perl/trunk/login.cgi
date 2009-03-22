#!/usr/bin/perl -w

use strict;
use OpenUGAI::Util;
use OpenUGAI::LoginServer;
require "config.pl";

my $config = undef; # TODO @@@ : = OpenUGAI::Config::GetConfig();
my $server = new OpenUGAI::LoginServer();
$server->init($config);
$server->run();

