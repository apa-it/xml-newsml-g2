#!/usr/bin/env perl

use Test::MockTime 'set_fixed_time';

BEGIN {
    set_fixed_time('1325422800');
}

use utf8;
use Test::More;

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
    title           => 'Event Ref Test',
    content_created => DateTime->now()
);

my $ev_ref = XML::NewsML_G2::Event_Ref->new(
    event_id => '0815',
    name     => 'Bierverkostung November 2019'
);
$ni->add_event_reference($ev_ref);
my %schemes = (
    'eventid' => XML::NewsML_G2::Scheme->new(
        alias => 'myeventid',
        uri   => 'http://events.salzamt.at/list-of-events/'
    ),
);
my $sm = XML::NewsML_G2::Scheme_Manager->new(%schemes);

foreach (qw/2.9 2.12 2.15 2.18 2.28/) {
    my $writer = XML::NewsML_G2::Writer::News_Item->new(
        news_item      => $ni,
        scheme_manager => $sm,
        g2_version     => $_
    );
    ok( my $dom = $writer->create_dom(), "V $_ DOM created" );
    validate_g2( $dom, $_, "NewsItem_withEventRefs_$_" );
}

done_testing;
