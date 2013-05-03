package Text::NewsML_G2::Desk;

# $Id$

use Moose;
use utf8;
use namespace::autoclean;


has 'name', isa => 'Str', is => 'ro', required => 1;
has 'qcode', isa => 'Str', is => 'ro', required => 1;

__PACKAGE__->meta->make_immutable;

1;
