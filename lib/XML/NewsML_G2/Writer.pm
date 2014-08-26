package XML::NewsML_G2::Writer;

# $Id$

use Module::Runtime 'use_module';

use Carp;
use Moose;
use Moose::Util;
use DateTime;
use DateTime::Format::XSD;
use XML::NewsML_G2::Scheme_Manager;
use namespace::autoclean;

has 'news_item', isa => 'XML::NewsML_G2::News_Item', is => 'ro', required => 1;

has 'encoding', isa => 'Str', is => 'ro', default => 'utf-8';

has 'scheme_manager', isa => 'XML::NewsML_G2::Scheme_Manager', is => 'ro', lazy => 1, builder => '_build_scheme_manager';
has 'doc', isa => 'XML::LibXML::Document', is => 'ro', lazy=> 1, builder => '_build_doc';
has '_formatter', is => 'ro', default => sub {DateTime::Format::XSD->new()};

has 'g2_ns', isa => 'Str', is => 'ro', default => 'http://iptc.org/std/nar/2006-10-01/';
has 'xhtml_ns', isa => 'Str', is => 'ro', default => 'http://www.w3.org/1999/xhtml';

has 'g2_version', isa => 'Str', is => 'ro';
has 'schema_location', isa => 'Str', is => 'ro';
has 'g2_catalog_url', isa => 'Str', is => 'ro';
has 'g2_catalog_schemes', isa => 'HashRef', is => 'ro',
    lazy => 1, builder => '_build_g2_catalog_schemes';

# builders

sub _build_g2_catalog_schemes {
    {isrol => undef, nprov => undef, ninat => undef, stat => undef,
     sig => undef, genre => undef, isin => undef, medtop => undef,
     crol => undef, drol => undef, iso3166_1a2 => 'iso3166-1a2'};
}

sub _build_doc {
    my $self = shift;
    return XML::LibXML->createDocument('1.0', $self->encoding);
}

sub _build_scheme_manager {
    my $self = shift;
    return XML::NewsML_G2::Scheme_Manager->new();
}

# Apply roles needed for writing
sub BUILD {
    my $self = shift;

    (my $my_cls) = reverse split ('::', $self->meta->name);
    (my $ni_cls) = reverse split ('::', $self->news_item->meta->name);

    my $base_role     = sprintf('XML::NewsML_G2::Roles::Writer::%s', $ni_cls);
    my $specific_role = sprintf(
        'XML::NewsML_G2::Roles::%s::%s', $my_cls, $ni_cls
        );

    my $role_to_use;
    eval {
        $role_to_use = $specific_role if use_module($specific_role);
    };
    eval {
        $role_to_use = $base_role if (!$role_to_use && use_module($base_role));
    };
    croak $@ if ($@ && $@ !~ /^Can't locate'/);

    Moose::Util::apply_all_roles($self, $role_to_use) if $role_to_use;

    return;
}

# DOM creating methods

sub _create_creator {
    my ($self, $name) = @_;
    return $self->create_element('creator', _name_text => $name);
}

sub _create_root_element {
    my ($self) = @_;
    my $root = $self->doc->createElementNS($self->g2_ns, 'newsItem');
    $self->doc->setDocumentElement($root);
    $root->setAttributeNS('http://www.w3.org/2001/XMLSchema-instance', 'xsi:schemaLocation',  $self->schema_location);

    $root->setAttribute('standard', 'NewsML-G2');
    $root->setAttribute('standardversion', $self->g2_version);
    $root->setAttribute('conformance', 'power');
    $root->setAttribute('xml:lang', $self->news_item->language);

    $root->setAttribute('guid', $self->news_item->guid);
    $root->setAttribute('version', $self->news_item->doc_version);
    return $root;
}

sub _create_catalogs {
    my ($self, $root) = @_;

    my %catalogs = ($self->g2_catalog_url => 1);

    my $cat;
    foreach my $scheme ($self->scheme_manager->get_all_schemes()) {
        if (my $catalog = $scheme->catalog) {
            $catalogs{$catalog} = 1;
        } elsif ($scheme) {
            $root->appendChild($cat = $self->create_element('catalog')) unless $cat;
            $cat->appendChild($self->create_element('scheme', alias => $scheme->alias, uri => $scheme->uri));
        }
    }

    foreach my $url (sort keys %catalogs) {
        $root->appendChild($self->create_element('catalogRef', href => $url));
    }

    return;
}

sub _create_rights_info {
    my ($self, $root) = @_;
    my $ri = $self->create_element('rightsInfo');

    $ri->appendChild (my $crh = $self->create_element('copyrightHolder', _name_text => $self->news_item->provider));
    $self->scheme_manager->add_qcode_or_literal($crh, 'nprov', $self->news_item->provider->qcode);

    my $notice = $self->news_item->provider->notice;
    $ri->appendChild($self->create_element('copyrightNotice', _text => $notice)) if $notice;

    $root->appendChild($ri);
    return;
}

sub _create_item_meta {
    my ($self, $root) = @_;

    my $im = $self->create_element('itemMeta');
    $im->appendChild(my $ic = $self->create_element('itemClass'));
    $self->_set_item_class($ic);

    $im->appendChild(my $p = $self->create_element('provider', _name_text => $self->news_item->provider));
    $self->scheme_manager->add_qcode_or_literal($p, 'nprov', $self->news_item->provider->qcode);
    $im->appendChild($self->create_element('versionCreated', _text => $self->_formatter->format_datetime(DateTime->now(time_zone => 'local'))));

    if ($self->news_item->embargo) {
        my $e = $self->_formatter->format_datetime($self->news_item->embargo);
        $im->appendChild($self->create_element('embargoed', _text => $e));
    }

    $im->appendChild(my $ps = $self->create_element('pubStatus'));
    $self->scheme_manager->add_qcode($ps, 'stat', $self->news_item->doc_status);
    $im->appendChild($self->create_element('generator', versioninfo => XML::NewsML_G2->VERSION, _text => 'XML::NewsML_G2'));
    if ($self->news_item->has_service) {
        $im->appendChild(my $svc = $self->create_element('service', _name_text => $self->news_item->service));
        $self->scheme_manager->add_qcode($svc, 'svc', $self->news_item->service->qcode);

    }

    if ($self->news_item->embargo_text) {
        $im->appendChild(my $e = $self->create_element('edNote', _text => $self->news_item->embargo_text));
        $self->scheme_manager->add_role($e, 'role', 'embargotext');
    }
    if ($self->news_item->closing) {
        $im->appendChild(my $e = $self->create_element('edNote', _text => $self->news_item->closing));
        $self->scheme_manager->add_role($e, 'role', 'closing');
    }
    if ($self->news_item->note) {
        $im->appendChild(my $e = $self->create_element('edNote', _text => $self->news_item->note));
        $self->scheme_manager->add_role($e, 'role', 'note');
    }

    if ($self->news_item->doc_version > 1) {
        $im->appendChild(my $s = $self->create_element('signal'));
        $self->scheme_manager->add_qcode($s, 'sig', 'correction');
    }

    foreach (@{$self->news_item->indicators}) {
        $im->appendChild(my $s = $self->create_element('signal'));
        $self->scheme_manager->add_qcode($s, 'ind', lc);
    }

    $im->appendChild($self->create_element('link', rel => 'irel:seeAlso', residref => $self->news_item->see_also)) if ($self->news_item->see_also);

    $root->appendChild($im);
    return;
}

sub _create_hierarchy {
    # my ($self, $node, $schema) = @_;
    # code moved to Writer_2_9
    return;
}

sub _create_subjects_desk {
    my $self = shift;
    my @res;

    push @res, $self->doc->createComment('desks') if $self->news_item->has_desks;
    foreach (@{$self->news_item->desks}) {
        push @res, my $s = $self->create_element('subject', type => 'cpnat:abstract', _name_text => $_);
        $self->scheme_manager->add_qcode_or_literal($s, 'desk', $_->qcode);
    }
    return @res;
}

sub _create_subjects_media_topic {
    my $self = shift;
    my @res;

    push @res, $self->doc->createComment('media topics') if $self->news_item->has_media_topics;
    foreach my $mt_qcode (sort keys %{$self->news_item->media_topics}) {
        my $mt = $self->news_item->media_topics->{$mt_qcode};
        my $why = $mt->direct ? 'why:direct' : 'why:ancestor';
        push @res, my $s = $self->create_element('subject', type => 'cpnat:abstract', why => $why, _name_text  => $mt);
        $self->scheme_manager->add_qcode_or_literal($s, 'medtop', $mt->qcode);
        foreach my $lang (sort keys %{$mt->translations}) {
            $s->appendChild($self->create_element('name', 'xml:lang' => $lang, _text => $mt->translations->{$lang}));
        }
        if ($mt->parent) {
            $s->appendChild(my $b = $self->create_element('broader'));
            $self->scheme_manager->add_qcode_or_literal($b, 'medtop', $mt->parent->qcode);
            my $hierarchy = $self->_create_hierarchy($mt, 'medtop');
            $b->appendChild($hierarchy) if $hierarchy;
        }
    }
    return @res;
}

sub _create_subjects_location {
    my $self = shift;
    my @res;

    push @res, $self->doc->createComment('locations') if $self->news_item->has_locations;

    foreach my $l (sort {$b->relevance <=> $a->relevance} values %{$self->news_item->locations}) {
        my $why = $l->direct ? 'why:direct' : 'why:ancestor';
        push @res, my $s = $self->create_element('subject', type => 'cpnat:geoArea', relevance => $l->relevance, why => $why, _name_text => $l);
        $self->scheme_manager->add_qcode_or_literal($s, 'geo', $l->qcode);
        if ($l->iso_code) {
            $s->appendChild(my $sa = $self->create_element('sameAs'));
            $self->scheme_manager->add_qcode_or_literal($sa, 'iso3166_1a2', $l->iso_code);
        }
        if ($l->parent) {
            $s->appendChild(my $b = $self->create_element('broader'));
            $self->scheme_manager->add_qcode_or_literal($b, 'geo', $l->parent->qcode);
            my $hierarchy = $self->_create_hierarchy($l, 'geo');
            $b->appendChild($hierarchy) if $hierarchy;
        }
    }
    return @res;
}

sub _create_subjects_organisation {
    my $self = shift;
    my @res;

    push @res, $self->doc->createComment('organisations') if $self->news_item->has_organisations;
    foreach my $org (@{$self->news_item->organisations}) {
        push @res, my $o = $self->create_element('subject', type => 'cpnat:organisation', _name_text => $org);
        $self->scheme_manager->add_qcode_or_literal($o, 'org', $org->qcode);
    }
    return @res;
}

sub _create_subjects_topic {
    my $self = shift;
    my @res;

    push @res, $self->doc->createComment('topics') if $self->news_item->has_topics;

    foreach my $topic (@{$self->news_item->topics}) {
        push @res, my $t = $self->create_element('subject', type => 'cpnat:abstract', _name_text => $topic);
        $self->scheme_manager->add_qcode_or_literal($t, 'topic', $topic->qcode);
    }

    return @res;
}

sub _create_subjects_product {
    my $self = shift;
    my @res;

    push @res, $self->doc->createComment('products') if $self->news_item->has_products;

    foreach my $product (@{$self->news_item->products}) {
        push @res, my $p = $self->create_element('subject', type => 'cpnat:object', _name_text => $product);
        if ($product->isbn) {
            $self->scheme_manager->add_qcode_or_literal($p, 'isbn', $product->isbn);
        } elsif ($product->ean) {
            $self->scheme_manager->add_qcode_or_literal($p, 'ean', $product->ean);
        }
    }

    return @res;
}


sub _create_subjects {
    my $self = shift;
    my @res;

    push @res, $self->_create_subjects_desk();
    push @res, $self->_create_subjects_media_topic();
    push @res, $self->_create_subjects_location();
    push @res, $self->_create_subjects_organisation();
    push @res, $self->_create_subjects_topic();
    push @res, $self->_create_subjects_product();

    return @res;
}

sub _create_company_data {
    my ($self, $org, $root) = @_;
    return unless ($self->scheme_manager->crel);

    my $crel_alias = $self->scheme_manager->crel->alias;
    $root->appendChild($self->create_element('related', rel => "$crel_alias:index", _name_text => $_)) foreach (@{$org->indices});
    $root->appendChild($self->create_element('related', rel => "$crel_alias:exchange", _name_text => $_)) foreach (@{$org->stock_exchanges});
}

sub _create_asserts_organisation {
    my $self = shift;

    my @res;
    push @res, $self->doc->createComment('organisations') if $self->news_item->has_organisations;

    foreach my $org (@{$self->news_item->organisations}) {
        push @res, my $a = $self->create_element('assert', _name_text => $org);
        $self->scheme_manager->add_qcode_or_literal($a, 'org', $org->qcode);

        foreach (@{$org->isins}) {
            $a->appendChild(my $sa = $self->create_element('sameAs'));
            $self->scheme_manager->add_qcode_or_literal($sa, 'isin', $_);
        }
        if ($org->has_websites) {
            $a->appendChild(my $od = $self->create_element('organisationDetails'));
            $od->appendChild(my $ci = $self->create_element('contactInfo'));
            $ci->appendChild($self->create_element('web', _text => $_)) foreach @{$org->websites};
        }
        $self->_create_company_data($org, $a);
    }
    return @res;
}

sub _create_asserts {
    my $self = shift;
    my @res;

    push @res, $self->_create_asserts_organisation();

    return @res;
}

sub _create_infosources {
    my ($self, $root) = @_;
    foreach (@{$self->news_item->sources}) {
        next if $_ eq uc $self->news_item->provider->qcode;
        $root->appendChild(my $i = $self->create_element('infoSource', _name_text => $_));
        $self->scheme_manager->add_role($i, 'isrol', 'originfo');
    }
    return;
}

sub _create_authors {
    my ($self, $root) = @_;
    foreach (@{$self->news_item->authors}) {
        $root->appendChild($self->_create_creator($_));
    }
    return;
}

sub _create_content_meta {
    my ($self, $root) = @_;

    my $cm = $self->create_element('contentMeta');
    $cm->appendChild($self->create_element('urgency', _text => $self->news_item->priority));

    if ($self->news_item->content_created) {
        my $t = $self->_formatter->format_datetime($self->news_item->content_created);
        $cm->appendChild($self->create_element('contentCreated', _text => $t));
    }
    if ($self->news_item->content_modified and $self->news_item->content_created != $self->news_item->content_modified) {
        my $t = $self->_formatter->format_datetime($self->news_item->content_modified);
        $cm->appendChild($self->create_element('contentModified', _text => $t));
    }

    foreach (@{$self->news_item->cities}) {
        $cm->appendChild(my $loc = $self->create_element('located', _name_text => $_));
    }

    $self->_create_infosources($cm);
    $self->_create_authors($cm);

    if ($self->news_item->message_id) {
        $cm->appendChild($self->create_element('altId', _text => $self->news_item->message_id));
    }

    $cm->appendChild($self->create_element('language', tag => $self->news_item->language));

    foreach (@{$self->news_item->genres}) {
        $cm->appendChild(my $gn = $self->create_element('genre', _name_text => $_));
        $self->scheme_manager->add_qcode_or_literal($gn, 'genre', $_->qcode);
    }

    my @subjects = $self->_create_subjects();
    $cm->appendChild($_) foreach (@subjects);

    if ($self->news_item->slugline) {
        $cm->appendChild($self->create_element('slugline', separator => $self->news_item->slugline_sep, _text => $self->news_item->slugline));
    }

    $cm->appendChild(my $hl1 = $self->create_element('headline', _text => $self->news_item->title));
    $self->scheme_manager->add_role($hl1, 'hltype', 'title');

    if ($self->news_item->subtitle) {
        $cm->appendChild(my $hl2 = $self->create_element('headline', _text => $self->news_item->subtitle));
        $self->scheme_manager->add_role($hl2, 'hltype', 'subtitle');
    }

    if ($self->news_item->credit) {
        $cm->appendChild($self->create_element('creditline', _text => $self->news_item->credit));
    }

    foreach (@{$self->news_item->keywords}) {
        $cm->appendChild($self->create_element('keyword', _text => $_));
    }

    if ($self->news_item->description) {
        $cm->appendChild(my $desc = $self->create_element('description', _text => $self->news_item->description));
        $self->scheme_manager->add_role($desc, 'drol', 'caption');
    }

    $root->appendChild($cm);

    my @asserts = $self->_create_asserts();
    $root->appendChild($_) foreach @asserts;
    return;
}

sub _create_content {
    my ($self, $root) = @_;

    $root->appendChild(my $cs = $self->create_element('contentSet'));
    my $inlinexml = $self->create_element('inlineXML', contenttype => 'application/xhtml+xml');
    my $html = $self->create_element('html', _ns => $self->xhtml_ns);
    $html->appendChild(my $head = $self->create_element('head', _ns => $self->xhtml_ns));
    $head->appendChild($self->create_element('title', _ns => $self->xhtml_ns, _text => $self->news_item->title));
    $inlinexml->appendChild($html);

    $html->appendChild(my $body = $self->create_element('body', _ns => $self->xhtml_ns));

    $body->appendChild($self->create_element('h1', _ns => $self->xhtml_ns, _text => $self->news_item->title));
    $body->appendChild($self->create_element('h2', _ns => $self->xhtml_ns, _text => $self->news_item->subtitle)) if $self->news_item->subtitle;

    my @paras = $self->news_item->paragraphs ? $self->news_item->paragraphs->getChildNodes() : ();
    $body->appendChild($_) foreach (@paras);

    $cs->appendChild($inlinexml);
    foreach (sort keys %{$self->news_item->remotes}) {
        my $rc = $self->create_element('remoteContent', href => $_);
        $self->_create_remote_content($rc, $self->news_item->remotes->{$_});
        $cs->appendChild($rc);
    }
    return;
}

sub _import_iptc_catalog {
    my $self = shift;

    while (my ($attr, $alias) = each %{$self->g2_catalog_schemes}) {
        $alias ||= $attr;
        my $getter_setter = $self->scheme_manager->can($attr) or die "Unknown scheme '$attr'\n";
        next if ($getter_setter->($self->scheme_manager)); # attribute ist already set by user
        my $scheme = XML::NewsML_G2::Scheme->new(alias => $alias, catalog => $self->g2_catalog_url);
        $getter_setter->($self->scheme_manager, $scheme);
    }
    return;
}

# public methods

sub create_element {
    my ($self, $name, %attrs) = @_;
    my $text = delete $attrs{_text};
    my $name_text = delete $attrs{_name_text};
    my $ns = delete $attrs{_ns} || $self->g2_ns;
    my $elem = $self->doc->createElementNS($ns, $name);
    while (my ($k, $v) = each %attrs) {
        $elem->setAttribute($k, $v);
    }
    if ($text) {
        $elem->appendChild($self->doc->createTextNode($text));
    } elsif ($name_text) {
        $name_text = $name_text->name if $name_text->can("name");
        $elem->appendChild($self->create_element('name', _text => $name_text));
    }
    return $elem;
}

sub create_dom {
    my $self = shift;

    $self->_import_iptc_catalog();
    my $root = $self->_create_root_element();
    $self->_create_catalogs($root);
    $self->_create_rights_info($root);
    $self->_create_item_meta($root);
    $self->_create_content_meta($root);
    $self->_create_content($root);
    return $self->doc;

}


__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::Writer - base class for XML DOM tree creation
conforming to NewsML-G2

=for test_synopsis
    my ($ni, $sm);

=head1 SYNOPSIS

    my $w = XML::NewsML_G2::Writer_2_12->new
        (news_item => $ni, scheme_manager => $sm);

    my $p = $w->create_element('p', class => 'main', _text => 'blah');

    my $dom = $w->create_dom();

=head1 DESCRIPTION

This module acts as a NewsML-G2 version-independent base
class. Instead of using this class, use the most current subclass,
e.g. L<XML::NewsML_G2::Writer_2_12>.

=head1 ATTRIBUTES

=over 4

=item news_item

L<XML::NewsML_G2::News_Item> instance used to create the output document

=item encoding

Encoding used to create the output document, defaults to utf-8

=item scheme_manager

L<XML::NewsML_G2::Scheme_Manager> instance used to create qcodes

=item doc

L<XML::LibXML::Document> instance used to create the output document

=item g2_ns

XML Namespace of NewsML-G2

=item xhtml_n2

XML Namespace of XHTML

=item g2_version

Specified by subclass.

=item schema_location

Specified by subclass.

=item g2_catalog_url

URL of the G2 catalog, specified by subclass.

=item g2_catalog_schemes

Reference to a hash of schemes that are covered by the G2 catalog. If
the value is undefined, it defaults to the name of the scheme.

=back

=head1 METHODS

=over 4

=item create_element

Helper method that creates XML elements, e.g. to be used in the
C<paragraphs> element of the L<XML::NewsML_G2::News_Item>.

=item create_dom

Returns the L<XML::LibXML::Document> element containing the requested
output. Be careful I<not> to use C<< $dom->serialize(2) >> for formatting,
as this creates invalid NewsML-G2 files because it adds whitespace
where none is allowed (e.g. in xs:dateTime elements).

=back

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013-2014, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
