package XML::NewsML_G2::News_Item;

use XML::LibXML qw();

use Carp;
use Moose;
use namespace::autoclean;

# document properties
extends 'XML::NewsML_G2::Substancial_Item';

has '+language',  required => 1;
has 'caption',    isa      => 'Str',               is => 'rw';
has 'teaser',     isa      => 'Str',               is => 'rw';
has 'byline',     isa      => 'Str',               is => 'rw';
has 'dateline',   isa      => 'Str',               is => 'rw';
has 'paragraphs', isa      => 'XML::LibXML::Node', is => 'rw';
has 'content_created',
    isa     => 'DateTime',
    is      => 'ro',
    lazy    => 1,
    builder => '_build_content_created';
has 'content_modified', isa => 'DateTime', is => 'ro';

has 'credit',       isa => 'Str', is => 'rw';
has 'priority',     isa => 'Int', is => 'ro', default => 5;
has 'message_id',   isa => 'Str', is => 'ro';
has 'slugline',     isa => 'Str', is => 'rw';
has 'slugline_sep', isa => 'Str', is => 'rw', default => '/';
has 'electiondistrict',
    isa => 'XML::NewsML_G2::ElectionDistrict',
    is  => 'rw';
has 'electionmunicipialhousing',
    isa => 'XML::NewsML_G2::ElectionMunicipialHousing',
    is  => 'rw';
has 'electionneighbourhood',
    isa => 'XML::NewsML_G2::ElectionNeighbourhood',
    is  => 'rw';

has 'event_references',
    isa     => 'ArrayRef[XML::NewsML_G2::Event_Ref]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles =>
    { add_event_reference => 'push', has_event_references => 'count' };
has 'sources',
    isa     => 'ArrayRef[Str]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_source => 'push' };
has 'authors',
    isa     => 'XML::NewsML_G2::ArrayRefOfCreators',
    is      => 'rw',
    coerce  => 1,
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_author => 'push' };
has 'cities',
    isa     => 'ArrayRef[Str]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_city => 'push' };

has 'genres',
    isa     => 'ArrayRef[XML::NewsML_G2::Genre]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_genre => 'push' };
has 'storytypes',
    isa     => 'ArrayRef[XML::NewsML_G2::StoryType]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_storytype => 'push' };
has 'organisations',
    isa     => 'ArrayRef[XML::NewsML_G2::Organisation]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_organisation => 'push', has_organisations => 'count' };
has 'topics',
    isa     => 'ArrayRef[XML::NewsML_G2::Topic]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_topic => 'push', has_topics => 'count' };
has 'products',
    isa     => 'ArrayRef[XML::NewsML_G2::Product]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_product => 'push', has_products => 'count' };
has 'desks',
    isa     => 'ArrayRef[XML::NewsML_G2::Desk]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_desk => 'push', has_desks => 'count' };
has 'locations',
    isa     => 'HashRef[XML::NewsML_G2::Location]',
    is      => 'rw',
    default => sub { {} },
    traits  => ['Hash'],
    handles => { has_locations => 'count' };
has 'remotes',
    isa     => 'HashRef',
    is      => 'rw',
    default => sub { {} },
    traits  => ['Hash'],
    handles => { has_remotes => 'count' };
has 'inlinedata',
    isa     => 'ArrayRef[XML::NewsML_G2::Inline_Data]',
    is      => 'rw',
    default => sub { [] },
    traits  => ['Array'],
    handles => { add_inlinedata => 'push', has_inlinedata => 'count' };
has 'translang',
    is            => 'rw',
    isa           => 'XML::NewsML_G2::TransLang',
    documentation =>
    'html lang Google Markup for Autotranslated Text as described in https://cloud.google.com/translate/markup?hl=de#for_short_snippets_or_sections_within_a_html_document';

sub _build_content_created {
    my ($self) = @_;
    return DateTime->now( time_zone => $self->timezone );
}

# public methods

sub add_location {
    my ( $self, $l ) = @_;
    return if exists $self->locations->{ $l->qcode };
    $self->locations->{ $l->qcode } = $l;
    $self->add_location( $l->parent ) if $l->parent;
    return 1;
}

sub add_paragraph {
    my ( $self, $text_or_xml ) = @_;
    my $paras = $self->paragraphs;
    unless ($paras) {
        $self->paragraphs( $paras =
                XML::LibXML->createDocument()->createElement('paragraphs') );
    }
    if ( ref $text_or_xml ) {
        $paras->appendChild($text_or_xml);
    }
    else {
        my $doc = $paras->getOwnerDocument;
        my $p = $doc->createElementNS( 'http://www.w3.org/1999/xhtml', 'p' );
        $p->appendChild( $doc->createTextNode($text_or_xml) );
        $paras->appendChild($p);
    }
    return 1;
}

sub add_remote {
    my ( $self, $uri, $remote ) = @_;
    return if exists $self->remotes->{$uri};
    $self->remotes->{$uri} = $remote;

    return 1;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::News_Item - a news item (story)

=for test_synopsis
    my ($provider, $service, $genre1, $genre2);

=head1 DESCRIPTION

This module acts as a base class for NewsML-G2 news items.
Instead of using this class, use the most appropriate subclass,
e.g. L<XML::NewsML_G2::News_Item_Text>.

=head1 ATTRIBUTES

=over 4

=item authors

List of strings containing names of the news item's authors

=item cities

List of strings containing city names where the story has been written
down (as opposed to: where the story occured)

=item closing

Final comment on planned updates of this story

=item content_created

DateTime instance, defaults to now

=item content_modified

DateTime instance

=item credit

Human readable credit line

=item caption

Human readable content description string

=item correction_note

Note regarding update or correction

=item dateline

Natural language information indicating the place and time that the content
was created

=item derived_from

Deprecated - use derived_froms and add_derived_from instead!

=item derived_froms

List of  XML::NewsML_G2::Link instances

=item desks

List of L<XML::NewsML_G2::Desk> instances

=item doc_status

Defaults to "usable".

=item doc_version

Defaults to "1"

=item embargo

DateTime instance

=item embargo_text

additional text for specifying details on the embargo

=item event_references

List of XML::NewsML_G2::Event_Ref instances

=item evolved_froms

List of  XML::NewsML_G2::Link instances

=item genres

List of L<XML::NewsML_G2::Genre> instances

=item guid

"identifier that is guaranteed to be globally unique for all time and
independent of location". Defaults to a UUID

=item indicators

List of strings to signal additional information

=item language

language of the story, required. E.g. "en", "de", ...

=item locations

Hash mapping qcodes to L<XML::NewsML_G2::Location> instances

=item media_topics

Hash mapping qcodes to L<XML::NewsML_G2::Media_Topic> instances

=item concepts

Hash mapping generated uids to L<XML::NewsML_G2::Concept> instances

=item message_id

Human-readable alternative ID of the story

=item note

Editorial notes

=item organisations

List of L<XML::NewsML_G2::Organisation> instances

=item paragraphs

An L<XML::LibXML::Node> instance containing the content (quite likely
C<p> elements, hence the name) of the story - to be put into the XHTML
body. Use the C<add_paragraph> method to add text unless you want more
control of the output.

=item priority

Numeric message priority, defaults to 5

=item processed_froms

List of XML::NewsML_G2::Link instances

=item products

List of L<XML::NewsML_G2::Product> instances

=item provider

List of L<XML::NewsML_G2::Provider> instances

=item remotes

Hash mapping of hrefs to remote object (e.g. XML::NewsML_G2::Picture) instances

=item see_also

Deprecated - use see_alsos and add_see_also instead!

=item see_alsos

List of XML::NewsML_G2::Link instances

=item service

L<XML::NewsML_G2::Service> instance

=item slugline

String containing the slugline

=item slugline_sep

Slugline separator, defaults to "/"

=item electiondistrict

L<XML::NewsML_G2::ElectionDistrict> instance

=item electionmunicipialhousing

L<XML::NewsML_G2::ElectionMunicipialHousing> instance

=item electionneighbourhood

L<XML::NewsML_G2::ElectionNeighbourhood> instance

=item sources

List of strings containing story source names

=item storytypes

List of L<XML::NewsML_G2::StoryType> instances

=item subtitle

Subtitle string

=item summary

A short overview of all, or at least the most important, facets of the content of the item

=item byline

A free-text expression of the person or organisation that created the content

=item teaser

A short description intended to attract the user to view the full content

=item title

Title string

=item topics

List of L<XML::NewsML_G2::Topic> instances

=item usage_terms

String containing human readable usage terms

=back

=head1 METHODS

=over 4

=item add_author

Add a string to the authors

=item add_city

Add a string to the cities

=item add_derived_from

Add a new "derived from" link - either a string, or a
XML::NewsML_G2::Link instance

=item add_desk

Add a L<XML::NewsML_G2::Desk> instance

=item add_event_reference

Add a L<XML::NewsML_G2::Event_Ref> instance

=item add_genre

Add a L<XML::NewsML_G2::Genre> instance

=item add_indicator

Add a string to the indicators

=item add_location

Add a new L<XML::NewsML_G2::Location> instance

=item add_media_topic

Add a new L<XML::NewsML_G2::MediaTopic> instance

=item add_concept

Add a new L<XML::NewsML_G2::Concept> instance

=item add_organisation

Add a new L<XML::NewsML_G2::Organisation> instance

=item add_paragraph

Takes a string to be added to the C<paragraphs> Node instance as a
C<p> element. To have more control over the created XHTML output,
directly set the C<paragraphs> attribute with a Node instance you
created by yourself.

=item add_product

Add a new L<XML::NewsML_G2::Product> instance

=item add_remote

Add a new remote instance (e.g. XML::NewsML_G2::Picture) with a given href

=item add_see_also

Add a new "see also" link - either a string, or a XML::NewsML_G2::Link
instance

=item add_source

Add a string to the sources

=item add_topic

Add a new L<XML::NewsML_G2::Topic> instance

=back

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013-2015, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
