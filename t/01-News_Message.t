#!/usr/bin/env perl

# $Id$

use utf8;
use Test::More;
use DateTime::Format::XSD;
use XML::LibXML;

use lib 't';
use NewsML_G2_Test_Helpers qw(create_ni_text create_ni_video validate_g2 :vars);

use warnings;
use strict;

use XML::NewsML_G2;


sub remotes_checks {
   #XXX 
}

my %schemes;
foreach (qw(crel desk geo svc role ind org topic hltype adc)) {
    $schemes{$_} = XML::NewsML_G2::Scheme->new(alias => "apa$_", uri => "http://cv.apa.at/$_/");
}

ok(my $sm = XML::NewsML_G2::Scheme_Manager->new(%schemes), 'create Scheme Manager');

my $ni_video = create_ni_video();
my $hd = XML::NewsML_G2::Video->new(width => 1920, height => 1080, size => '23013531', duration => 30, audiochannels => 'stereo');
$ni_video->add_remote('file://tmp/files/123.hd.mp4', $hd);
my $ni_text = create_ni_text();

my $nm = XML::NewsML_G2::News_Message->new();
$nm->add_anyItem($ni_video);
$nm->add_anyItem($ni_text);


my $writer = XML::NewsML_G2::Writer::News_Message->new(news_message => $nm, scheme_manager => $sm, g2_version => 2.18);
ok(my $dom = $writer->create_dom(), 'create DOM');
ok(my $xpc = XML::LibXML::XPathContext->new($dom), 'create XPath context for DOM tree');
$xpc->registerNs('nar', 'http://iptc.org/std/nar/2006-10-01/');
$xpc->registerNs('xhtml', 'http://www.w3.org/1999/xhtml');


#XXX Package Item Test

#remotes_checks($dom, $xpc);
validate_g2($dom, '2.18');

done_testing();


