package Text::NewsML_G2::Location;

# $Id$

use Moose;
use namespace::autoclean;


has 'name', isa => 'Str', is => 'ro', required => 1;
has 'qcode', isa => 'Str', is => 'ro', required => 1;
has 'relevance', isa => 'Int', is => 'ro', required => 1;
has 'parent', isa => __PACKAGE__, is => 'rw';
has 'direct', isa => 'Bool', is => 'rw', default => '';
has 'iso_code', isa => 'Str', is => 'rw';

__PACKAGE__->meta->make_immutable;

1;
