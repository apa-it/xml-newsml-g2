package XML::NewsML_G2::Writer_2_12;

# $Id$

use Moose;
use namespace::autoclean;


extends 'XML::NewsML_G2::Writer';

has '+g2_version', default => '2.12';
has '+schema_location', default => 'http://iptc.org/std/nar/2006-10-01/';
has '+g2_catalog_url', default => 'http://www.iptc.org/std/catalog/catalog.IPTC-G2-Standards_22.xml';

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

XML::NewsML_G2::Writer_2_12 - create XML DOM tree conforming to version 2.12 of the NewsML G2 specification

Check the documentation of L<XML::NewsML_G2::Writer> for details.

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, APA-IT. All rights reserved.

See L<XML::NewsML_G2> for the license.
