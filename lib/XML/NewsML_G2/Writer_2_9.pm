package XML::NewsML_G2::Writer_2_9;

# $Id$

use Moose;
use namespace::autoclean;


extends 'XML::NewsML_G2::Writer';

has '+g2_version', default => '2.9';
has '+schema_location', default => 'http://iptc.org/std/nar/2006-10-01/ http://www.iptc.org/std/NewsML-G2/2.9/specification/NewsML-G2_2.9-spec-All-Power.xsd';
has '+g2_catalog_url', default => 'http://www.iptc.org/std/catalog/catalog.IPTC-G2-Standards_18.xml';

override '_create_catalogs' => sub {
    my ($self, $root) = @_;
    $root->appendChild($self->create_element('catalogRef', href => $self->g2_catalog_url));

    my $cat;
    foreach my $scheme ($self->scheme_manager->get_all_schemes()) {
        if ($scheme->uri) {
            $root->appendChild($cat = $self->create_element('catalog')) unless $cat;
            $cat->appendChild($self->create_element('scheme', alias => $scheme->alias, uri => $scheme->uri));
        }
    }
    return;
};

override '_create_hierarchy' => sub {
    my ($self, $node, $schema) = @_;
    my @res;

    do {
        unshift @res, "$schema:" . $node->qcode();
    } while ($node = $node->parent());

    return $self->create_element('hierarchyInfo', _text => join ' ', @res);
};

override '_create_infosources' => sub {
    my ($self, $root) = @_;
    foreach (@{$self->news_item->sources}) {
        next if $_ eq uc $self->news_item->provider->qcode;
        $root->appendChild(my $i = $self->create_element('infoSource', literal => $_));
        $self->scheme_manager->add_role($i, 'isrol', 'originfo');
    }
    return;
};

override '_create_company_data' => sub {
    my ($self, $org, $root) = @_;
    return unless ($self->scheme_manager->crel);

    my $crel_alias = $self->scheme_manager->crel->alias;
    $root->appendChild($self->create_element('related', rel => "$crel_alias:index", literal => $_)) foreach (@{$org->indices});
    $root->appendChild($self->create_element('related', rel => "$crel_alias:exchange", literal => $_)) foreach (@{$org->stock_exchanges});
};

override '_create_creator' => sub {
    my ($self, $name) = @_;
    return $self->create_element('creator', literal => $name);
};

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::Writer_2_9 - create XML DOM tree conforming to version
2.9 of the NewsML-G2 specification

Check the documentation of L<XML::NewsML_G2::Writer> for general
information on this class.

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013-2014, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
