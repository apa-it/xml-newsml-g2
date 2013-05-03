package Text::NewsML_G2::Media_Topic;

# $Id$

use Moose;
use namespace::autoclean;


has 'name', isa => 'Str', is => 'ro', required => 1;
has 'qcode', isa => 'Str', is => 'ro', required => 1;
has 'translations', isa => 'HashRef', is => 'rw', default => sub { {} }, traits => ['Hash'],
  handles => {add_translation => 'set'};
has 'parent', isa => __PACKAGE__, is => 'rw';
has 'direct', isa => 'Bool', is => 'rw', default => '';

__PACKAGE__->meta->make_immutable;

1;
