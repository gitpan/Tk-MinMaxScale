#!perl -w
use strict;
use diagnostics;
use Tk;
use Test;

BEGIN { plan tests => 130 }

use Tk::MinMaxScale;
my $delay = 20;

my $mw = new MainWindow;

my $vn = 94;
my $vx = 117;
my $mms1 = $mw->MinMaxScale(
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

my $wn = 50;
my $wx = 70;
my $mms2 = $mw->MinMaxScale(
	-from => 30,
	-to => 80,
	-orient => 'vertical',
	-resolution => 1,
	-label => 'min-max',
	-variablemin => \$wn,
	-variablemax => \$wx,
)->pack;

$mw->after(1000, &start_test);

MainLoop;

sub start_test {
	for (1..19) {
		$wn++;
		$mw->after($delay, $mw->update);
		ok($wn < $wx);
	}
	for (20..29) {
		$wn++;
		$mw->after($delay, $mw->update);
 		ok($wx == $wn);
	}
	for (30..31) {
		$wn++;
		$mw->after($delay, $mw->update);
		ok($wn == 80);
		ok($wx == 80);
	}

	sleep 1;

	$wn = 40;
	$wx = 60;
	for (1..19) {
		$wx--;
		$mw->after($delay, $mw->update);
		ok($wx > $wn);
	}
	for (20..29) {
		$wx--;
		$mw->after($delay, $mw->update);
 		ok($wn == $wx);
	}
	for (30..31) {
		$wx--;
		$mw->after($delay, $mw->update);
		ok($wn == 30);
		ok($wx == 30);
	}

	sleep 1;

	$wn = 40;
	$wx = 60;

	sleep 1;

	$mw->eventGenerate('<Shift_L>');
	for (1..30) {
		$wn++;
		$mw->after($delay, $mw->update);
		ok(($wx - $wn) == 20);
	}
	ok($wn == 60);
	ok($wx == 80);

	sleep 1;

	$wn = 40;
	$wx = 60;

	sleep 1;

	for (1..30) {
		$wx--;
		$mw->after($delay, $mw->update);
		ok(($wx - $wn) == 20);
	}
	ok($wn == 30);
	ok($wx == 50);

	# that's all folks
	sleep 1;
	exit;
}

sub s1 {
	# does nothing
}
