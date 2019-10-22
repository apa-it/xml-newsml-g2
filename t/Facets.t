#!/usr/bin/env perl

use Test::MockTime 'set_fixed_time';

BEGIN {
    set_fixed_time('2012-01-01T13:00:00Z');
}

use utf8;
use Test::More;
use Test::Exception;
use DateTime::Format::XSD;
use XML::LibXML;

use lib 't';
use NewsML_G2_Test_Helpers qw(validate_g2 :vars);

use warnings;
use strict;

use XML::NewsML_G2;

my $ni = XML::NewsML_G2::News_Item_Text->new(
    guid            => $guid_text,
    provider        => $prov_apa,
    message_id      => $apa_id,
    language        => 'de',
    title           => 'Facet test',
    content_created => DateTime->now()
);

my $mt = XML::NewsML_G2::Media_Topic->new(
    name  => 'alpine skiing',
    qcode => 20001057
);

my $facet = XML::NewsML_G2::Facet->new(
    name  => 'alpine skiing slalom',
    qcode => 'denhangrunter'
);

my $concept = XML::NewsML_G2::Concept->new( main => $mt );
$concept->add_facet($facet);
$ni->add_concept($concept);

my %schemes = (
    'facet' => XML::NewsML_G2::Scheme->new(
        alias => 'myfacet',
        uri   => 'http://facets.salzamt.at/myfacet/'
    )
);
my $sm = XML::NewsML_G2::Scheme_Manager->new(%schemes);

my $writer = XML::NewsML_G2::Writer::News_Item->new(
    news_item      => $ni,
    scheme_manager => $sm,
    g2_version     => 2.28
);

ok( my $dom = $writer->create_dom(), 'V 2.28 DOM created' );
validate_g2( $dom, '2.28', 'NewsItem_withFacets_2.28' );

foreach (qw/2.9 2.12 2.15 2.18/) {
    my $writer = XML::NewsML_G2::Writer::News_Item->new(
        news_item      => $ni,
        scheme_manager => $sm,
        g2_version     => $_
    );
    throws_ok( sub { $writer->create_dom() },
        qr/Unimplemented/, "No concept suppport for version $_" );
}

### XXX Test Sport Facets from Catalog

done_testing;
