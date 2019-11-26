package XML::NewsML_G2::Writer::Event_Item;

use Moose;
use Carp;
use namespace::autoclean;

extends 'XML::NewsML_G2::Writer::Concept_Item';

has 'event_item',
    isa      => 'XML::NewsML_G2::Event_Item',
    is       => 'ro',
    required => 1;

sub _build__root_item {
    my $self = shift;
    return $self->event_item;
}

sub _create_id_element {
    my ($self) = @_;

    my $result = $self->create_element('conceptId');
    $self->scheme_manager->add_qcode( $result, 'eventid',
        $self->event_item->event_id );
    return $result;
}

sub _create_type_element {
    my ($self) = @_;

    my $result = $self->create_element( 'type', qcode => 'cpnat:event' );
    return $result;
}

sub _create_inner_content {
    my ( $self, $parent ) = @_;

    $parent->appendChild(
        $self->create_element( 'name', _text => $self->event_item->title ) );
    if ( $self->event_item->subtitle ) {
        $parent->appendChild(
            $self->create_element(
                'definition',
                role  => 'definitionrole:short',
                _text => $self->event_item->subtitle
            )
        );
    }
    if ( $self->event_item->summary ) {
        $parent->appendChild(
            $self->create_element(
                'definition',
                role  => 'definitionrole:long',
                _text => $self->event_item->summary
            )
        );
    }
    return;
}

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 NAME

XML::NewsML_G2::Writer::Event_Item - create DOM tree conforming to
NewsML-G2 for Event Concept Items

=for test_synopsis
    my ($ei, $sm);

=head1 SYNOPSIS

    my $w = XML::NewsML_G2::Writer::Event_Item->new
        (event_item => $ei, scheme_manager => $sm);

    my $dom = $w->create_dom();

=head1 DESCRIPTION

This module implements the creation of a DOM tree conforming to
NewsML-G2 for Event Concept Items.  Depending on the version of the standard
specified, a version-dependent role will be applied. For the API of
this module, see the documentation of the superclass L<XML::NewsML_G2::Writer>.

=head1 ATTRIBUTES

=over 4

=item event_item

L<XML::NewsML_G2::Event_Item> instance used to create the output document

=back

=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2019, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
