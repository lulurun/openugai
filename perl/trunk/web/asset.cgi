#!/usr/bin/perl -w

use strict;
use OpenUGAI::Util;
use OpenUGAI::Global;
use OpenUGAI::AssetServer;
require "config.pl";

# test
#&OpenUGAI::Util::Log("asset", "test ENV $$", \%ENV);

$OpenUGAI::AssetServer::Instance->run();

