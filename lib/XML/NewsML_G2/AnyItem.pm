package XML::NewsML_G2::AnyItem;

use Moose;
use namespace::autoclean;

use UUID::Tiny;
use XML::NewsML_G2::Types;
use XML::NewsML_G2::Link;

has 'guid', isa => 'Str', is => 'ro', lazy => 1, builder => '_build_guid';
has 'doc_version', isa => 'Int', is => 'ro', default  => '1';
has 'language',    isa => 'Str', is => 'ro', required => 1;
has 'nature',
    isa      => 'XML::NewsML_G2::Types::Nature',
    is       => 'ro',
    required => 1;
has 'provider', isa => 'XML::NewsML_G2::Provider', is => 'ro', required => 1;
has 'copyright_holder', isa => 'XML::NewsML_G2::Copyright_Holder', is => 'ro';
has 'usage_terms', isa => 'Str', is => 'rw';

has 'service',
    isa       => 'XML::NewsML_G2::Service',
    is        => 'ro',
    predicate => 'has_service';
has 'doc_status', isa => 'Str', is => 'ro', default => 'usable';

has 'note',    isa => 'Str', is => 'ro';
has 'closing', isa => 'Str', is => 'rw';

has 'see_also',
    isa     => 'ArrayRef[XML::NewsML_G2::Link]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_see_also => 'push' };
has 'derived_from',
    isa     => 'ArrayRef[XML::NewsML_G2::Link]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_derived_from => 'push' };

has 'embargo',      isa => 'DateTime', is => 'rw';
has 'embargo_text', isa => 'Str',      is => 'rw';

has 'indicators',
    isa     => 'ArrayRef[Str]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_indicator => 'push' };

sub _build_guid {
    return UUID::Tiny::create_uuid_as_string();
}

sub add_see_also_str {
    my ( $self, $str ) = @_;
    return unless $str;
    $self->add_see_also( XML::NewsML_G2::Link->new( residref => $str ) );
    return 1;
}

sub add_derived_from_str {
    my ( $self, $str ) = @_;
    return unless $str;
    $self->add_derived_from( XML::NewsML_G2::Link->new( residref => $str ) );
    return 1;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::AnyItem - base class for news and package items

=head1 DESCRIPTION

This module acts as a base class for NewsML-G2 news items and package
items. For a documentation of the attributes it provides, please see
L<XML::NewsML_G2::News_Item>.

=head1 METHODS

=over 4

=item add_see_also_str

adds a new Link element of type 'see also' with a given string

=item  add_derived_from_str

adds a new Link element of type 'derived from' with a given string

=back

Add a string to the authors

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2014-2015, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
