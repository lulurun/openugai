package OpenSim::ServerLog::User;

use strict;

my %USER_DEF;
my @USER_DEF_NAMES = ( "RECRUIT", "STAFF", "3Di" );
my $recruit_user = 1;
my $staff_user = 2;
my $_3di_user = 3;

BEGIN {
    $recruit_user = 1;
    $staff_user = 2;
    $_3di_user = 3;

    %USER_DEF = ();
    for(1..100) {
 	my $first_name = sprintf("recruit%03d", $_);
	my $last_name = "mixi";
	$USER_DEF{$first_name . " " . $last_name} = $recruit_user;
    }
    for(101..110) {
 	my $first_name = sprintf("recruit%03d", $_);
	my $last_name = "mixi";
	$USER_DEF{$first_name . " " . $last_name} = $_3di_user;
    }
    $USER_DEF{"Umezaki mixistaff"} = $staff_user;
    $USER_DEF{"Kondo mixistaff"} = $staff_user;
    $USER_DEF{"Tester mixi"} = $_3di_user;
    $USER_DEF{"Admin mixi"} = $_3di_user;
};

sub get_user_def {
    my $name = shift;
    return $USER_DEF_NAMES[$USER_DEF{$name}];
}

sub get_recruit_users {
    my @ret = ();
    foreach (keys %USER_DEF) {
	if ($USER_DEF{$_} == $recruit_user) {
	    push @ret, $_;
	}
    }
    return @ret;
}

1;
