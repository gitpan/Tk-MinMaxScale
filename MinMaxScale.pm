package Tk::MinMaxScale;
use warnings;
use Tk;
use Carp;
use base qw(Tk::Toplevel);
use Tk::widgets qw(Frame Scale);
@ISA = qw(Tk::Frame);

our $VERSION = '0.01';

Construct Tk::Widget 'MinMaxScale';

sub Populate {
	my ($minvar, $oldmin, $maxvar, $oldmax, $cmd);
	my ($cw, $args) = @_;
	$cw->SUPER::Populate($args);

	delete $args->{'-variable'} && carp('Tk::MinMaxScale warning: option "-variable" not allowed');

	$minvar = delete $args->{'-variablemin'};
	$maxvar = delete $args->{'-variablemax'};

	($oldmin, $oldmax) = ($$minvar, $$maxvar);

	my $minlbl = delete $args->{'-labelmin'};
	my $maxlbl = delete $args->{'-labelmax'};

	$cmd = delete $args->{'-command'};

	# create the subwidget 'min' Scale
	my $smin = $cw->Scale(
		%$args,
		-variable => $minvar,
		-label => $minlbl,
		-command => sub {
			$$maxvar = $$minvar if $$minvar > $$maxvar;
			if (($$minvar != $oldmin) || ($$maxvar != $oldmax)) {
				$oldmin = $$minvar;
				$oldmax = $$maxvar;
				&$cmd;
			}
		},
	)->pack;

	# create the subwidget 'max' Scale
	my $smax = $cw->Scale(
		%$args,
		-variable => $maxvar,
		-label => $maxlbl,
		-command => sub {
			$$minvar = $$maxvar if $$maxvar < $$minvar;
			if (($$minvar != $oldmin) || ($$maxvar != $oldmax)) {
				$oldmin = $$minvar;
				$oldmax = $$maxvar;
				&$cmd;
			}
		},
	)->pack;

	$cw->ConfigSpecs (
		DEFAULT => [PASSIVE],
	);
}

1;

__END__

=head1 NAME

Tk::MinMaxScale - Two Scale(s) to get a (min, max) values pair

=head1 SYNOPSIS

	I<$range> = I<$parent>-E<gt>B<MinMaxScale>(I<-option> =E<gt> I<value>, ... );

=head1 DESCRIPTION

Tk::MinMaxScale is a Frame-based widget including two Scale widgets, the first
acting as a "minimum" and the second as a "maximum", the value of the first always
less than or equal to the value of the second.
The purpose of MinMaxScale is to retrieve a range of values narrower than the whole Scale range
given by the Scale options '-from' and '-to' applied to both "minimum" and "maximum" Scale.
This is done through the "Scale variable" -variablemin and -variablemax.

The widget accept all options accepted by Scale, except -variable.

In addition, the following option/value pairs are supported:

=item B<-labelmin>

The text used as a label for the "minimum" Scale. Default none.

=item B<-labelmax>

The text used as a label for the "maximum" Scale Default none..

=item B<-variablemin>

The name of a global variable to link to the "minimum" Scale.

=item B<-variablemax>

The name of a global variable to link to the "maximum" Scale.

=head2 EXPORT

None.

=head1 METHODS

At this time, there is no method provided for this widget.

=head1 HISTORY

version 0.01 2002/10/17 first release.

=head1 TODO

- switch to a "one groove, two sliders" scale.

- implement include/exclude bounds

=head1 AUTHOR

Jean-Pierre Vidal, E<lt>jpvidal@cpan.orgE<gt>

This package is free software and is provided "as is"
without express or implied warranty. It may be used, modified,
and redistributed under the same terms as Perl itself.

=head1 SEE ALSO

L<Tk::Scale>.

=cut
