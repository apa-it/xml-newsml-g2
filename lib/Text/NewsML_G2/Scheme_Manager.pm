package Text::NewsML_G2::Scheme_Manager;

# $Id$

use Moose;
use namespace::autoclean;


foreach (qw(desk hltype svc)) {
    has $_, isa => 'Text::NewsML_G2::Scheme', is => 'ro', required => 1;

}

foreach (qw(role ind geo org topic crel)) {
    has $_, isa => 'Text::NewsML_G2::Scheme', is => 'ro';

}

sub get_all_schemes {
    my $self = shift;

    return map {$self->can($_)->($self)} sort $self->meta->get_attribute_list();
}

__PACKAGE__->meta->make_immutable;

1;
