package XML::NewsML_G2::Event_Item;

use Moose;
use namespace::autoclean;

extends 'XML::NewsML_G2::Concept_Item';

has '+title',    isa => 'XML::NewsML_G2::Translatable_Text', coerce => 1;
has '+subtitle', isa => 'XML::NewsML_G2::Translatable_Text', coerce => 1;
has '+summary',  isa => 'XML::NewsML_G2::Translatable_Text', coerce => 1;

has 'event_id', is => 'ro', isa => 'Str', required => 1;
has 'event_notes',
    is      => 'ro',
    isa     => 'ArrayRef[XML::NewsML_G2::Event_Note]',
    default => sub { [] },
    traits  => [qw/Array/],
    handles => { add_note => 'push', all_notes => 'elements' };
has 'locations',
    is      => 'ro',
    isa     => 'ArrayRef[XML::NewsML_G2::Location]',
    default => sub { [] },
    traits  => [qw/Array/],
    handles => { add_location => 'push', all_locations => 'elements' };
has 'start',  is => 'ro', isa => 'DateTime', required => 1;
has 'end',    is => 'ro', isa => 'DateTime';
has 'allday', is => 'ro', isa => 'Bool',     default  => 0;
has 'languages',
    is      => 'ro',
    is      => 'ro',
    isa     => 'ArrayRef[XML::NewsML_G2::Language]',
    default => sub { [] },
    traits  => [qw/Array/],
    handles => { add_language => 'push', all_languages => 'elements' };
has 'coverages',
    is      => 'ro',
    isa     => 'ArrayRef[Str]',
    default => sub { [] },
    traits  => [qw/Array/],
    handles => {
    add_coverage => 'push',
    has_coverage => 'count',
    all_coverage => 'elements'
    };

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::Event_Item - an event as concept item

=head1 SYNOPSIS

    my $event = XML::NewsML_G2::Event_Item->new();

=head1 DESCRIPTION

An event item is an event as described in
https://iptc.org/std/NewsML-G2/guidelines/#events-in-newsml-g2
that can be published standalone

=head1 ATTRIBUTES

=over 4

=item allday

Indicates whether this is an all-day event (no time is specified). Default: 0

=item coverages

Freetext list of intented coverages (e.g. 'Text', 'Photo', ...)

=item end

The end date (and maybe time) of the event

=item event_id

The unique id of the event

=item event_notes

An optional array of L<XML::NewsML_G2::Event_Note>s about the event

=item languages

languages of the event

=item locations

The location(s) of the event

=item start

The start date (and maybe time)  of the event

=item subtitle

A short description of the event

=item summary

A more detailed description of the event

=item title

The title of the referenced event

=item media_topics

Hash mapping qcodes to L<XML::NewsML_G2::Media_Topic> instances

=item concepts

Hash mapping generated uids to L<XML::NewsML_G2::Concept> instances

=back

=head1 METHODS

=over 4

=item add_media_topic

Add a new L<XML::NewsML_G2::MediaTopic> instance

=item add_concept

Add a new L<XML::NewsML_G2::Concept> instance

=item add_language

Add a new L<XML::NewsML_G2::Language> instance

=item add_location

Add a new L<XML::NewsML_G2::Location> instance

=item add_note

Add a new L<XML::NewsML_G2::Event_Note> instance

=back

=head1 AUTHOR

Christian Eder  C<< <christian.eder@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2019, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
