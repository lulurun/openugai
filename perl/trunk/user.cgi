#!/usr/bin/perl -w

use strict;
use OpenUGAI::Util;
use OpenUGAI::UserServer;
require "config.pl";

my $config = undef; # TODO @@@ : = OpenUGAI::Config::GetConfig();
my $server = new OpenUGAI::UserServer();
$server->init($config);
$server->run();

A
