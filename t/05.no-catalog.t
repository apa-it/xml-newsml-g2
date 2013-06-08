#! /usr/bin/perl

# $Id$

use utf8;
use Test::More;
use DateTime::Format::XSD;
use XML::LibXML;

use lib 't';
use NewsML_G2_Test_Helpers qw(validate_g2);

use warnings;
use strict;

diag("libxml version " . XML::LibXML::LIBXML_RUNTIME_VERSION);

use XML::NewsML_G2;

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

ok(my $desk_ci = XML::NewsML_G2::Desk->new
   (qcode => 'CI', name => 'Chronik Inland'
   ), 'create Desk instance');

ok(my $ni = XML::NewsML_G2::News_Item->new
   (guid => $guid,
    see_also => $see_also_guid,
    provider => $prov_apa,
    message_id => $apa_id,
    title => $title,
    subtitle => $subtitle,
    slugline => $slugline,
    embargo => DateTime::Format::XSD->parse_datetime($embargo),
    embargo_text => $embargo_text,
    language => 'de',
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

ok(my $writer = XML::NewsML_G2::Writer_2_12->new(news_item => $ni), 'creating 2.12 writer');
ok(my $dom = $writer->create_dom(), '2.12 writer creates DOM');

diag($dom->serialize(2));

validate_g2($dom, '2.12');

done_testing;
