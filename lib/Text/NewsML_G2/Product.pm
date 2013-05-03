package Text::NewsML_G2::Product;

# $Id$

use Moose;
use namespace::autoclean;


has 'name', isa => 'Str', is => 'ro', lazy_build => 1;
has 'isbn', isa => 'Str', is => 'rw';
has 'ean', isa => 'Str', is => 'rw';
has 'name_template', isa => 'Str', is => 'ro', default => 'Product %d';

{
    my $product_count = 0;
    sub _build_name {
        my $self = shift;
        return sprintf $self->name_template, ++$product_count;
    }
}

__PACKAGE__->meta->make_immutable;

1;
