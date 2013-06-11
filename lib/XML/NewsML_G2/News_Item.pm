package XML::NewsML_G2::News_Item;

# $Id$

use XML::LibXML qw();
use UUID::Tiny ':std';

use Moose;
use namespace::autoclean;


has 'language', isa => 'Str', is => 'ro', required => 1;

# document properties
has 'guid', isa => 'Str', is => 'ro', default => sub {create_uuid_as_string()};
has 'doc_version', isa => 'Int', is => 'ro', default => '1';
has 'provider', isa => 'XML::NewsML_G2::Provider', is => 'ro', required => 1;
has 'service', isa => 'XML::NewsML_G2::Service', is => 'ro', predicate => 'has_service';
has 'doc_status', isa => 'Str', is => 'ro', default => 'usable';
has 'title', isa => 'Str', is => 'ro', required => 1;
has 'subtitle', isa => 'Str', is => 'rw';
has 'paragraphs', isa => 'XML::LibXML::Node', is => 'rw';
has 'content_created', isa => 'DateTime', is => 'ro', default => sub {DateTime->now()};
has 'content_modified', isa => 'DateTime', is => 'ro';
has 'embargo', isa => 'DateTime', is => 'rw';
has 'embargo_text', isa => 'Str', is => 'rw';

has 'priority', isa => 'Int', is => 'ro', default => 5;
has 'message_id', isa => 'Str', is => 'ro';
has 'slugline', isa => 'Str', is => 'ro';
has 'slugline_sep', isa => 'Str', is => 'ro', default => '/';
has 'note', isa => 'Str', is => 'ro';
has 'closing', isa => 'Str', is => 'rw';
has 'see_also', isa => 'Str', is => 'rw';

has 'sources', isa => 'ArrayRef[Str]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_source => 'push'};
has 'authors', isa => 'ArrayRef[Str]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_author => 'push'};
has 'indicators', isa => 'ArrayRef[Str]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_indicator => 'push'};
has 'cities', isa => 'ArrayRef[Str]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_city => 'push'};

has 'genres', isa => 'ArrayRef[XML::NewsML_G2::Genre]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_genre => 'push'};
has 'organisations', isa => 'ArrayRef[XML::NewsML_G2::Organisation]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_organisation => 'push', has_organisations => 'count'};
has 'topics', isa => 'ArrayRef[XML::NewsML_G2::Topic]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_topic => 'push', has_topics => 'count'};
has 'products', isa => 'ArrayRef[XML::NewsML_G2::Product]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_product => 'push', has_products => 'count'};
has 'desks', isa => 'ArrayRef[XML::NewsML_G2::Desk]', is => 'rw',  default => sub { [] },
  traits => ['Array'], handles => {add_desk => 'push', has_desks => 'count'};
has 'media_topics', isa => 'HashRef[XML::NewsML_G2::Media_Topic]', is => 'rw', default => sub { {} },
  traits => ['Hash'], handles => {has_media_topics => 'count'};
has 'locations', isa => 'HashRef[XML::NewsML_G2::Location]', is => 'rw', default => sub { {} },
  traits => ['Hash'], handles => {has_locations => 'count'};


# public methods

sub add_media_topic {
    my ($self, $mt) = @_;
    return if exists $self->media_topics->{$mt->qcode};
    $self->media_topics->{$mt->qcode} = $mt;
    $self->add_media_topic($mt->parent) if ($mt->parent);
    return 1;
}

sub add_location {
    my ($self, $l) = @_;
    return if exists $self->locations->{$l->qcode};
    $self->locations->{$l->qcode} = $l;
    $self->add_location($l->parent) if $l->parent;
    return 1;
}

sub add_paragraph {
    my ($self, $text) = @_;
    my $paras = $self->paragraphs;
    unless ($paras) {
        $self->paragraphs($paras = XML::LibXML->createDocument()->createElement('paragraphs'));
    }
    my $doc = $paras->getOwnerDocument;
    my $p = $doc->createElementNS('http://www.w3.org/1999/xhtml', 'p');
    $p->appendChild($doc->createTextNode($text));
    $paras->appendChild($p);
    return 1;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::News_Item - a news item (story)

=head1 SYNOPSIS

    my $ni = XML::NewsML_G2::News_Item->new
        (guid => $guid,
         title => "Story title",
         slugline => "the/slugline",
         language => 'de',
         provider => $provider_instance,
         service => $service_instance,
        );
    $ni->add_genre($genre1, $genre2);
    $ni->add_source('APA');
    $ni->add_paragraph('blah blah blah');


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

=item products

List of L<XML::NewsML_G2::Product> instances

=item provider

List of L<XML::NewsML_G2::Provider> instances

=item see_also

Free-format string

=item service

L<XML::NewsML_G2::Service> instance

=item slugline

String containing the slugline

=item slugline_sep

Slugline separator, defaults to "/"

=item sources

List of strings containing story source names

=item subtitle

Subtitle string

=item title

Title string

=item topics

List of L<XML::NewsML_G2::Topic> instances

=back

=head1 METHODS

=over 4

=item add_author

Add a string to the authors

=item add_city

Add a string to the cities

=item add_desk

Add a L<XML::NewsML_G2::Desk> instance

=item add_genre

Add a L<XML::NewsML_G2::Genre> instance

=item add_indicator

Add a string to the indicators

=item add_location

Add a new L<XML::NewsML_G2::Location> instance

=item add_media_topic

Add a new L<XML::NewsML_G2::MediaTopic> instance

=item add_organisation

Add a new L<XML::NewsML_G2::Organisation> instance

=item add_paragraph

Takes a string to be added to the C<paragraphs> Node instance as a
C<p> element. To have more control over the created XHTML output,
directly set the C<paragraphs> attribute with a Node instance you
created by yourself.

=item add_product

Add a new L<XML::NewsML_G2::Product> instance

=item add_source

Add a string to the sources

=item add_topic

Add a new L<XML::NewsML_G2::Topic> instance

=back

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
