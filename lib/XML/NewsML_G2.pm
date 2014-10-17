package XML::NewsML_G2;

# $Id$

use XML::NewsML_G2::News_Item;
use XML::NewsML_G2::News_Item_Text;
use XML::NewsML_G2::News_Item_Picture;
use XML::NewsML_G2::News_Item_Video;
use XML::NewsML_G2::News_Item_Graphics;
use XML::NewsML_G2::News_Item_Audio;
use XML::NewsML_G2::News_Message;
use XML::NewsML_G2::Provider;
use XML::NewsML_G2::Copyright_Holder;
use XML::NewsML_G2::Service;
use XML::NewsML_G2::Genre;
use XML::NewsML_G2::Desk;
use XML::NewsML_G2::Media_Topic;
use XML::NewsML_G2::Location;
use XML::NewsML_G2::Organisation;
use XML::NewsML_G2::Picture;
use XML::NewsML_G2::Video;
use XML::NewsML_G2::Graphics;
use XML::NewsML_G2::Audio;
use XML::NewsML_G2::Icon;
use XML::NewsML_G2::Topic;
use XML::NewsML_G2::Product;
use XML::NewsML_G2::Package_Item;
use XML::NewsML_G2::Group;
use XML::NewsML_G2::Scheme_Manager;
use XML::NewsML_G2::Scheme;
use XML::NewsML_G2::Writer::News_Item;
use XML::NewsML_G2::Writer::Package_Item;
use XML::NewsML_G2::Writer::News_Message;

use warnings;
use strict;

use version; our $VERSION = qv('0.1_4');

1;

__END__

=head1 NAME

XML::NewsML_G2 - generate NewsML-G2 news items


=head1 VERSION

0.1_4

=begin readme

=head1 INSTALLATION

To install this module, run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

=end readme

=for test_synopsis
    my %args;

=head1 SYNOPSIS

    use XML::NewsML_G2;
    my $ni = XML::NewsML_G2::News_Item_Text->new(%args);
    my $writer = XML::NewsML_G2::Writer_2_18(news_item => $ni);
    my $dom = $writer->create_dom();


=head1 DESCRIPTION

This module tries to implement the creation of XML files conforming to
the NewsML-G2 specification as published by the IPTC. It does not aim
in implementing the complete standard, but in covering the most common
use cases.

For the full specification of the format, visit
L<http://www.iptc.org/site/News_Exchange_Formats/NewsML-G2/>

=head1 CURRENT STATUS

The implementation currently supports text, picture, video, audio,
graphics, as well as multimedia packages.

Versions 2.9 and 2.12 of the standard are frozen, so the output should
not change when you update this distribution. Version 2.18 however is
not yet frozen, changes in the output are to be expected.

=head1 SCHEMES AND CATALOGS

Before starting to use schemes or catalogs with this module, read the
chapter 13 of the
L<NewsML-G2 implementation guide|http://www.iptc.org/std/NewsML-G2/2.17/documentation/IPTC-G2-Implementation_Guide_6.1.pdf>.
Go on, do it now. I'll wait.

You don't need to use either schemes or catalogs in order to use this
module, unless you are required to do so by the NewsML-G2 standard
(e.g. the C<service> attribute). If you specify a value for such an
attribute and don't add a corresponding scheme, creating the DOM tree
will die.

For all attributes where a scheme is not required by the standard, you
can start without specifying anything. In that case, a C<literal>
attribute will be created, with the value you specified in the
C<qcode> attribute. For instance:

    my $org = XML::NewsML_G2::Organisation->new(name => 'Google', qcode => 'gogl');
    $ni->add_organisation($org);

will result in this output:

    <subject type="cpnat:organisation" literal="org#gogl">
      <name>Google</name>
    </subject>

If the qcodes used in your organisation instances are part of a
controlled vocabulary, you can convey this information by creating a
L<XML::NewsML_G2::Scheme> instance, specifying a custom, unique C<uri>
for your vocabulary, and registering it with the
L<XML::NewsML_G2::Scheme_Manager>:

    my $os = XML::NewsML_G2::Scheme->new(alias => 'xyzorg',
        uri => 'http://xyz.org/cv/org');
    my $sm = XML::NewsML_G2::Scheme_Manager->new(org => $os);

The output will now contain an inline catalog with your scheme:

    <catalog>
      <scheme alias="xyzorg" uri="http://xyz.org/cv/org"/>
    </catalog>

and the literal will be replaced by a qcode:

    <subject type="cpnat:organisation" qcode="xyzorg:gogl">
      <name>Google</name>
    </subject>

If you have multiple schemes, you can package them together into a
single catalog, which you publish on your website. Simply specify the
URL of the catalog when creating the L<XML::NewsML_G2::Scheme>
instance:

    my $os = XML::NewsML_G2::Scheme->new(alias => 'xyzorg',
        catalog => 'http://xyz.org/catalog_1.xml');

and the inline catalog will be replaced with a link:

    <catalogRef href="http://xyz.org/catalog_1.xml"/>

=head1 API

=over 4

=item L<XML::NewsML_G2::News_Item>

=item L<XML::NewsML_G2::News_Item_Text>

=item L<XML::NewsML_G2::News_Item_Audio>

=item L<XML::NewsML_G2::News_Item_Picture>

=item L<XML::NewsML_G2::News_Item_Video>

=item L<XML::NewsML_G2::News_Item_Graphics>

=item L<XML::NewsML_G2::News_Message>

=item L<XML::NewsML_G2::Package_Item>

=item L<XML::NewsML_G2::AnyItem>



=item L<XML::NewsML_G2::Scheme>

=item L<XML::NewsML_G2::Scheme_Manager>


=item L<XML::NewsML_G2::Service>

=item L<XML::NewsML_G2::Video>

=item L<XML::NewsML_G2::Media_Topic>

=item L<XML::NewsML_G2::Topic>

=item L<XML::NewsML_G2::Genre>

=item L<XML::NewsML_G2::Provider>

=item L<XML::NewsML_G2::Desk>

=item L<XML::NewsML_G2::Group>

=item L<XML::NewsML_G2::Picture>

=item L<XML::NewsML_G2::Location>

=item L<XML::NewsML_G2::Graphics>

=item L<XML::NewsML_G2::Audio>

=item L<XML::NewsML_G2::Copyright_Holder>

=item L<XML::NewsML_G2::Organisation>

=item L<XML::NewsML_G2::Product>

=item L<XML::NewsML_G2::Icon>


=item L<XML::NewsML_G2::Writer>

=item L<XML::NewsML_G2::Writer::News_Item>

=item L<XML::NewsML_G2::Writer::News_Message>

=item L<XML::NewsML_G2::Writer::Package_Item>


=item L<XML::NewsML_G2::Types>



=item L<XML::NewsML_G2::Role::Writer>

=item L<XML::NewsML_G2::Role::Writer_2_9>

=item L<XML::NewsML_G2::Role::Writer_2_12>

=item L<XML::NewsML_G2::Role::Writer_2_18>

=item L<XML::NewsML_G2::Role::Writer::News_Item_Text>

=item L<XML::NewsML_G2::Role::Writer::News_Item_Audio>

=item L<XML::NewsML_G2::Role::Writer::News_Message>

=item L<XML::NewsML_G2::Role::Writer::News_Item_Picture>

=item L<XML::NewsML_G2::Role::Writer::Package_Item>

=item L<XML::NewsML_G2::Role::Writer::News_Item_Video>

=item L<XML::NewsML_G2::Role::Writer::News_Item_Graphics>

=item L<XML::NewsML_G2::Role::HasQCode>

=item L<XML::NewsML_G2::Role::Remote>

=item L<XML::NewsML_G2::Role::RemoteVisual>

=item L<XML::NewsML_G2::Role::RemoteAudible>


=back

=head1 DEPENDENCIES

Moose, XML::LibXML, DateTime, DateTime::Format::XSD, UUID::Tiny

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-xml-newsml_g2@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

Be aware that the API for this module I<will> change with each
upcoming release.

=head1 SEE ALSO

=over 4

=item L<XML::NewsML> - Simple interface for creating NewsML documents

=back

=head1 AUTHOR

=over 4

=item Philipp Gortan  C<< <philipp.gortan@apa.at> >>

=item Mario Paumann  C<< <mario.paumann@apa.at> >>

=item Christian Eder  C<< <christian.eder@apa.at> >>

=item Stefan Hrdlicka  C<< <stefan.hrdlicka@apa.at> >>

=back

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2013-2014, APA-IT. All rights reserved.

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
