package XML::NewsML_G2::Package_Item;

# $Id$

use Moose;
use namespace::autoclean;

extends 'XML::NewsML_G2::AnyItem';

has '+nature', default => 'composite';
has 'root_group', isa => 'XML::NewsML_G2::Group', is => 'ro', lazy => 1, builder => '_build_root_group';

sub _build_sent {
    return DateTime->now(time_zone => 'local');
}

sub _build_root_group {
    my $self = shift;
    return XML::NewsML_G2::Group->new();
}

sub add_to_root_group {
    my ($self, @items) = @_;
    $self->root_group->add_items(@items);
}

__PACKAGE__->meta->make_immutable;

1;
