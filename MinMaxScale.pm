package Tk::MinMaxScale;
use warnings;
use diagnostics;
use Carp;

@ISA = qw(Tk::Frame);

$VERSION = '0.03';

Construct Tk::Widget 'MinMaxScale';

my $shifted; # is Shift key pressed ?

sub Populate {
	my ($smin, $smax); # the scales
	my ($minvar, $maxvar); # references of variables associated with the scales
	my ($oldmin, $oldmax); # previous values of the variables
	my ($minlbl, $maxlbl); # labels for the scales
	my $cmd; # reference to a callback associated with any change
	my ($vmin, $vmax); # just in case the caller don't provide variables

	my ($cw, $args) = @_;
	$cw->SUPER::Populate($args);

	my $pn = __PACKAGE__;
	delete $args->{'-variable'} && carp("$pn warning: option \"-variable\" not allowed");

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
	$smin = $cw->Component(
		'Scale', 'top',
		%$args,
		-variable => $minvar,
		-label => $minlbl,
		-command => sub {
			if ($shifted) {
				my $distance = $oldmax - $oldmin; # distance between sliders
				my $distancemin = $args->{'-to'} - $$minvar; # distance between min slider and maximum
				if ($distancemin < $distance) {
					$$minvar = $$maxvar - $distance;
					return;
				} else {
					$$maxvar = $$minvar + $distance;
				}
			} else {
				$$maxvar = $$minvar if $$minvar > $$maxvar;
			}
			if (($$minvar != $oldmin) || ($$maxvar != $oldmax)) {
				$oldmin = $$minvar;
				$oldmax = $$maxvar;
				&$cmd;
			}
		},
	)->pack;

	# create the subwidget 'max' Scale
	$smax = $cw->Component(
		Scale => 'top',
		%$args,
		-variable => $maxvar,
		-label => $maxlbl,
		-command => sub {
			if ($shifted) {
				my $distance = $oldmax - $oldmin; # distance between sliders
				my $distancemax = $$maxvar - $args->{'-from'}; # distance between minimum and max slider
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
		},
	)->pack;

	$cw->ConfigSpecs (
		DEFAULT => [PASSIVE],
		-variablemin => [$minvar, undef, undef, undef],
		-variablemax => [$maxvar, undef, undef, undef],
	);

	$cw->bind($smin, "<Shift-Button-1>", sub { $shifted = 1; } );
	$cw->bind($smin, "<Shift-ButtonRelease-1>", sub { $shifted = 0; });
	$cw->bind($smin, "<ButtonRelease-1>", sub { $shifted = 0; });
	$cw->bind($smin, "<KeyRelease>", sub { $shifted = 0; });

	$cw->bind($smax, "<Shift-Button-1>", sub { $shifted = 1; } );
	$cw->bind($smax, "<Shift-ButtonRelease-1>", sub { $shifted = 0; });
	$cw->bind($smax, "<ButtonRelease-1>", sub { $shifted = 0; });
	$cw->bind($smax, "<KeyRelease>", sub { $shifted = 0; });

#	this code doesn't function : why?
#	$cw->bind(Tk::Scale, "<Shift-Button-1>", sub { $shifted = 1; } );
#	$cw->bind(Tk::Scale, "<Shift-ButtonRelease-1>", sub { $shifted = 0; });
#	$cw->bind(Tk::Scale, "<ButtonRelease-1>", sub { $shifted = 0; });
#	$cw->bind(Tk::Scale, "<KeyRelease>", sub { $shifted = 0; });
}

sub minvalue {
	my $self = shift;
	my $refval = $self->{ConfigSpecs}->{'-variablemin'}[0];
	return $$refval;
}

sub maxvalue {
	my $self = shift;
	my $refval = $self->{ConfigSpecs}->{'-variablemax'}[0];
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

I<$varmax> = I<$mms>-E<gt>B<maxvalue>;

=head1 DESCRIPTION

Tk::MinMaxScale is a Frame-based widget including two Scale widgets,
the first acting as a "minimum" and the second as a "maximum".
The value of "minimum" is always less than or equal to the value of "maximum".

The purpose of Tk::MinMaxScale is to get a range of values narrower
than the whole Scale range given by the options B<-from> and B<-to>
(applied to both "minimum" and "maximum" Scale).
This is done through the options B<-variablemin> and B<-variablemax>,
or via the methods B<minvalue> and B<maxvalues>, see below.

In addition, dragging a slider while pressing a B<Shift> key drags both sliders,
locking their distance. You must hold down the B<Shift> key before dragging a slider.

=head1 OPTIONS

The widget accept all options accepted by B<Scale> and their default value,
except B<-variable>. In addition, the following option/value pairs are supported:

=over 4

=item B<-labelmin>

The text used as a label for the "minimum" Scale. Default none.

=item B<-labelmax>

The text used as a label for the "maximum" Scale. Default none.

=item B<-variablemin>

A reference to a global variable linked with the "minimum" Scale.

=item B<-variablemax>

A reference to a global variable linked with the "maximum" Scale.

=back

=head1 METHODS

=over 4

=item B<minvalue>

return the value of min scale.

=item B<maxvalue>

return the value of max scale.

=head1 HISTORY

=item B<v0.03> - 2002/11/01

=over 2

=item -

fixed some problems when dragging while depressing shift key

=item -

added methods B<minvalue> and B<maxvalues>

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

- switch to a "one groove, two sliders" scale.

- implement include/exclude bounds

=head1 AUTHOR

Jean-Pierre Vidal, E<lt>jpvidal@cpan.orgE<gt>

This package is free software and is provided "as is"
without express or implied warranty. It may be used, modified,
and redistributed under the same terms as Perl itself.

Feedback would be appreciated in many ways, including corrections to my poor english.

=head1 SEE ALSO

B<Tk::Scale>

=cut
