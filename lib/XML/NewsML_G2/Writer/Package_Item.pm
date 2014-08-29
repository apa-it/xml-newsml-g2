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
    my ($self, $root) = @_;
    my $main_id = 'root_group';

    $root->appendChild(my $gs = $self->create_element('groupSet', root => $main_id));

    $gs->appendChild(my $group = $self->create_element('group', id => $main_id)); ### XXX role

    foreach my $item (@{$self->package_item->root_group->items}) {
        ## if $item->isa("group") -> recursive call

        $group->appendChild(my $child = $self->create_element('itemRef', residref => $item->guid, version => $item->doc_version));
        $child->appendChild(my $ic = $self->create_element('itemClass'));
        $self->scheme_manager->add_qcode($ic, 'ninat', $item->nature);
        $child->appendChild($self->create_element('title', _text => $item->title));

    }

    return;
}

__PACKAGE__->meta->make_immutable;

1;
