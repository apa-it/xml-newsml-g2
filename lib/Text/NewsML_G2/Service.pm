package Text::NewsML_G2::Service;

# $Id$

use Moose;
use namespace::autoclean;

our ($VERSION) = ' $Id$ ' =~ /\s(\d+)\s/;

has 'name', isa => 'Str', is => 'ro', required => 1;
has 'qcode', isa => 'Str', is => 'ro', required => 1;

__PACKAGE__->meta->make_immutable;

1;
