package Text::NewsML_G2::Organisation;

# $Id$

use Moose;
use namespace::autoclean;

our ($VERSION) = ' $Id$ ' =~ /\s(\d+)\s/;

has 'name', isa => 'Str', is => 'ro', required => 1;
has 'qcode', isa => 'Str', is => 'ro', required => 1;
has 'isins', isa => 'ArrayRef[Str]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_isin => 'push'};
has 'websites', isa => 'ArrayRef[Str]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_website => 'push', has_websites => 'count'};
has 'indices', isa => 'ArrayRef[Str]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_index => 'push'};
has 'stock_exchanges', isa => 'ArrayRef[Str]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_stock_exchange => 'push'};

__PACKAGE__->meta->make_immutable;

1;
