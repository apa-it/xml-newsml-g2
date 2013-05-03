package Text::NewsML_G2::Writer_2_9;

# $Id$

use Moose;
use namespace::autoclean;


extends 'Text::NewsML_G2::Writer';

has '+g2_version', default => '2.9';
has '+schema_location', default => 'http://iptc.org/std/nar/2006-10-01/ http://www.iptc.org/std/NewsML-G2/2.9/specification/NewsML-G2_2.9-spec-All-Power.xsd';
has '+g2_catalog', default => 'http://www.iptc.org/std/catalog/catalog.IPTC-G2-Standards_18.xml';

__PACKAGE__->meta->make_immutable;

1;
