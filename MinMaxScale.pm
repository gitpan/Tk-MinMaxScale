package Tk::MinMaxScale;
use Carp;
use Tk;
#use warnings; #################### fot tests ################################
#use Data::Dumper; ################ for tests ################################

@ISA = qw(Tk::Frame);

$VERSION = '0.09';

Construct Tk::Widget 'MinMaxScale';

my $shifted; # is Shift-Key pressed ?

sub Populate {
	my ($cw, $args) = @_;
	$cw->SUPER::Populate($args);

	my $pn = __PACKAGE__;
	delete $args->{'-variable'} && carp("$pn warning: option \"-variable\" not allowed");

	# let's make the widget horizontal unless defined other specs
	$cw->{mms}{'orient'} = delete $args->{'-orient'};
	$cw->{mms}{'orient'} = 'horizontal' unless defined $cw->{mms}{'orient'};
	my $sideforpack = $cw->{mms}{'orient'} eq 'vertical' ? 'left' : 'top';

	$cw->{mms}{'command'} = delete $args->{'-command'};
	$cw->{mms}{'command'} = sub {} unless defined $cw->{mms}{'command'};

	$cw->{mms}{'from'} = delete $args->{'-from'};
	$cw->{mms}{'from'} = 0 unless defined $cw->{mms}{'from'};
	$cw->{mms}{'to'} = delete $args->{'-to'};
	$cw->{mms}{'to'} = 100 unless defined $cw->{mms}{'to'};

	$cw->{mms}{'variablemin'} = delete $args->{'-variablemin'};
	if (!defined $cw->{mms}{'variablemin'}) {
		$cw->{mms}{'variablemin'} = \$cw->{mms}{'valeurmin'};
		$cw->{mms}{'valeurmin'} = $cw->{mms}{'from'};
	}
	$cw->{mms}{'oldmin'} = ${$cw->{mms}{'variablemin'}};

	$cw->{mms}{'variablemax'} = delete $args->{'-variablemax'};
	if (!defined $cw->{mms}{'variablemax'}) {
		$cw->{mms}{'variablemax'} = \$cw->{mms}{'valeurmax'};
		$cw->{mms}{'valeurmax'} = $cw->{mms}{'to'};
	}
	$cw->{mms}{'oldmax'} = ${$cw->{mms}{'variablemax'}};

	$cw->{mms}{'labelmin'} = delete $args->{'-labelmin'};
	$cw->{mms}{'labelmax'} = delete $args->{'-labelmax'};

	# create the subwidget 'min' Scale
	my $smin = $cw->Scale(
		%$args,
		-variable => $cw->{mms}{'variablemin'},
		-label => $cw->{mms}{'labelmin'},
		-orient => $cw->{mms}{'orient'},
		-from => $cw->{mms}{'from'},
		-to => $cw->{mms}{'to'},
		-command => sub {
			my $oldmin = $cw->{mms}{'oldmin'};
			my $oldmax = $cw->{mms}{'oldmax'};
			my $valmin = ${$cw->{mms}{'variablemin'}};
			my $valmax = ${$cw->{mms}{'variablemax'}};
			my $to = $cw->{mms}{'to'};
			if ($shifted) {
				my $distance = $oldmax - $oldmin; # distance between sliders
				my $distancemin = $to - $valmin; # distance between min slider and maximum
				if ($distancemin < $distance) {
					${$cw->{mms}{'variablemin'}} = $valmax - $distance;
					return;
				} else {
					${$cw->{mms}{'variablemax'}} = $valmin + $distance;
				}
			} else {
				${$cw->{mms}{'variablemax'}} = $valmin  if $valmin > $valmax;
			}
			$cw->{mms}{'oldmin'} = ${$cw->{mms}{'variablemin'}};
			$cw->{mms}{'oldmax'} = ${$cw->{mms}{'variablemax'}};
			my $cmd = $cw->{mms}{'command'};
			&$cmd;
		},
	)->pack(-side => $sideforpack);
	$cw->Advertise('smin' => $smin);

	# create the subwidget 'max' Scale
	my $smax = $cw->Scale(
		%$args,
		-variable => $cw->{mms}{'variablemax'},
		-label => $cw->{mms}{'labelmax'},
		-orient => $cw->{mms}{'orient'},
		-from => $cw->{mms}{'from'},
		-to => $cw->{mms}{'to'},
		-command => sub {
			my $oldmin = $cw->{mms}{'oldmin'};
			my $oldmax = $cw->{mms}{'oldmax'};
			my $valmin = ${$cw->{mms}{'variablemin'}};
			my $valmax = ${$cw->{mms}{'variablemax'}};
			my $from = $cw->{mms}{'from'};
			if ($shifted) {
				my $distance = $oldmax - $oldmin; # distance between sliders
				my $distancemax = $valmax - $from; # distance between minimum and max slider
				if ($distancemax < $distance) {
					${$cw->{mms}{'variablemax'}} = $valmin + $distance;
					return;
				} else {
					${$cw->{mms}{'variablemin'}} = $valmax - $distance;
				}
			} else {
				${$cw->{mms}{'variablemin'}} = $valmax if $valmax < $valmin;
			}
			$cw->{mms}{'oldmin'} = ${$cw->{mms}{'variablemin'}};
			$cw->{mms}{'oldmax'} = ${$cw->{mms}{'variablemax'}};
			my $cmd = $cw->{mms}{'command'};
			&$cmd;
		},
	)->pack(-side => $sideforpack);
	$cw->Advertise('smax' => $smax);

	$cw->toplevel->bind("<Key>", [ \&is_shift_key, Ev('s'), Ev('K') ] );
	$cw->toplevel->bind("<KeyRelease>", [ \&is_shift_key, Ev('s'), Ev('K') ] );

	$cw->ConfigSpecs (
		-from => 		[METHOD, undef, undef, 0],
		-to => 			[METHOD, undef, undef, 100],
		-variablemin => [METHOD, undef, undef, undef],
		-variablemax => [METHOD, undef, undef, undef],
		-labelmin => 	[METHOD, undef, undef, undef],
		-labelmax => 	[METHOD, undef, undef, undef],
		-orient => 		[METHOD, undef, undef, 'horizontal'],
		-command =>     [METHOD, undef, undef, undef],
		DEFAULT => 		[[$smin, $smax], undef, undef, undef],
	);
}

sub command {
	my ($cw, $val) = @_;
	$cw->{mms}{'command'} = $val if $val;
}

sub orient {
	my ($cw, $val) = @_;
	if ($val) {
		$cw->{mms}{'orient'} = $val;
		my $sideforpack = $val eq 'vertical' ? 'left' : 'top';
		$cw->Subwidget('smin')->configure(-orient => $val);
		$cw->Subwidget('smin')->pack(-side => $sideforpack);
		$cw->Subwidget('smax')->configure(-orient => $val);
		$cw->Subwidget('smax')->pack(-side => $sideforpack);
	}
	return $cw->{mms}{'orient'};
}

sub labelmin {
	my ($cw, $val) = @_;
	if ($val) {
		$cw->{mms}{'labelmin'} = $val;
		$cw->Subwidget('smin')->configure(-label => $val);
	}
	return $cw->{mms}{'labelmin'};
}

sub labelmax {
	my ($cw, $val) = @_;
	if ($val) {
		$cw->{mms}{'labelmax'} = $val;
		$cw->Subwidget('smax')->configure(-label => $val);
	}
	return $cw->{mms}{'labelmax'};
}

sub variablemin {
	my ($cw, $val) = @_;
	if ( ($val) && ($val != $cw->{mms}{'variablemin'}) ) {
		$cw->{mms}{'variablemin'} = $val;
		my $scale = $cw->Subwidget('smin');
		$scale->configure(-variable => $val);
	}
	return $cw->{mms}{'variablemin'};
}

sub variablemax {
	my ($cw, $val) = @_;
	if ( ($val) && ($val != $cw->{mms}{'variablemax'}) ) {
		$cw->{mms}{'variablemax'} = $val;
		my $scale = $cw->Subwidget('smax');
		$scale->configure(-variable => $val);
	}
	return $cw->{mms}{'variablemax'};
}

sub from {
	my ($cw, $val) = @_;
	if ( ($val) && ($val <= $cw->{mms}{'to'}) ) {
		$cw->{mms}{'from'} = $val;
		my $scale = $cw->Subwidget('smin');
		$scale->configure(-from => $val);
		$scale = $cw->Subwidget('smax');
		$scale->configure(-from => $val);
	}
	return $cw->{mms}{'from'};
}

sub to {
	my ($cw, $val) = @_;
	if ( ($val) && ($val >= $cw->{mms}{'from'}) ) {
		$cw->{mms}{'to'} = $val;
		my $scale = $cw->Subwidget('smin');
		$scale->configure(-to => $val);
		$scale = $cw->Subwidget('smax');
		$scale->configure(-to => $val);
	}
	return $cw->{mms}{'to'};
}

sub is_shift_key {
	$shifted = ($_[1] =~ /^Shift/) && ($_[2] =~ /^Shift/) ? 0 : 1;
}

sub minvalue {
	my $cw = shift;
	my $refval = $cw->{mms}{'variablemin'};
	$$refval = shift if @_;
	$cw->{mms}{'oldmin'} = $$refval;
	return $$refval;
}

sub maxvalue {
	my $cw = shift;
	my $refval = $cw->{mms}{'variablemax'};
	$$refval = shift if @_;
	$cw->{mms}{'oldmax'} = $$refval;
	return $$refval;
}

1;

__END__

=head1 NAME

Tk::MinMaxScale - Two B<Scale> to get a (min, max) pair of values

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

Tk::MinMaxScale is a Frame-based widget wrapping two B<Scale> widgets,
the first acting as a 'minimum' and the second as a 'maximum'.
The value of the 'minimum' B<Scale> is always less than or equal to
the value of the 'maximum' B<Scale>.

The purpose of Tk::MinMaxScale is to get a range of values narrower
than the whole range given by the options B<-from> and B<-to>
(who are applied to both 'minimum' and 'maximum' Scale).
This is done through the variables associated to the options B<-variablemin>
and B<-variablemax>, or via the methods B<minvalue> and B<maxvalues>, see below.

In addition, dragging a slider while pressing a B<Shift> key drags both sliders,
locking their distance. You must hold down the B<Shift> key before dragging a slider.

=head1 OPTIONS

The widget accepts all options accepted by B<Scale> (except B<-variable> option),
and their default value (exception: option B<-orient> defaults to 'horizontal').

In addition, the following option/value pairs are supported, but not required:

=item B<-labelmin>

The text used as a label for the 'minimum' Scale. Default none.

=item B<-labelmax>

The text used as a label for the 'maximum' Scale. Default none.

=item B<-variablemin>

A reference to a global variable linked with the 'minimum' Scale.

=item B<-variablemax>

A reference to a global variable linked with the 'maximum' Scale.

All other options are applied to both 'min' and 'max' Scale(s).

=head1 METHODS

The MinMaxScale method creates a widget object. This object supports the configure
and cget methods described in Tk::options which can be used to enquire and modify
the options described above.
The widget also inherits all the methods provided by the generic Tk::Widget class.

The following additional methods are available for MinMaxScale widgets:

=item I<$mms>->B<minvalue>(?I<value>?)

Sets the 'min' Scale of the widget to I<value>, if any
(limited by 'B<-from>' value and the 'max' Scale value).
Returns the value of the 'min' Scale.

=item I<$mms>->B<maxvalue>(?I<value>?)

Sets the 'max' Scale of the widget to I<value>, if any
(limited by the 'min' Scale value and 'B<-to>' values).
Returns the value of the 'max' Scale.

=head1 HISTORY

=item B<v0.09> - 2004/01/31

=item -
configure and cget methods implemented.

=item B<v0.08> - 2004/01/04

=item -
compatibility with Tk804.xxx (dash before option).

=item B<v0.07> - 2002/11/21

=item -
added tests.

=item B<v0.06> - 2002/11/20

=item -
dropped "use warnings" and "use diagnostics".

=item -
cleaned up the distribution package.

=item B<v0.05> - 2002/11/05

=item -
unlike Scale, 'B<-orient>' option defaults now to 'horizontal'.

=item -
like Scale, 'B<-from>' and 'B<-to>' options defaults now to 0 and 100, respectively.

=item -
definitely (:() fixed Shift-key binding problems.

=item B<v0.04> - 2002/11/01

=item -
enhanced methods B<minvalue> and B<maxvalue> to set|get the scale values.

=item B<v0.03> - 2002/11/01

=item -
fixed some problems when dragging while depressing shift key

=item -
added methods B<minvalue> and B<maxvalue>

=item B<v0.02> - 2002/10/24

=item -
new feature added: dragging a slider while pressing a B<Shift> key
drags both sliders, locking their distance (an idea from Mark Lakata).

=item B<v0.01> - 2002/10/17

=item -
first release.

=head1 TODO

=item -
switch to a 'one groove, two sliders' scale : I think it is not a so good idea.

=item -
make some test programs.

=head1 AUTHOR & LICENSE

Jean-Pierre Vidal, E<lt>jeanpierre.vidal@free.frE<gt>

Feedback would be greatly appreciated, including corrections to my poor english.

This package is free software and is provided 'as is'
without express or implied warranty. It may be used, modified,
and redistributed under the same terms as Perl itself.

=head1 SEE ALSO

B<Tk::Scale>

=cut
