package OpenUGAITester;

use strict;
use OpenUGAITester::Config;
use OpenUGAITester::UserTester;
use OpenUGAITester::GridTester;
use OpenUGAITester::AssetTester;
use OpenUGAITester::InventoryTester;

sub init {
	UserTester::init();
	GridTester::init();
	AssetTester::init();
	InventoryTester::init();
}

sub SingleTest {
	my $url = shift;
	my $methodname = shift;
	my @ARGS = @_;

	if (!$OpenUGAITester::Config::HANDLER_LIST{$methodname}) {
	    Carp::croak("unknown handler name: [$methodname]");
	} else {
	    my $handler = $OpenUGAITester::Config::HANDLER_LIST{$methodname};
	    my $result = $handler->($url, @ARGS);
		return $result;
	}
}

sub PerformanceCompare {
    require PerformanceTest;
    
    my $server_name = shift;
    my $count = shift;
    my @args = @_;
    my $test = new PerformanceTest();
    {
	my @params = @args;
	unshift(@params, $OpenUGAITester::Config::APACHE_SERVERS{$server_name});
	$test->add_test("APACHE::$args[0]", \&OpenUGAITester::SingleTest, \@params);
    }
    {
	my @params = @args;
	unshift(@params, $OpenUGAITester::Config::OPENSIM_SERVERS{$server_name});
	$test->add_test("OPENSIM::$args[0]", \&OpenUGAITester::SingleTest, \@params);
    }
    $test->set_count($count);
    $test->start();
    print "\n\n";
    #$test->bref_result();
}

1;
