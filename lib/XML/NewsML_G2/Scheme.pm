package XML::NewsML_G2::Scheme;

# $Id$

use Moose;
use namespace::autoclean;


has 'alias', isa => 'Str', is => 'ro', required => 1;
has 'uri', isa => 'Str', is => 'ro', required => 1;

__PACKAGE__->meta->make_immutable;

1;
