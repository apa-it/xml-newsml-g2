#! /usr/bin/perl

# $Id$

use utf8;
use Test::More;
use DateTime::Format::XSD;
use XML::LibXML;

use warnings;
use strict;

use XML::NewsML_G2;

my $guid = 'urn:newsml:apa.at:20120315:APA0379';

my $title = 'Saisonstart im Schweizerhaus: Run aufs Krügerl im Prater';
my $slugline = 'Buntes/Freizeit/Bauten/Eröffnung/Unterhaltung/Wien/Kommunales';

my $text_1 =<< 'EOT';
Die Saison im Wiener Prater hat am Donnerstagvormittag mit der
Eröffnung des Schweizerhauses begonnen - diese findet traditionell
jedes Jahr am 15. März statt. Pünktlich um 10.00 Uhr öffnete das
Bierlokal seine Pforten. Für viele Wiener ist das ein Pflichttermin:
"Es ist ein Fest für unsere Stammgäste. Die machen sich schon zum
Saisonschluss im Oktober aus, dass sie am ersten Öffnungstag im neuen
Jahr wieder kommen", sagte der Betreiber des Schweizerhauses, Karl
Kolarik, der APA.
EOT

my $text_2 =<< 'EOT';
Das traditionelle Bierlokal Schweizerhaus geht heuer in die 93. Saison
und erstrahlt in neuem Glanz: "Wir sind nun endgültig fertig mit dem
Umbau", zeigte sich Kolarik erfreut. Vor rund zwei Jahren wurde
begonnen, die Gaststätte zu vergrößern. So bekam das Haus eine neue
Bierschank, einen Lastenaufzug und auch die Sanitäranlagen wurden
erneuert. All diese Bauarbeiten wurden pünktlich bis zum Saisonstart
im Vorjahr abgeschlossen. Kleinere Veränderungen an der Infrastruktur
des Hauses wurden in den vergangenen Monaten fertiggestellt: "Das
bekommt der Gast gar nicht mit, aber wir haben noch unser EDV-System
sowie diverse Kabel verändert", so der Hausherr.
EOT

my $time1 = '2012-03-15T09:09:00+01:00';

ok(my $prov_apa = XML::NewsML_G2::Provider->new
  (qcode => 'apa', name => 'APA - Austria Presse Agentur'
  ), 'create Provider instance');

ok(my $svc_apa_bd = XML::NewsML_G2::Service->new
  (qcode => 'bd', name => 'Basisdienst'
  ), 'create Service instance');

ok(my $ni = XML::NewsML_G2::News_Item->new
   (guid => $guid,
    provider => $prov_apa,
    service => $svc_apa_bd,
    title => $title,
    slugline => $slugline,
    language => 'de',
    content_created => DateTime::Format::XSD->parse_datetime($time1),
   ), 'create News Item instance');

ok($ni->add_paragraph($text_1), 'add_paragraph returns OK');
ok($ni->add_paragraph($text_2), 'add_paragraph returns OK again');

my %schemes;
foreach (qw(crel desk geo svc role ind org topic hltype)) {
    $schemes{$_} = XML::NewsML_G2::Scheme->new(alias => "apa$_", uri => "http://cv.apa.at/$_/");
}

ok(my $sm = XML::NewsML_G2::Scheme_Manager->new(%schemes), 'create Scheme Manager');

my $writer = XML::NewsML_G2::Writer_2_12->new(news_item => $ni, scheme_manager => $sm);

ok(my $dom = $writer->create_dom(), 'create DOM');

ok(my $xpc = XML::LibXML::XPathContext->new($dom), 'create XPath context for DOM tree');
$xpc->registerNs('xhtml', 'http://www.w3.org/1999/xhtml');

ok(my @ps = $xpc->findnodes('//xhtml:p'), 'found paragraphs');

is($ps[0]->textContent, $text_1, 'paragraph 1 is correct');
is($ps[1]->textContent, $text_2, 'paragraph 2 is correct');

done_testing;
