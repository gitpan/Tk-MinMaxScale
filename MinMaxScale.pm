package Tk::MinMaxScale;
use Carp;
use Tk;

@ISA = qw(Tk::Frame);

$VERSION = '0.07';

Construct Tk::Widget 'MinMaxScale';

my $shifted; # is Shift key pressed ?

sub Populate {
	my ($smin, $smax); # the scales
	my ($minvar, $maxvar); # references of variables associated with the scales
	my ($oldmin, $oldmax); # previous values of the variables
	my ($minlbl, $maxlbl); # labels for the scales
	my $cmd; # reference to a callback associated with any change
	my $orient; # 'horizontal' or 'vertical'
	my ($vmin, $vmax); # just in case the caller don't provide variables
	my $to;
	my $from;

	my ($cw, $args) = @_;
	$cw->SUPER::Populate($args);

	my $pn = __PACKAGE__;
	delete $args->{'-variable'} && carp("$pn warning: option \"-variable\" not allowed");

	# let's make the widget horizontal unless defined other specs
	$orient = delete $args->{'-orient'};
	$orient = 'horizontal' unless defined $orient;
	my $sideforpack = $orient eq 'vertical' ? 'left' : 'top';

	$to = delete $args->{'-to'};
	$to = 100 unless defined $to;

	$from = delete $args->{'-from'};
	$from = 0 unless defined $from;

	$minvar = delete $args->{'-variablemin'};
	if (!defined $minvar) {
		$minvar = \$vmin;
		$vmin = $args->{'-from'};
	}
	$maxvar = delete $args->{'-variablemax'};
	if (!defined $maxvar) {
		$maxvar = \$vmax;
		$vmax = $args->{'-to'};
	}

	($oldmin, $oldmax) = ($$minvar, $$maxvar);

	$minlbl = delete $args->{'-labelmin'};
	$maxlbl = delete $args->{'-labelmax'};

	$cmd = delete $args->{'-command'};
	$cmd = sub {} unless defined $cmd;

	# create the subwidget 'min' Scale
	$smin = $cw->Scale(
		%$args,
		-variable => $minvar,
		-label => $minlbl,
		-orient => $orient,
		-from => $from,
		-to => $to,
		-command => sub {
			if ($shifted) {
				my $distance = $oldmax - $oldmin; # distance between sliders
				my $distancemin = $to - $$minvar; # distance between min slider and maximum
				if ($distancemin < $distance) {
					$$minvar = $$maxvar - $distance;
					return;
				} else {
					$$maxvar = $$minvar + $distance;
				}
			} else {
				$$maxvar = $$minvar if $$minvar > $$maxvar;
			}
			if ((!defined $oldmin) || (!defined $oldmax) || ($$minvar != $oldmin) || ($$maxvar != $oldmax)) {
				$oldmin = $$minvar;
				$oldmax = $$maxvar;
				&$cmd;
			}
			return;
		},
	);
	$smin->pack(side => $sideforpack);

	# create the subwidget 'max' Scale
	$smax = $cw->Scale(
		%$args,
		-variable => $maxvar,
		-label => $maxlbl,
		-orient => $orient,
		-from => $from,
		-to => $to,
		-command => sub {
			if ($shifted) {
				my $distance = $oldmax - $oldmin; # distance between sliders
				my $distancemax = $$maxvar - $from; # distance between minimum and max slider
				if ($distancemax < $distance) {
					$$maxvar = $$minvar + $distance;
					return;
				} else {
					$$minvar = $$maxvar - $distance;
				}
			} else {
				$$minvar = $$maxvar if $$maxvar < $$minvar;
			}
			if (($$minvar != $oldmin) || ($$maxvar != $oldmax)) {
				$oldmin = $$minvar;
				$oldmax = $$maxvar;
				&$cmd;
			}
			return;
		},
	);
	$smax->pack(side => $sideforpack);

	$cw->ConfigSpecs (
		DEFAULT => [PASSIVE],
		-variablemin => [$minvar, undef, undef, undef],
		-variablemax => [$maxvar, undef, undef, undef],
	);

	$cw->toplevel->bind("<Key>", [ \&is_shift_key, Ev('s'), Ev('K') ] );
	$cw->toplevel->bind("<KeyRelease>", [ \&is_shift_key, Ev('s'), Ev('K') ] );
}

sub is_shift_key {
	$shifted = ($_[1] =~ /^Shift/) && ($_[2] =~ /^Shift/) ? 0 : 1;
}

sub minvalue {
	my $mms = shift;
	my $refval = $mms->{ConfigSpecs}->{'-variablemin'}[0];
	$$refval = shift if @_;
	return $$refval;
}

sub maxvalue {
	my $mms = shift;
	my $refval = $mms->{ConfigSpecs}->{'-variablemax'}[0];
	$$refval = shift if @_;
	return $$refval;
}

1;

__END__

=head1 NAME

Tk::MinMaxScale - Two Scale(s) to get a (min, max) values pair

=head1 SYNOPSIS

I<$mms> = I<$parent>-E<gt>B<MinMaxScale>(I<-option> =E<gt> I<value>, ... );

I<$mms> = I<$parent>-E<gt>B<MinMaxScale>(
    -variablemin =E<gt> \$vn,
    -variablemax =E<gt> \$vx,
    -labelmin =E<gt> ...,
    -labelmax =E<gt> ...,
    ...,
);

I<$varmin> = I<$mms>-E<gt>B<minvalue>;

I<$mms>-E<gt>B<minvalue>(10);

I<$varmax> = I<$mms>-E<gt>B<maxvalue>;

I<$mms>-E<gt>B<maxvalue>($var);

=head1 DESCRIPTION

Tk::MinMaxScale is a Frame-based widget wrapping two Scale widgets,
the first acting as a 'minimum' and the second as a 'maximum'.
The value of 'minimum' is always less than or equal to the value of 'maximum'.

The purpose of Tk::MinMaxScale is to get a range of values narrower
than the whole Scale range given by the options B<-from> and B<-to>
(applied to both 'minimum' and 'maximum' Scale).
This is done through the options B<-variablemin> and B<-variablemax>,
or via the methods B<minvalue> and B<maxvalues>, see below.

In addition, dragging a slider while pressing a B<Shift> key drags both sliders,
locking their distance. You must hold down the B<Shift> key before dragging a slider.

=head1 OPTIONS

The widget accepts all options accepted by B<Scale> (except B<-variable> option),
and their default value (except for B<-orient> option wich defaults to 'horizontal').
In addition, the following option/value pairs are supported, but not required:

=over 4

=item B<-labelmin>

The text used as a label for the 'minimum' Scale. Default none.

=item B<-labelmax>

The text used as a label for the 'maximum' Scale. Default none.

=item B<-variablemin>

A reference to a global variable linked with the 'minimum' Scale.

=item B<-variablemax>

A reference to a global variable linked with the 'maximum' Scale.

=back

=head1 METHODS

=over 4

=item B<minvalue>

Get the value of 'min' scale. With an argument, set the value of 'min' scale,
bounded by 'B<-from>' and 'B<maxvalue>' values.

=item B<maxvalue>

Get the value of 'max' scale. With an argument, set the value of 'max' scale,
bounded by 'B<minvalue>' and 'B<-to>' values.

=head1 HISTORY

=item B<v0.07> - 2002/11/21

=over 2

=item -
added tests.

=back

=item B<v0.06> - 2002/11/20

=over 2

=item -
dropped "use warnings" and "use diagnostics".

=item -
cleaned up the distribution package.

=back

=item B<v0.05> - 2002/11/05

=over 2

=item -
unlike Scale, 'B<-orient>' option defaults now to 'horizontal'.

=item -
like Scale, 'B<-from>' and 'B<-to>' options defaults now to 0 and 100, respectively.

=item -
definitely (:() fixed Shift-key binding problems.

=back

=item B<v0.04> - 2002/11/01

=over 2

=item -
enhanced methods B<minvalue> and B<maxvalue> to set|get the scale values.

=back

=item B<v0.03> - 2002/11/01

=over 2

=item -
fixed some problems when dragging while depressing shift key

=item -
added methods B<minvalue> and B<maxvalue>

=back

=item B<v0.02> - 2002/10/24

=over 2

=item -
new feature added: dragging a slider while pressing a B<Shift> key
drags both sliders, locking their distance (an idea from Mark Lakata).

=back

=item B<v0.01> - 2002/10/17

=over 2

=item -
first release.

=back

=head1 TODO

- switch to a 'one groove, two sliders' scale.

=head1 AUTHOR

Jean-Pierre Vidal, E<lt>jeanpierre.vidal@free.frE<gt>

This package is free software and is provided 'as is'
without express or implied warranty. It may be used, modified,
and redistributed under the same terms as Perl itself.

Feedback would be appreciated in many ways, including corrections to my poor english.

=head1 SEE ALSO

B<Tk::Scale>

=cut
