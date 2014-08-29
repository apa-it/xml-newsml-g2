package XML::NewsML_G2::AnyItem;

# $Id$

use Moose;
use namespace::autoclean;

use UUID::Tiny ':std';
use XML::NewsML_G2::Types;

has 'guid', isa => 'Str', is => 'ro', lazy => 1, builder => '_build_guid';
has 'doc_version', isa => 'Int', is => 'ro', default => '1';
has 'language', isa => 'Str', is => 'ro', required => 1;
has 'nature', isa => 'XML::NewsML_G2::Types::Nature', is => 'ro', required => 1;
has 'provider', isa => 'XML::NewsML_G2::Provider', is => 'ro', required => 1;
has 'usage_terms', isa => 'Str', is => 'rw';

has 'service', isa => 'XML::NewsML_G2::Service', is => 'ro', predicate => 'has_service';
has 'doc_status', isa => 'Str', is => 'ro', default => 'usable';

has 'note', isa => 'Str', is => 'ro';
has 'closing', isa => 'Str', is => 'rw';
has 'see_also', isa => 'Str', is => 'rw';

has 'embargo', isa => 'DateTime', is => 'rw';
has 'embargo_text', isa => 'Str', is => 'rw';

has 'indicators', isa => 'ArrayRef[Str]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_indicator => 'push'};

sub _build_guid {
    return create_uuid_as_string();
}

__PACKAGE__->meta->make_immutable;

1;
