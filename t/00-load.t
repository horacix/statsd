#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Net::StatsD' ) || print "Bail out!
";
}

diag( "Testing Net::StatsD $Net::StatsD::VERSION, Perl $], $^X" );
