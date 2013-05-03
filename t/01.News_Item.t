#! /usr/bin/perl

# $Id$

use utf8;
use Test::More;
use Test::Exception;
use File::Basename;
use File::Spec::Functions qw(catfile);
use DateTime::Format::XSD;
use XML::LibXML;

use warnings;
use strict;

use XML::NewsML_G2;

my $base_dir = dirname $0 || '.';

my $guid = 'urn:newsml:apa.at:20120315:APA0379';
my $see_also_guid = 'urn:newsml:apa.at:20120315:APA0123';

my $title = 'Saisonstart im Schweizerhaus: Run aufs Krügerl im Prater';
my $subtitle = 'Großer Andrang am Eröffnungstag - Auch der Rummelplatz startete heute den Betrieb';
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

my $apa_id = 'APA0379';

my $time1 = '2012-03-15T09:09:00+01:00';
my $time2 = '2012-03-15T10:10:00+01:00';
my $embargo = '2012-03-15T12:00:00+01:00';
my $embargo_text = 'frei für Dienstagsausgaben';

ok(my $genre1 = XML::NewsML_G2::Genre->new
   (name => 'Berichterstattung',
    qcode => 'Current'
   ), 'create Genre instance 1');

ok(my $genre2 = XML::NewsML_G2::Genre->new
   (name => 'Extra',
    qcode => 'Extra'
   ), 'create Genre instance 2');

ok(my $org = XML::NewsML_G2::Organisation->new
   (name => 'Ottakringer Brauerei',
    qcode => '161616',
    isins => ['AT0000758032'],
    websites => ['http://www.ottakringer.at'],
    markets => ['Wien', 'Prag']
   ), 'create Organisation instance');

ok(my $prov_apa = XML::NewsML_G2::Provider->new
  (qcode => 'apa', name => 'APA - Austria Presse Agentur'
  ), 'create Provider instance');

ok(my $svc_apa_bd = XML::NewsML_G2::Service->new
  (qcode => 'bd', name => 'Basisdienst'
  ), 'create Service instance');

ok(my $desk_ci = XML::NewsML_G2::Desk->new
   (qcode => 'CI', name => 'Chronik Inland'
   ), 'create Desk instance');

ok(my $ni = XML::NewsML_G2::News_Item->new
   (guid => $guid,
    see_also => $see_also_guid,
    provider => $prov_apa,
    service => $svc_apa_bd,
    message_id => $apa_id,
    title => $title,
    subtitle => $subtitle,
    slugline => $slugline,
    embargo => DateTime::Format::XSD->parse_datetime($embargo),
    embargo_text => $embargo_text,
    note => 'Bilder zum Schweizerhaus sind im AOM, z.B. ABD0019 vom 23. März 2006, abrufbar',
    closing => 'Schluss',
    content_created => DateTime::Format::XSD->parse_datetime($time1),
    content_modified => DateTime::Format::XSD->parse_datetime($time2),
   ), 'create News Item instance');

$ni->add_genre($genre1, $genre2);

$ni->add_source('APA');
$ni->add_source('DPA');

$ni->add_city('Wien');

$ni->add_author($_) foreach (qw(dw dk wh));

$ni->add_desk($desk_ci);

$ni->add_indicator('BILD');
$ni->add_indicator('VIDEO');

ok($ni->add_organisation($org), 'adding organisation');

ok(my $mt10000000 = XML::NewsML_G2::Media_Topic->new
   (name => 'Freizeit, Modernes Leben', qcode => 10000000),
   'create media topic 1');
ok($mt10000000->add_translation('en', 'lifestyle and leisure'), 'add translation');

my $mt20000538 = XML::NewsML_G2::Media_Topic->new
  (name => 'Freizeit', qcode => 20000538);
$mt20000538->add_translation('en', 'leisure');
ok($mt20000538->parent($mt10000000), 'set parent');

my $mt20000553 = XML::NewsML_G2::Media_Topic->new
  (name => 'Veranstaltungsort', qcode => 20000553, direct => 1);
$mt20000553->add_translation('en', 'leisure venue');
$mt20000553->parent($mt20000538);

ok($ni->add_media_topic($mt20000553), 'adding media topic');
ok(!$ni->add_media_topic($mt20000553), 'adding media topic again fails');

ok(exists $ni->media_topics->{20000553}, 'media topic in news item');
ok(exists $ni->media_topics->{20000538}, 'parent in news item');
ok(exists $ni->media_topics->{10000000}, 'grandparent in news item');


ok(my $wien = XML::NewsML_G2::Location->new
   (name => 'Wien', qcode => '1111', relevance => 100, direct => 1),
   'create Location Wien');

my $aut = XML::NewsML_G2::Location->new(name => 'Österreich', iso_code => 'AT', qcode => '2222', relevance => 40);

ok($wien->parent($aut), 'set parent');

my $europe = XML::NewsML_G2::Location->new(name => 'Europe', qcode => '3333', relevance => 30);
$aut->parent($europe);

ok($ni->add_location($wien), 'adding location');
ok(!$ni->add_location($wien), 'adding location again fails');
ok(exists $ni->locations->{1111}, 'Wien in locations');
ok(exists $ni->locations->{2222}, 'Österreich in locations');
ok(exists $ni->locations->{3333}, 'Europe in locations');

ok(my $t = XML::NewsML_G2::Topic->new(name => 'Budget 2012', qcode => 'bbbb'), 'create Topic');
ok($ni->add_topic($t), 'adding Topic');

ok(my $p = XML::NewsML_G2::Product->new(isbn => 3442162637), 'create Product');
ok($ni->add_product($p), 'adding product');

my %schemes;
foreach (qw(crel desk geo svc role ind org topic hltype)) {
    $schemes{$_} = XML::NewsML_G2::Scheme->new(alias => "apa$_", uri => "http://cv.apa.at/$_/");
}

ok(my $sm = XML::NewsML_G2::Scheme_Manager->new(%schemes), 'create Scheme Manager');

my $writer = XML::NewsML_G2::Writer_2_9->new(news_item => $ni, scheme_manager => $sm);

my $paragraphs = $writer->create_element('paragraphs');
for my $t ($text_1, $text_2) {
    $paragraphs->appendChild($writer->create_element('p', _ns => $writer->xhtml_ns, _text => $t));
}

ok($ni->paragraphs($paragraphs), 'set paragraphs');

ok(my $dom = $writer->create_dom(), 'create DOM');

ok(my $xpc = XML::LibXML::XPathContext->new($dom), 'create XPath context for DOM tree');
$xpc->registerNs('nar', 'http://iptc.org/std/nar/2006-10-01/');
$xpc->registerNs('xhtml', 'http://www.w3.org/1999/xhtml');

is($xpc->findvalue('nar:newsItem/@guid'), $guid, 'correct guid in XML');
like($xpc->findvalue('//nar:copyrightHolder/nar:name'), qr/APA/, 'correct copyright in XML');
is($xpc->findvalue('//nar:provider/@qcode'), 'nprov:apa', 'correct provider in XML');
is($xpc->findvalue('//nar:itemClass/@qcode'), 'ninat:text', 'correct item class in XML');
is($xpc->findvalue('//nar:embargoed'), $embargo, 'correct embargo in XML');
like($xpc->findvalue('//nar:edNote[contains(@role, "embargo")]'), qr/\Q$embargo_text\E/, 'correct embargo text in XML');
is($xpc->findvalue('//nar:contentCreated'), $time1, 'contentCreated correct');
is($xpc->findvalue('//nar:contentModified'), $time2, 'contentModified correct');

is($xpc->findvalue('//nar:pubStatus/@qcode'), 'stat:usable', 'correct pubStatus in XML');
like($xpc->findvalue('//nar:service/nar:name'), qr/Basisdienst/, 'correct service in XML');
ok($xpc->find('//nar:signal[@qcode="apaind:bild"]'), 'indicator for BILD found');
ok($xpc->find('//nar:signal[@qcode="apaind:video"]'), 'indicator for VIDEO found');
like($xpc->findvalue('//nar:edNote[contains(@role, "closing")]'), qr/Schluss/, 'correct closing in XML');
like($xpc->findvalue('//nar:edNote[contains(@role, "note")]'), qr/Bilder zum /, 'correct note in XML');
like($xpc->findvalue('//nar:located/nar:name'), qr/Wien/, 'correct city in XML');
like($xpc->findvalue('//nar:infoSource/@literal'), qr/DPA/, 'correct source in XML');
like($xpc->findvalue('//nar:creator/@literal'), qr/dw.*dk.*wh/, 'correct authors in XML');
is($xpc->findvalue('//nar:altId'), $apa_id, 'correct AltId in XML');
is($xpc->findvalue('//nar:genre[1]/@qcode'), 'genre:Current', 'correct genre 1 in XML');
is($xpc->findvalue('//nar:genre[2]/@qcode'), 'genre:Extra', 'correct genre 2 in XML');
like($xpc->findvalue('//nar:subject/@qcode'), qr/apadesk:CI/, 'desk in XML');
is($xpc->findvalue('//nar:slugline'), $slugline, 'correct slugline in XML');
is($xpc->findvalue('//nar:headline[@role="apahltype:title"]'), $title, 'correct title in XML');
is($xpc->findvalue('//nar:headline[@role="apahltype:subtitle"]'), $subtitle, 'correct subtitle in XML');
is($xpc->findvalue('//nar:contentSet/nar:inlineXML/@contenttype'), 'application/xhtml+xml', 'correct contenttype in XML');
is($xpc->findvalue('//xhtml:title'), $title, 'correct title in HTML head');

ok(my $xml_string = $dom->serialize(2), 'serializes into string');
unlike($xml_string, qr/(HASH|ARRAY|SCALAR)\(/, 'no perl references in XML');

my $xsd = catfile($base_dir, 'xsds/NewsML-G2_2.9-spec-All-Power.xsd');
ok(my $xmlschema = XML::LibXML::Schema->new(location => $xsd), 'parsing XSD');

lives_ok(sub {$xmlschema->validate($dom)}, 'generated XML validates against NewsML G2 schema');

# 2.11
ok($writer = XML::NewsML_G2::Writer_2_11->new(news_item => $ni, scheme_manager => $sm), 'creating 2.11 writer');
ok($dom = $writer->create_dom(), '2.11 writer creates DOM');
$xsd = catfile($base_dir, 'xsds/NewsML-G2_2.11-spec-All-Power.xsd');
ok($xmlschema = XML::LibXML::Schema->new(location => $xsd), 'parsing 2.11 XSD');
lives_ok(sub {$xmlschema->validate($dom)}, '2.11 XML validates');

done_testing;

open my $fh, '>', '/tmp/newsitem.xml';
print $fh $xml_string;
close $fh;
