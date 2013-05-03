package Text::NewsML_G2::News_Item;

# $Id$

use XML::LibXML qw();

use Moose;
use namespace::autoclean;


has 'language', isa => 'Str', is => 'ro', default => 'de';

# document properties
has 'guid', isa => 'Str', is => 'ro', required => 1;
has 'doc_version', isa => 'Int', is => 'ro', default => '1';
has 'provider', isa => 'Text::NewsML_G2::Provider', is => 'ro', required => 1;
has 'service', isa => 'Text::NewsML_G2::Service', is => 'ro', required => 1;
has 'doc_status', isa => 'Str', is => 'ro', default => 'usable';
has 'title', isa => 'Str', is => 'ro', required => 1;
has 'subtitle', isa => 'Str', is => 'rw';
has 'paragraphs', isa => 'XML::LibXML::Node', is => 'rw';
has 'content_created', isa => 'DateTime', is => 'ro', required => 1;
has 'content_modified', isa => 'DateTime', is => 'ro';
has 'embargo', isa => 'DateTime', is => 'rw';
has 'embargo_text', isa => 'Str', is => 'rw';

has 'priority', isa => 'Int', is => 'ro', default => 5;
has 'message_id', isa => 'Str', is => 'ro', required => 1;
has 'slugline', isa => 'Str', is => 'ro', required => 1;
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

has 'genres', isa => 'ArrayRef[Text::NewsML_G2::Genre]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_genre => 'push'};
has 'organisations', isa => 'ArrayRef[Text::NewsML_G2::Organisation]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_organisation => 'push', has_organisations => 'count'};
has 'topics', isa => 'ArrayRef[Text::NewsML_G2::Topic]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_topic => 'push', has_topics => 'count'};
has 'products', isa => 'ArrayRef[Text::NewsML_G2::Product]', is => 'rw', default => sub { [] },
  traits => ['Array'], handles => {add_product => 'push', has_products => 'count'};
has 'desks', isa => 'ArrayRef[Text::NewsML_G2::Desk]', is => 'rw',  default => sub { [] },
  traits => ['Array'], handles => {add_desk => 'push', has_desks => 'count'};
has 'media_topics', isa => 'HashRef[Text::NewsML_G2::Media_Topic]', is => 'rw', default => sub { {} },
  traits => ['Hash'], handles => {has_media_topics => 'count'};
has 'locations', isa => 'HashRef[Text::NewsML_G2::Location]', is => 'rw', default => sub { {} },
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

__PACKAGE__->meta->make_immutable;

1;
