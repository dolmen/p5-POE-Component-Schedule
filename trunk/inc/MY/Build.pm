use strict;
package inc::MY::Build;
use Module::Build;
our @ISA;
BEGIN {
    push @ISA, 'Module::Build';
}


sub ACTION_distmeta
{
    my $self = shift;
    $self->SUPER::depends_on('distrss');
    $self->SUPER::ACTION_distmeta;
}


# Override 'dist' to force a 'distcheck'
# (this is unfortunately not the default in M::B, which means it let you build
#  and distribute a distribution which has an incorrect MANIFEST and lacks some
#  files)
sub ACTION_dist
{
    my $self = shift;
    $self->SUPER::depends_on('distcheck');
    $self->SUPER::ACTION_dist;
}

=head1 ACTIONS

=over 4

=item distrss

Creates 'Changes.rss' and 'Changes.yml' from 'Changes'.

=back

=cut

sub ACTION_distrss
{
    my $self = shift;
    $self->do_create_Changes_RSS;
}


sub do_create_Changes_RSS
{
    my $self = shift;

    print "Creating Changes.{rss,yml}\n";

    my %deps = (
	'DateTime' => '0.53',
	'Regexp::Grammars' => '1.002',
	'Data::Recursive::Encode' => '0.03',
	'DateTime::Format::W3CDTF' => '0.04',
	'YAML' => '0.71',
	'XML::RSS' => '1.47',
	#'Toto' => '3',
    );

    my $ok = 1;
    while (my ($mod, $ver) = each %deps) {
	unless ($self->check_installed_version($mod, $ver)) {
	    $self->log_warn("missing module $mod $ver");
	    $ok = 0;
	}
    }
    die "Can't build Changes.{rss,yml}" unless $ok;


    #system $^X $^X, 'make-Changes-rss-2.pl';
    require inc::MY::Build::Changes;
    inc::MY::Build::Changes->build(dist_name => $self->dist_name);
}


1;
__END__
