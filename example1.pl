#!perl -w
use strict;
use Tk;
use Tk::MinMaxScale;

my $vn = 94;
my $vx = 117;
my $wn = 65;
my $wx = 86;

my $top = new MainWindow;

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
	-command => \&s2,
	-label => 'min-max',
	-variablemin => \$wn,
	-variablemax => \$wx,
)->pack;

MainLoop;

sub s1 {
	print "mms 1 $vn..$vx\n";
}
sub s2{
	print "mms 2 $wn..$wx\n";
}
