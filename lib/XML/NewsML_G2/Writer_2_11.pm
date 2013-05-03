package XML::NewsML_G2::Writer_2_11;

# $Id$

use Moose;
use namespace::autoclean;


extends 'XML::NewsML_G2::Writer';

has '+g2_version', default => '2.11';
has '+schema_location', default => 'http://iptc.org/std/nar/2006-10-01/';
has '+g2_catalog', default => 'http://www.iptc.org/std/catalog/catalog.IPTC-G2-Standards_18.xml';

__PACKAGE__->meta->make_immutable;

1;
