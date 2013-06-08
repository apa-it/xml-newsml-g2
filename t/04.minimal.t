#! /usr/bin/perl

# $Id$

use utf8;
use Test::More;
use Test::Exception;
use File::Basename;
use File::Spec::Functions qw(catfile);
use XML::LibXML;
use XML::NewsML_G2;

use warnings;
use strict;

diag("libxml version " . XML::LibXML::LIBXML_RUNTIME_VERSION);

my $base_dir = dirname $0 || '.';

ok(my $prov_apa = XML::NewsML_G2::Provider->new
  (qcode => 'apa', name => 'APA - Austria Presse Agentur'
  ), 'create Provider instance');

ok(my $ni = XML::NewsML_G2::News_Item->new
   (title => 'Saisonstart im Schweizerhaus: Run aufs Krügerl im Prater',
    slugline => 'Buntes/Freizeit/Bauten/Eröffnung/Unterhaltung/Wien/Kommunales',
    language => 'de',
    provider => $prov_apa,
   ), 'create News Item instance');

ok($ni->add_paragraph('Die Saison im Wiener Prater hat am Donnerstagvormittag mit der Eröffnung des Schweizerhauses begonnen - diese findet traditionell jedes Jahr am 15. März statt.'), 'add_paragraph works');

my $writer = XML::NewsML_G2::Writer_2_12->new(news_item => $ni);
ok(my $dom = $writer->create_dom(), 'create DOM');

diag($dom->serialize(2));

my $xsd = catfile($base_dir, 'xsds/NewsML-G2_2.12-spec-All-Power.xsd');
ok(my $xmlschema = XML::LibXML::Schema->new(location => $xsd), 'parsing 2.12 XSD');
lives_ok(sub {$xmlschema->validate($dom)}, '2.12 XML validates');

done_testing;
