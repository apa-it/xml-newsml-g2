package NewsML_G2_Test_Helpers;

# $Id$

use Exporter 'import';
use File::Spec::Functions qw(catfile);
use XML::LibXML;
use Test::More;
use Test::Exception;
use utf8;

use warnings;
use strict;

use XML::NewsML_G2;

our @EXPORT_OK = qw(validate_g2 create_ni_text create_ni_picture create_ni_video);

our %EXPORT_TAGS = (vars => [qw($guid_text $guid_picture
    $see_also_guid $embargo $apa_id $title $subtitle $slugline
    $creditline $embargo_text $note $prov_apa $svc_apa_bd $time1
    $time2 @text @genres $org $desk @keywords)]);

Exporter::export_ok_tags('vars');

our $guid_text = 'urn:newsml:apa.at:20120315:APA0379';
our $guid_picture = 'urn:newsml:apa.at:20120315:ABD0111';
our $see_also_guid = 'urn:newsml:apa.at:20120315:APA0123';
our $apa_id = 'APA0379';
our $title = 'Saisonstart im Schweizerhaus: Run aufs Krügerl im Prater';
our $subtitle = 'Großer Andrang am Eröffnungstag - Auch der Rummelplatz startsete heute den Betrieb';
our $slugline = 'Buntes/Freizeit/Bauten/Eröffnung/Unterhaltung/Wien/Kommunales';
our $creditline = 'APA/John Doe';
our $embargo = '2012-03-15T12:00:00+01:00';
our $embargo_text = 'frei für Dienstagsausgaben';
our $note = 'Bilder zum Schweizerhaus sind im AOM, z.B. ABD0019 vom 23. März 2006, abrufbar';
our $time1 = '2012-03-15T09:09:00+01:00';
our $time2 = '2012-03-15T10:10:00+01:00';

ok(our $mt10000000 = XML::NewsML_G2::Media_Topic->new
   (name => 'Freizeit, Modernes Leben', qcode => 10000000),
   'create media topic 1');
ok($mt10000000->add_translation('en', 'lifestyle and leisure'), 'add translation');

our $mt20000538 = XML::NewsML_G2::Media_Topic->new
  (name => 'Freizeit', qcode => 20000538);
ok($mt20000538->add_translation('en', 'leisure'), 'set translation');
ok($mt20000538->parent($mt10000000), 'set parent');

our $mt20000553 = XML::NewsML_G2::Media_Topic->new
  (name => 'Veranstaltungsort', qcode => 20000553, direct => 1);
$mt20000553->add_translation('en', 'leisure venue');
$mt20000553->parent($mt20000538);

ok(our $prov_apa = XML::NewsML_G2::Provider->new
   (qcode => 'apa', name => 'APA - Austria Presse Agentur',
    notice => '(c) 2014 http://www.apa.at'
   ), 'create Provider instance');

ok(our $svc_apa_bd = XML::NewsML_G2::Service->new
   (qcode => 'bd', name => 'Basisdienst'
   ), 'create Service instance');

ok(our @genres =
   (XML::NewsML_G2::Genre->new
    (name => 'Berichterstattung',
     qcode => 'Current'
    ),
    XML::NewsML_G2::Genre->new
    (name => 'Extra',
     qcode => 'Extra'
    )), 'create Genre instances');

ok(our $org = XML::NewsML_G2::Organisation->new
   (name => 'Ottakringer Brauerei',
    qcode => '161616',
    isins => ['AT0000758032'],
    websites => ['http://www.ottakringer.at'],
    markets => ['Wien', 'Prag']
   ), 'create Organisation instance');

ok(our $desk = XML::NewsML_G2::Desk->new
   (qcode => 'CI', name => 'Chronik Inland'
   ), 'create Desk instance');

ok(my $wien = XML::NewsML_G2::Location->new
   (name => 'Wien', qcode => '1111', relevance => 100, direct => 1),
   'create Location Wien');

my $aut = XML::NewsML_G2::Location->new(name => 'Österreich', iso_code => 'AT', qcode => '2222', relevance => 40);

ok($wien->parent($aut), 'set parent');

my $europe = XML::NewsML_G2::Location->new(name => 'Europe', qcode => '3333', relevance => 30);
$aut->parent($europe);

ok(my $topic = XML::NewsML_G2::Topic->new(name => 'Budget 2012', qcode => 'bbbb'), 'create Topic');
ok(my $product = XML::NewsML_G2::Product->new(isbn => 3442162637), 'create Product');

our @keywords = qw(beer vienna prater kolarik schweizerhaus);

{
    local $/ = undef;
    our @text = split /\n\n+/, <DATA>;
}


sub validate_g2 {
    my ($dom, $version) = @_;

  SKIP: {
        skip 'libxml2 before 2.8 reports bogus violation on children of "broader"', 2 if (20800 > XML::LibXML::LIBXML_RUNTIME_VERSION);
        $version =~ tr/./_/;
        my $xsd = catfile('t', 'xsds', "NewsML-G2_$version-spec-All-Power.xsd");
        ok(my $xmlschema = XML::LibXML::Schema->new(location => $xsd), "parsing $version XSD");

        lives_ok(sub {$xmlschema->validate($dom)}, "XML validates against $version XSD");
    }

    return;
}

sub _create_ni {
    my $ni_cls = shift;
    my $hash  = shift;
    my %opts = @_;

    $hash->{service} = $svc_apa_bd unless ($opts{no_required_scheme});

    ok(my $ni = $ni_cls->new
       (guid             => $guid_text, # overwrite in $hash
        see_also         => $see_also_guid,
        provider         => $prov_apa,
        usage_terms      => 'view only with a full beer',
        message_id       => $apa_id,
        title            => $title,
        subtitle         => $subtitle,
        slugline         => $slugline,
        embargo          => DateTime::Format::XSD->parse_datetime($embargo),
        embargo_text     => $embargo_text,
        language         => 'de',
        note             => $note,
        closing          => 'Schluss',
        credit           => $creditline,
        content_created  => DateTime::Format::XSD->parse_datetime($time1),
        content_modified => DateTime::Format::XSD->parse_datetime($time2),
        %$hash
       ), 'create News Item instance');

    ok($ni->add_genre(@genres), 'add_genre works');
    ok($ni->add_organisation($org), 'add_organisation works');
    ok($ni->add_source('APA', 'DPA'), 'add_source works');
    ok($ni->add_city('Wien'), 'add_city works');
    ok($ni->add_desk($desk), 'add_desk works');

    $ni->add_author($_) foreach (qw(dw dk wh));
    ok($ni->authors, 'add_author works');

    $ni->add_keyword($_) foreach (@keywords);

    ok($ni->add_media_topic($mt20000553), 'adding media topic');
    ok(!$ni->add_media_topic($mt20000553), 'adding media topic again fails');

    ok(exists $ni->media_topics->{20000553}, 'media topic in news item');
    ok(exists $ni->media_topics->{20000538}, 'parent in news item');
    ok(exists $ni->media_topics->{10000000}, 'grandparent in news item');

    ok($ni->add_location($wien), 'adding location');
    ok(!$ni->add_location($wien), 'adding location again fails');
    ok(exists $ni->locations->{1111}, 'Wien in locations');
    ok(exists $ni->locations->{2222}, 'Österreich in locations');
    ok(exists $ni->locations->{3333}, 'Europe in locations');

    ok($ni->add_topic($topic), 'adding Topic');
    ok($ni->add_product($product), 'adding product');

    unless ($opts{no_required_scheme}) {
        $ni->add_indicator('BILD');
        $ni->add_indicator('VIDEO');
    }

    return $ni;
}

sub create_ni_text {
    _create_ni('XML::NewsML_G2::News_Item_Text', {}, @_);
}

sub create_ni_picture {
    _create_ni(
        'XML::NewsML_G2::News_Item_Picture',
        {photographer => 'Homer Simpson', guid => $guid_picture}, @_
        );
}

sub create_ni_video {
    _create_ni('XML::NewsML_G2::News_Item_Video', @_);
}

1;

__DATA__
Die Saison im Wiener Prater hat am Donnerstagvormittag mit der
Eröffnung des Schweizerhauses begonnen - diese findet traditionell
jedes Jahr am 15. März statt. Pünktlich um 10.00 Uhr öffnete das
Bierlokal seine Pforten. Für viele Wiener ist das ein Pflichttermin:
"Es ist ein Fest für unsere Stammgäste. Die machen sich schon zum
Saisonschluss im Oktober aus, dass sie am ersten Öffnungstag im neuen
Jahr wieder kommen", sagte der Betreiber des Schweizerhauses, Karl
Kolarik, der APA.

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
