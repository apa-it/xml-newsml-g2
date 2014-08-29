#!/usr/bin/env perl

# $Id$

use utf8;
use Test::More;

use lib 't';
use NewsML_G2_Test_Helpers qw($prov_apa create_ni_text create_ni_picture validate_g2);

use warnings;
use strict;

use XML::NewsML_G2;

my %args = (language => 'de', provider => $prov_apa);

ok(my $pi = XML::NewsML_G2::Package_Item->new(%args), 'create Package_Item');
isa_ok($pi->root_group, 'XML::NewsML_G2::Group', 'package\'s root group');
is_deeply($pi->root_group->items, [], 'root group is empty');

# for multimedia package: create news item + image, add them to root group
my $text = create_ni_text();
my $pic = create_ni_picture();
$pi->add_to_root_group($text, $pic);

cmp_ok(@{$pi->root_group->items}, '==', 2, 'root group has two items now');

my %schemes = ();
foreach (qw(group)) {
    $schemes{$_} = XML::NewsML_G2::Scheme->new(alias => "apa$_", uri => "http://cv.apa.at/$_/");
}
ok(my $sm = XML::NewsML_G2::Scheme_Manager->new(%schemes), 'create Scheme Manager');

ok(my $writer = XML::NewsML_G2::Writer::Package_Item->new(package_item => $pi, scheme_manager => $sm), 'create package writer');

ok(my $dom = $writer->create_dom(), 'package writer creates DOM');
validate_g2($dom, '2.12');
diag($dom->serialize(1));

# for slideshows: create several news items + images, each pair in its own group

ok($pi = XML::NewsML_G2::Package_Item->new(root_role => 'slideshow', %args), 'create Package_Item');
for my $id (1 .. 4) {
    $text = create_ni_text(id => $id);
    $pic = create_ni_picture(id => $id);
    my $g = XML::NewsML_G2::Group->new(role => 'slide');
    $g->add($text, $pic);
    $pi->add_to_root_group($g);
}

# and add a final inner group, just for the kicks
my $last_group = $pi->root_group->items->[-1];
$last_group->add(my $inner_group = XML::NewsML_G2::Group->new(role => 'slide-in-a-slide'));
$text = create_ni_text(id => 42);
$pic = create_ni_picture(id => 42);
$inner_group->add($text, $pic);

ok($writer = XML::NewsML_G2::Writer::Package_Item->new(package_item => $pi, scheme_manager => $sm), 'create package writer');

ok($dom = $writer->create_dom(), 'package writer creates DOM');
validate_g2($dom, '2.12');
diag($dom->serialize(1));


done_testing;
