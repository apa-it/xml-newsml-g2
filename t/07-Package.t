#!/usr/bin/env perl

# $Id$

use utf8;
use Test::More;

use lib 't';
use NewsML_G2_Test_Helpers qw($prov_apa create_ni_text create_ni_picture);

use warnings;
use strict;

use XML::NewsML_G2;

my %args = (language => 'de', provider => $prov_apa);

ok(my $pi = XML::NewsML_G2::Package->new(%args), 'create Package');
isa_ok($pi->root_group, 'XML::NewsML_G2::Group', 'package\'s root group');
is_deeply($pi->root_group->items, [], 'root group is empty');

# for multimedia package: create news item + image, add them to root group
my $text = create_ni_text();
my $pic = create_ni_picture();
$pi->add_to_root_group($text, $pic);

cmp_ok(@{$pi->root_group->items}, '==', 2, 'root group has two items now');

my %schemes;
ok(my $sm = XML::NewsML_G2::Scheme_Manager->new(%schemes), 'create Scheme Manager');

ok(my $writer = XML::NewsML_G2::Writer::Package->new(package_item => $pi, scheme_manager => $sm), 'create package writer');

ok(my $dom = $writer->create_dom(), 'package writer creates DOM');

diag($dom->serialize(1));

done_testing;
