#!perl -w
use strict;
use Tk;
use Test;
use Tk::ROText;

BEGIN { plan tests => 1 }

use Tk::MinMaxScale;

my $vn = 94;
my $vx = 117;
my $wn = 65;
my $wx = 86;

my $timetest = 10;

my $top = new MainWindow;
$top->after( $timetest * 1000, sub { ok(1); exit; } );

my $mms1 = $top->MinMaxScale(
	-from => 50.0,
	-to => 150.0,
	-orient => 'horizontal',
	-resolution => 0.1,
	-command => \&s1,
	-labelmin => 'mini',
	-labelmax => 'max',
	-label => 'minmax',
	-variablemin => \$vn,
	-variablemax => \$vx,
)->pack;

my $mms2 = $top->MinMaxScale(
	-from => 30,
	-to => 120,
	-orient => 'vertical',
	-resolution => 1,
	-label => 'min-max',
	-variablemin => \$wn,
	-variablemax => \$wx,
)->pack;

my $stop = new MainWindow;
my $rot = $stop->ROText(-wrap => 'word')->pack;
$rot->insert('end', "test running for about $timetest seconds\n\n");

$stop->after( $timetest * 1000, sub { exit; } );

MainLoop;

sub s1 {
	# does nothing
}
