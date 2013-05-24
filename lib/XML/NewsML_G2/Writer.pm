package XML::NewsML_G2::Writer;

# $Id$

use Moose;
use DateTime;
use DateTime::Format::XSD;
use namespace::autoclean;

has 'news_item', isa => 'XML::NewsML_G2::News_Item', is => 'ro', required => 1;

has 'encoding', isa => 'Str', is => 'ro', default => 'utf-8';
has 'generator', isa => 'Str', is => 'ro', default => __PACKAGE__;

has 'scheme_manager', isa => 'XML::NewsML_G2::Scheme_Manager', is => 'ro', required => 1;
has 'doc', isa => 'XML::LibXML::Document', is => 'ro', lazy_build => 1;
has 'formatter', is => 'ro', default => sub {DateTime::Format::XSD->new()};

has 'g2_ns', isa => 'Str', is => 'ro', default => 'http://iptc.org/std/nar/2006-10-01/';
has 'xhtml_ns', isa => 'Str', is => 'ro', default => 'http://www.w3.org/1999/xhtml';

has 'g2_version', isa => 'Str', is => 'ro';
has 'schema_location', isa => 'Str', is => 'ro';
has 'g2_catalog', isa => 'Str', is => 'ro';

# builders

sub _build_doc {
    my $self = shift;
    return XML::LibXML->createDocument('1.0', $self->encoding);
}

# DOM creating methods

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

    my %catalogs = ($self->g2_catalog => 1);

    my $cat;
    foreach my $scheme ($self->scheme_manager->get_all_schemes()) {
        if (my $catalog = $scheme->catalog) {
            $catalogs{$catalog} = 1;
        } else {
            $root->appendChild(my $cat = $self->create_element('catalog')) unless $cat;
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

    $ri->appendChild (my $crh = $self->create_element('copyrightHolder', qcode => 'nprov:' . $self->news_item->provider->qcode));
    $crh->appendChild($self->create_element('name', _text => $self->news_item->provider->name));

    my $notice = $self->news_item->provider->notice;
    $ri->appendChild($self->create_element('copyrightNotice', _text => $notice)) if $notice;

    $root->appendChild($ri);
    return;
}

sub _create_item_meta {
    my ($self, $root) = @_;

    my $im = $self->create_element('itemMeta');
    $im->appendChild($self->create_element('itemClass', qcode => 'ninat:text'));
    $im->appendChild(my $p = $self->create_element('provider', qcode => 'nprov:' . $self->news_item->provider->qcode));
    $p->appendChild($self->create_element('name', _text => $self->news_item->provider->name));
    $im->appendChild($self->create_element('versionCreated', _text => $self->formatter->format_datetime(DateTime->now(time_zone => 'local'))));

    if ($self->news_item->embargo) {
        my $e = $self->formatter->format_datetime($self->news_item->embargo);
        $im->appendChild($self->create_element('embargoed', _text => $e));
    }

    $im->appendChild($self->create_element('pubStatus', qcode => 'stat:' . $self->news_item->doc_status));
    $im->appendChild($self->create_element('generator', versioninfo => XML::NewsML_G2->VERSION, _text => $self->generator));
    $im->appendChild(my $svc = $self->create_element('service', qcode => $self->scheme_manager->svc->alias . ':' . $self->news_item->service->qcode));
    $svc->appendChild($self->create_element('name', _text => $self->news_item->service->name));

    my $role_alias = $self->scheme_manager->role->alias;
    $im->appendChild($self->create_element('edNote', role => "$role_alias:embargotext", _text => $self->news_item->embargo_text)) if $self->news_item->embargo_text;
    $im->appendChild($self->create_element('edNote', role => "$role_alias:closing", _text => $self->news_item->closing)) if $self->news_item->closing;
    $im->appendChild($self->create_element('edNote', role => "$role_alias:note", _text => $self->news_item->note)) if $self->news_item->note;

    $im->appendChild($self->create_element('signal', qcode => 'sig:correction')) if $self->news_item->doc_version > 1;

    my $ind_alias = $self->scheme_manager->ind->alias;
    foreach (@{$self->news_item->indicators}) {
        $im->appendChild($self->create_element('signal', qcode => "$ind_alias:" . lc));
    }

    $im->appendChild($self->create_element('link', rel => 'irel:seeAlso', residref => $self->news_item->see_also)) if ($self->news_item->see_also);

    $root->appendChild($im);
    return;
}

sub _create_hierarchy {
    my ($self, $node, $schema) = @_;
    my @res;

    do {
        unshift @res, "$schema:" . $node->qcode();
    } while ($node = $node->parent());

    return $self->create_element('hierarchyInfo', _text => join ' ', @res);
}

sub _create_subjects_desk {
    my $self = shift;
    my @res;

    push @res, $self->doc->createComment('desks') if $self->news_item->has_desks;
    my $alias = $self->scheme_manager->desk->alias;
    foreach (@{$self->news_item->desks}) {
        push @res, my $s = $self->create_element
          ('subject', type => 'cpnat:abstract', qcode => "$alias:" . $_->qcode);
        $s->appendChild($self->create_element('name', _text => $_->name));
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
        push @res, my $s = $self->create_element('subject', type => 'cpnat:abstract', qcode => 'medtop:'.$mt->qcode, why => $why);
        $s->appendChild($self->create_element('name', _text => $mt->name));
        foreach my $lang (sort keys %{$mt->translations}) {
            $s->appendChild($self->create_element('name', 'xml:lang' => $lang, _text => $mt->translations->{$lang}));
        }
        if ($mt->parent) {
            $s->appendChild(my $b = $self->create_element('broader', qcode => 'medtop:' . $mt->parent->qcode));
            $b->appendChild($self->_create_hierarchy($mt, 'medtop'));
        }
    }
    return @res;
}

sub _create_subjects_location {
    my $self = shift;
    my @res;

    push @res, $self->doc->createComment('locations') if $self->news_item->has_locations;

    my $geo_alias = $self->scheme_manager->geo->alias;
    foreach my $l (sort {$b->relevance <=> $a->relevance} values %{$self->news_item->locations}) {
        my $why = $l->direct ? 'why:direct' : 'why:ancestor';
        push @res, my $s = $self->create_element('subject', type => 'cpnat:geoArea', qcode => "$geo_alias:" . $l->qcode, relevance => $l->relevance, why => $why);
        $s->appendChild($self->create_element('name', _text => $l->name));
        $s->appendChild($self->create_element('sameAs', qcode => 'iso3166-1a2:' . $l->iso_code)) if $l->iso_code;
        if ($l->parent) {
            $s->appendChild(my $b = $self->create_element('broader', qcode => "$geo_alias:" . $l->parent->qcode));
            $b->appendChild($self->_create_hierarchy($l, 'apageo'));
        }
    }
    return @res;
}

sub _create_subjects_organisation {
    my $self = shift;
    my @res;

    push @res, $self->doc->createComment('organisations') if $self->news_item->has_organisations;
    foreach my $org (@{$self->news_item->organisations}) {
        my $qcode = $self->scheme_manager->org->alias . ':' . $org->qcode;
        push @res, my $o = $self->create_element('subject', type => 'cpnat:organisation', qcode => $qcode);
        $o->appendChild($self->create_element('name', _text => $org->name));
    }
    return @res;
}

sub _create_subjects_topic {
    my $self = shift;
    my @res;

    push @res, $self->doc->createComment('topics') if $self->news_item->has_topics;

    foreach my $topic (@{$self->news_item->topics}) {
        my $qcode = $self->scheme_manager->topic->alias . ':' . $topic->qcode;
        push @res, my $t = $self->create_element('subject', type => 'cpnat:abstract', qcode => $qcode);
        $t->appendChild($self->create_element('name', _text => $topic->name));
    }

    return @res;
}

sub _create_subjects_product {
    my $self = shift;
    my @res;

    push @res, $self->doc->createComment('products') if $self->news_item->has_products;

    foreach my $product (@{$self->news_item->products}) {
        my $literal;
        $literal   = 'isbn#' . $product->isbn if $product->isbn;
        $literal ||= 'ean#' . $product->ean if $product->ean;

        push @res, my $p = $self->create_element('subject', type => 'cpnat:object', literal => $literal);
        $p->appendChild($self->create_element('name', _text => $product->name));
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

sub _create_asserts_organisation {
    my $self = shift;

    my @res;
    push @res, $self->doc->createComment('organisations') if $self->news_item->has_organisations;
    my $crel_alias = $self->scheme_manager->crel->alias;

    foreach my $org (@{$self->news_item->organisations}) {
        my $qcode = $self->scheme_manager->org->alias . ':' . $org->qcode;
        push @res, my $a = $self->create_element('assert', qcode => $qcode);
        $a->appendChild($self->create_element('name', _text => $org->name));
        $a->appendChild($self->create_element('sameAs', qcode=> "isin:$_")) foreach @{$org->isins};
        if ($org->has_websites) {
            $a->appendChild(my $od = $self->create_element('organisationDetails'));
            $od->appendChild(my $ci = $self->create_element('contactInfo'));
            $ci->appendChild($self->create_element('web', _text => $_)) foreach @{$org->websites};
        }
        $a->appendChild($self->create_element('related', rel => "$crel_alias:index", literal => $_)) foreach (@{$org->indices});
        $a->appendChild($self->create_element('related', rel => "$crel_alias:exchange", literal => $_)) foreach (@{$org->stock_exchanges});

    }
    return @res;
}

sub _create_asserts {
    my $self = shift;
    my @res;

    push @res, $self->_create_asserts_organisation();

    return @res;
}

sub _create_content_meta {
    my ($self, $root) = @_;

    my $cm = $self->create_element('contentMeta');
    $cm->appendChild($self->create_element('urgency', _text => $self->news_item->priority));

    if ($self->news_item->content_created) {
        my $t = $self->formatter->format_datetime($self->news_item->content_created);
        $cm->appendChild($self->create_element('contentCreated', _text => $t));
    }
    if ($self->news_item->content_modified and $self->news_item->content_created != $self->news_item->content_modified) {
        my $t = $self->formatter->format_datetime($self->news_item->content_modified);
        $cm->appendChild($self->create_element('contentModified', _text => $t));
    }

    foreach (@{$self->news_item->cities}) {
        $cm->appendChild(my $loc = $self->create_element('located'));
        $loc->appendChild($self->create_element('name', _text => $_));
    }

    foreach (@{$self->news_item->sources}) {
        next if $_ eq uc $self->news_item->provider->qcode;
        $cm->appendChild($self->create_element('infoSource', role => 'isrol:originfo', literal => $_));
    }

    foreach (@{$self->news_item->authors}) {
        $cm->appendChild($self->create_element('creator', literal => $_));
    }

    if ($self->news_item->message_id) {
        $cm->appendChild($self->create_element('altId', _text => $self->news_item->message_id));
    }

    $cm->appendChild($self->create_element('language', tag => $self->news_item->language));

    foreach (@{$self->news_item->genres}) {
        $cm->appendChild(my $gn = $self->create_element('genre', qcode => 'genre:' . $_->qcode));
        $gn->appendChild($self->create_element('name', _text => $_->name));
    }

    my @subjects = $self->_create_subjects();
    $cm->appendChild($_) foreach (@subjects);

    $cm->appendChild($self->create_element('slugline', separator => $self->news_item->slugline_sep, _text => $self->news_item->slugline));

    my $hltype_alias = $self->scheme_manager->hltype->alias;
    $cm->appendChild($self->create_element('headline', role => "$hltype_alias:title", _text => $self->news_item->title));
    $cm->appendChild($self->create_element('headline', role => "$hltype_alias:subtitle", _text => $self->news_item->subtitle)) if $self->news_item->subtitle;

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
    return;
}


# public methods

sub create_element {
    my ($self, $name, %attrs) = @_;
    my $text = delete $attrs{_text};
    my $ns = delete $attrs{_ns} || $self->g2_ns;
    my $elem = $self->doc->createElementNS($ns, $name);
    while (my ($k, $v) = each %attrs) {
        $elem->setAttribute($k, $v);
    }
    $elem->appendChild($self->doc->createTextNode($text)) if $text;
    return $elem;
}

sub create_dom {
    my $self = shift;

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
