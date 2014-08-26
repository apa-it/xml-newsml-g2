#!/usr/bin/env perl

# $Id$

use utf8;
use Test::More;
use DateTime::Format::XSD;
use XML::LibXML;

use lib 't';
use NewsML_G2_Test_Helpers qw(create_ni_picture validate_g2 :vars);

use warnings;
use strict;

use XML::NewsML_G2;


sub remotes_checks {
    my ($dom, $xpc) = @_;

    like($xpc->findvalue('//nar:contentSet/nar:remoteContent/@rendition'), qr|rnd:highRes|, 'correct rendition in XML');
    like($xpc->findvalue('//nar:contentSet/nar:remoteContent/@rendition'), qr|rnd:thumb|, 'correct rendition in XML');
    like($xpc->findvalue('//nar:contentSet/nar:remoteContent/@href'), qr|file://tmp/files/123.*jpg|, 'correct href in XML');
    like($xpc->findvalue('//nar:contentSet/nar:remoteContent/@contenttype'), qr|image/jpg|, 'correct mimetype in XML');
    like($xpc->findvalue('//nar:contentSet/nar:remoteContent/@layoutorientation'), qr/loutorient:unaligned/, 'correct layout in XML');

    return;
}

my %schemes;
foreach (qw(crel desk geo svc role ind org topic hltype)) {
    $schemes{$_} = XML::NewsML_G2::Scheme->new(alias => "apa$_", uri => "http://cv.apa.at/$_/");
}

ok(my $sm = XML::NewsML_G2::Scheme_Manager->new(%schemes), 'create Scheme Manager');
my $ni = create_ni_picture();
my $pic = XML::NewsML_G2::Picture->new(mimetype => 'image/jpg', width => 1600, height => 1024, layout => 'vertical', rendition => 'highRes');
my $thumb = XML::NewsML_G2::Picture->new(mimetype => 'image/jpg', width => 48, height => 32, rendition => 'thumb');
$ni->add_remote('file://tmp/files/123.jpg', $pic);
$ni->add_remote('file://tmp/files/123.thumb.jpg', $thumb);
my $writer = XML::NewsML_G2::Writer_2_9->new(news_item => $ni, scheme_manager => $sm);

# 2.9 checks
ok(my $dom = $writer->create_dom(), 'create DOM');
ok(my $xpc = XML::LibXML::XPathContext->new($dom), 'create XPath context for DOM tree');
$xpc->registerNs('nar', 'http://iptc.org/std/nar/2006-10-01/');
$xpc->registerNs('xhtml', 'http://www.w3.org/1999/xhtml');
remotes_checks($dom, $xpc);
validate_g2($dom, '2.9');

# 2.12 checks
ok($writer = XML::NewsML_G2::Writer_2_12->new(news_item => $ni, scheme_manager => $sm), 'creating 2.12 writer');
ok($dom = $writer->create_dom(), '2.12 writer creates DOM');
ok($xpc = XML::LibXML::XPathContext->new($dom), 'create XPath context for DOM tree');
$xpc->registerNs('nar', 'http://iptc.org/std/nar/2006-10-01/');
$xpc->registerNs('xhtml', 'http://www.w3.org/1999/xhtml');
remotes_checks($dom, $xpc);
validate_g2($dom, '2.12');

#diag($dom->serialize(1));

done_testing;
