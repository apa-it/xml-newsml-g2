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

# TODO [Subroutines::ProhibitExcessComplexity] Subroutine "_create_location" with high complexity score (21)
sub _create_location {    ## no critic (ProhibitExcessComplexity)
    my ( $self, $loc ) = @_;

    my $result = $self->create_element('location');
    $result->appendChild($_)
        foreach ( $self->_create_multilang_elements( 'name', $loc->name ) );
    if ( $loc->has_address_details || $loc->has_position ) {
        $result->appendChild( my $details =
                $self->create_element('POIDetails') );
        if ( $loc->has_position ) {
            $details->appendChild(
                $self->create_element(
                    'position',
                    latitude  => $loc->latitude,
                    longitude => $loc->longitude
                )
            );
        }
        if ( $loc->has_address_details ) {
            $details->appendChild( my $address =
                    $self->create_element('address') );

            if ( $loc->address_line ) {
                $address->appendChild($_) foreach (
                    $self->_create_multilang_elements(
                        'line', $loc->address_line
                    )
                );
            }

            if ( $loc->locality ) {
                $address->appendChild( my $locality =
                        $self->create_element('locality') );
                $locality->appendChild($_) foreach (
                    $self->_create_multilang_elements(
                        'name', $loc->locality
                    )
                );
            }

            if ( $loc->area ) {
                my $qcode;
                if ( my $c = $loc->iso_code_region ) {
                    $qcode = 'iso3166-2:' . $c;
                }
                $address->appendChild( my $area =
                        $self->create_element('area') );
                $area->setAttribute( 'qcode', $qcode ) if $qcode;
                $area->appendChild($_)
                    foreach (
                    $self->_create_multilang_elements( 'name', $loc->area ) );
            }

            if ( $loc->country ) {
                my $qcode;
                if ( my $c = $loc->iso_code ) {
                    if ( length $c == 2 ) {
                        $qcode = 'iso3166-1a2:' . $c;
                    }
                    elsif ( length $c == 3 ) {
                        $qcode = 'iso3166-1a3:' . $c;
                    }
                }
                $address->appendChild( my $country =
                        $self->create_element('country') );
                $country->setAttribute( 'qcode', $qcode ) if $qcode;

                foreach (
                    $self->_create_multilang_elements(
                        'name', $loc->country
                    )
                ) {
                    $country->appendChild($_);
                }
            }

            if ( $loc->postal_code ) {
                $address->appendChild(
                    $self->create_element(
                        'postalCode', _text => $loc->postal_code
                    )
                );

            }
        }
    }

    return $result;
}

sub _create_language {
    my ( $self, $lang ) = @_;

    my $result = $self->create_element('language');
    $result->setAttribute( 'tag', $lang->code ) if ( $lang->code );
    $result->appendChild(
        $self->create_element( 'name', _text => $lang->name ) );

    return $result;
}

sub _format_dt {
    my ( $self, $field ) = @_;

    if ( $self->event_item->allday ) {
        return $self->event_item->$field->ymd('-');
    }
    else {
        return $self->_formatter->format_datetime(
            $self->event_item->$field );
    }
}

sub _create_dates {
    my ($self) = @_;

    my $result = $self->create_element('dates');
    $result->appendChild(
        $self->create_element( 'start', _text => $self->_format_dt('start') )
    );
    if ( $self->event_item->end ) {
        if ( $self->event_item->allday ) {
            my $d0 =
                $self->event_item->start->clone()->set_hour(0)->set_minute(0)
                ->set_second(0);
            my $d1 =
                $self->event_item->end->clone()->set_hour(0)->set_minute(0)
                ->set_second(0);
            my $days = ( $d1 - $d0 )->days;

            $result->appendChild(
                $self->create_element(
                    'duration', _text => ( 'P' . $days . 'D' )
                )
            );
        }
        else {
            $result->appendChild(
                $self->create_element(
                    'end', _text => $self->_format_dt('end')
                )
            );
        }
    }
    return $result;
}

sub _create_coverage {
    my ($self) = @_;

    my $result = $self->create_element('newsCoverageStatus');
    $self->scheme_manager->add_qcode( $result, 'ncostat', 'int' );
    foreach my $cov ( $self->event_item->all_coverage ) {
        $result->appendChild($_)
            foreach $self->_create_multilang_elements( 'name', $cov );
    }
    return $result;
}

sub _create_occurence_status {
    my ($self) = @_;

    my $result = $self->create_element('occurStatus');
    $self->scheme_manager->add_qcode( $result, 'eventoccurstatus',
        $self->event_item->occurence_status );
    return $result;
}

sub _create_inner_content {
    my ( $self, $parent ) = @_;
    $parent->appendChild( $self->doc->createComment('event information') );
    $parent->appendChild($_)
        foreach $self->_create_multilang_elements( 'name',
        $self->event_item->title );

    if ( my $subtitle = $self->event_item->subtitle ) {
        $parent->appendChild($_)
            foreach $self->_create_multilang_elements( 'definition',
            $subtitle, role => 'definitionrole:short' );
    }
    if ( my $summary = $self->event_item->summary ) {
        $parent->appendChild($_)
            foreach $self->_create_multilang_elements( 'definition',
            $summary, role => 'definitionrole:long' );
    }
    foreach my $note ( $self->event_item->all_notes ) {
        $parent->appendChild($_)
            foreach $self->_create_multilang_elements( 'note',
            $note->text, role => $note->role );
    }
    $parent->appendChild( my $details =
            $self->create_element('eventDetails') );
    $details->appendChild( $self->doc->createComment('dates') );
    $details->appendChild( $self->_create_dates() );
    if ( $self->event_item->has_coverage ) {
        $details->appendChild( $self->doc->createComment('coverage') );
        $details->appendChild( $self->_create_coverage() );
    }
    if ( $self->event_item->occurence_status ) {
        $details->appendChild(
            $self->doc->createComment('occurence status') );
        $details->appendChild( $self->_create_occurence_status() );
    }
    $details->appendChild( $self->doc->createComment('location') );
    $details->appendChild( $self->_create_location($_) )
        foreach ( $self->event_item->all_locations );

    $details->appendChild( $self->doc->createComment('language') );
    $details->appendChild( $self->_create_language($_) )
        foreach ( $self->event_item->all_languages );

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
