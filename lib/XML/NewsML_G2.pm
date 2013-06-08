package XML::NewsML_G2;

# $Id$

use XML::NewsML_G2::News_Item;
use XML::NewsML_G2::Provider;
use XML::NewsML_G2::Service;
use XML::NewsML_G2::Genre;
use XML::NewsML_G2::Desk;
use XML::NewsML_G2::Media_Topic;
use XML::NewsML_G2::Location;
use XML::NewsML_G2::Organisation;
use XML::NewsML_G2::Topic;
use XML::NewsML_G2::Product;
use XML::NewsML_G2::Scheme_Manager;
use XML::NewsML_G2::Scheme;
use XML::NewsML_G2::Writer;
use XML::NewsML_G2::Writer_2_9;
use XML::NewsML_G2::Writer_2_12;

use warnings;
use strict;

use version; our $VERSION = qv('v0.0_3');

1;

__END__

=head1 NAME

XML::NewsML_G2 - generate NewsML G2 news items


=head1 VERSION

This document describes XML::NewsML_G2 version 0.0_1


=head1 SYNOPSIS

    use XML::NewsML_G2;
    my $ni = XML::NewsML_G2::News_Item->new(...);
    my $writer = XML::NewsML_G2::Writer_2_9(news_item => $ni);
    my $dom = $writer->create_dom();


=head1 DESCRIPTION

This module tries to implement the creation of XML files conforming to
the NewsML G2 specification as published by the IPTC. It does not aim
in implementing the complete standard, but in covering the most common
use cases.

For the full specification of the format, visit
L<http://www.iptc.org/site/News_Exchange_Formats/NewsML-G2/>

For further information on this software, please check the following
documentation:

=over 4

=item L<XML::NewsML_G2::News_Item>

=item L<XML::NewsML_G2::Desk>

=item L<XML::NewsML_G2::Genre>

=item L<XML::NewsML_G2::Location>

=item L<XML::NewsML_G2::Media_Topic>

=item L<XML::NewsML_G2::Organisation>

=item L<XML::NewsML_G2::Product>

=item L<XML::NewsML_G2::Provider>

=item L<XML::NewsML_G2::Service>

=item L<XML::NewsML_G2::Topic>

=item L<XML::NewsML_G2::Scheme>

=item L<XML::NewsML_G2::Scheme_Manager>

=item L<XML::NewsML_G2::Writer>

=item L<XML::NewsML_G2::Writer_2_9>

=item L<XML::NewsML_G2::Writer_2_12>

=back

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-xml-newsml_g2@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

Be aware that the API for this module I<will> change with each
upcoming release.

=head1 AUTHOR

Philipp Gortan  C<< <philipp.gortan@apa.at> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013, APA-IT. All rights reserved.

This module is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the
Free Software Foundation; either version 2 of the License, or (at your
option) any later version.

This module is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public License
along with this module.  If not, see L<http://www.gnu.org/licenses/>.
