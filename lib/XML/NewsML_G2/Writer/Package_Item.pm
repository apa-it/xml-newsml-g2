package XML::NewsML_G2::Writer::Package_Item;

# $Id$

use Moose;

extends 'XML::NewsML_G2::Writer';

has 'package_item', isa => 'XML::NewsML_G2::Package_Item', is => 'ro', required => 1;
has '+_root_node_name', default => 'packageItem';

sub _build__root_item {
    my $self = shift;
    return $self->package_item;
}

sub _create_rights_info {
}

sub _create_content_meta {
}

sub _create_content {
}

__PACKAGE__->meta->make_immutable;

1;
