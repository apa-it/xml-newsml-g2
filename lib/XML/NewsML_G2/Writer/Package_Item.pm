package XML::NewsML_G2::Writer::Package_Item;

# $Id$

use Moose;

extends 'XML::NewsML_G2::Writer';

has 'package_item', isa => 'XML::NewsML_G2::Package_Item', is => 'ro', required => 1;
has '+_root_node_name', default => 'packageItem';
has '_group_id', isa => 'Num', is => 'rw', default => 0, traits  => ['Counter'], handles => {_next_group_id => 'inc'};

sub _build__root_item {
    my $self = shift;
    return $self->package_item;
}

#sub BUILD {
#    my $self = shift;
#    my $test_group = $self->scheme_manager->build_qcode('group', 'test');
#    die 'You need to register a scheme for groups' unless $test_group;
#}


sub _create_item_meta_title {
    my ($self, $im) = @_;
    my $t = $self->package_item->title;
    $im->appendChild($self->create_element('title', _text => $t)) if $t;
    return;
}

sub _create_rights_info {
}

sub _create_content_meta {
}

sub _create_group {
    my ($self, $parent, $group, $id) = @_;

    $parent->appendChild(
        my $result = $self->create_element('group', id => $id));
    $self->scheme_manager->add_role($result, 'group', $group->role);

    if ($group->mode ne 'bag') {
        my ($mode) = $group->mode =~ /^(...)/;
        my $qcode = $self->scheme_manager->build_qcode('pgrmod', $mode);
        $result->setAttribute('mode', $qcode) if $qcode;
    }

    foreach my $item (@{$group->items}) {
        if ($item->isa('XML::NewsML_G2::Group')) {
            my $group_id = "group_" . $self->_next_group_id();

            $result->appendChild(
                my $child = $self->create_element(
                    'groupRef', idref => $group_id));
            $self->_create_group($parent, $item, $group_id);

        } else { # it's a News_Item
            $result->appendChild(
                my $child = $self->create_element(
                    'itemRef', residref => $item->guid,
                    version => $item->doc_version));
            $child->appendChild(
                my $ic = $self->create_element('itemClass'));
            $self->scheme_manager->add_qcode($ic, 'ninat', $item->nature);
            $child->appendChild($self->create_element('title', _text => $item->title));
        }
    }
}

sub _create_content {
    my ($self, $root) = @_;
    my $main_id = $self->package_item->root_id;

    $root->appendChild(
        my $gs = $self->create_element('groupSet', root => $main_id));

    $self->_create_group($gs, $self->package_item->root_group, $main_id);
    return;
}

__PACKAGE__->meta->make_immutable;

1;
