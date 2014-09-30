package XML::NewsML_G2::Role::Writer::Package_Item;

# $Id$

use Moose::Role;
use namespace::autoclean;

with 'XML::NewsML_G2::Role::Writer';

around '_build_g2_catalog_schemes' => sub {
    my ( $orig, $self, @args ) = @_;
    my $result = $self->$orig(@args);
    $result->{group} = undef;
    return $result;
};


1;
