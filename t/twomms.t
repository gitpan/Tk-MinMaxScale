#!perl -w
use strict;
use diagnostics;
use Tk;
use Test;

BEGIN { plan tests => 130 }

use Tk::MinMaxScale;
my $delay = 50;

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

$mw->after(2000, &start_test);

MainLoop;

sub start_test {
	for (1..19) {
		$wn++;
		$mw->update;
		$mw->after($delay);
		ok($wn < $wx);
	}

	$mw->after(1000);

	for (20..29) {
		$wn++;
		$mw->update;
 		ok($wx == $wn);
	}

	$mw->after(1000);

	for (30..31) {
		$wn++;
		$mw->update;
		$mw->after($delay);
		ok($wn == 80);
		ok($wx == 80);
	}

	$mw->after(1000);

	$wn = 40;
	$wx = 60;

	$mw->after(1000);

	for (1..19) {
		$wx--;
		$mw->update;
		$mw->after($delay);
		ok($wx > $wn);
	}

	$mw->after(1000);

	for (20..29) {
		$wx--;
		$mw->update;
 		ok($wn == $wx);
	}

	$mw->after(1000);

	for (30..31) {
		$wx--;
		$mw->update;
		$mw->after($delay);
		ok($wn == 30);
		ok($wx == 30);
	}

	$mw->after(1000);

	$wn = 40;
	$wx = 60;


	$mw->after(1000);

	$mw->eventGenerate('<Shift_L>');
	for (1..30) {
		$wn++;
		$mw->update;
		$mw->after($delay);
		ok(($wx - $wn) == 20);
	}
	ok($wn == 60);
	ok($wx == 80);

	$mw->after(1000);

	$wn = 40;
	$wx = 60;

	$mw->after(1000);

	for (1..30) {
		$wx--;
		$mw->update;
		$mw->after($delay);
		ok(($wx - $wn) == 20);
	}
	ok($wn == 30);
	ok($wx == 50);

	# that's all folks
	$mw->after(1000);
	exit;
}

sub s1 {
	# does nothing
}
