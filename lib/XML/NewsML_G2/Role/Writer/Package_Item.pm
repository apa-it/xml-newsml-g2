package XML::NewsML_G2::Role::Writer::Package_Item;

# $Id$

use Moose::Role;
use namespace::autoclean;

with 'XML::NewsML_G2::Role::Writer';

sub _set_item_class {
    my ($self, $ic) = @_;
    $self->scheme_manager->add_qcode($ic, 'ninat', 'composite');
};


1;
