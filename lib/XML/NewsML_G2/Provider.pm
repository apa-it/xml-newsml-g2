package XML::NewsML_G2::Provider;

# $Id$

use Moose;
use namespace::autoclean;


has 'name', isa => 'Str', is => 'ro', required => 1;
has 'qcode', isa => 'Str', is => 'ro', required => 1;
has 'notice', isa => 'Str', is => 'ro';

__PACKAGE__->meta->make_immutable;

1;
