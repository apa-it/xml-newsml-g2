package XML::NewsML_G2::Writer_2_9;

# $Id$

use Moose;
use namespace::autoclean;


extends 'XML::NewsML_G2::Writer';

has '+g2_version', default => '2.9';
has '+schema_location', default => 'http://iptc.org/std/nar/2006-10-01/ http://www.iptc.org/std/NewsML-G2/2.9/specification/NewsML-G2_2.9-spec-All-Power.xsd';
has '+g2_catalog', default => 'http://www.iptc.org/std/catalog/catalog.IPTC-G2-Standards_18.xml';

override '_create_catalogs' => sub {
    my ($self, $root) = @_;
    $root->appendChild($self->create_element('catalogRef', href => $self->g2_catalog));

    $root->appendChild(my $cat = $self->create_element('catalog'));
    foreach my $scheme ($self->scheme_manager->get_all_schemes()) {
        $cat->appendChild($self->create_element('scheme', alias => $scheme->alias, uri => $scheme->uri));
    }
    return;
};

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::Writer_2_9 - create XML DOM tree conforming to version 2.9 of the NewsML G2 specification

Check the documentation of L<XML::NewsML_G2::Writer> for general information on this class.

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 COPYRIGHT

Copyright (c) 2013, APA-IT. All rights reserved.
