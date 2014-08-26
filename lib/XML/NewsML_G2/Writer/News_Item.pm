package XML::NewsML_G2::Writer::News_Item;

# $Id$

use Moose;

extends 'XML::NewsML_G2::Writer';

has 'news_item', isa => 'XML::NewsML_G2::News_Item', is => 'ro', required => 1;


sub _build__root_item {
    my $self = shift;
    return $self->news_item;
}

__PACKAGE__->meta->make_immutable;

1;
