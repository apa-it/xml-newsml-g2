package XML::NewsML_G2::Group;

# $Id$

use Moose;

has 'items', isa => 'ArrayRef', is => 'ro', default => sub {[]},
    traits => ['Array'], handles => {add_item => 'push', add_items => 'push'};


__PACKAGE__->meta->make_immutable;

1;
