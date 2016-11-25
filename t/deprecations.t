#! /usr/bin/env perl

use strict;
use warnings;
use Test::More;
use Test::Warnings 'warning';

use XML::NewsML_G2::News_Item_Text;

use lib 't';
use NewsML_G2_Test_Helpers;

my $ni =
    XML::NewsML_G2::News_Item_Text->new( %NewsML_G2_Test_Helpers::ni_std_opts,
    title => 'blah' );

like(
    warning { $ni->see_also("something") },
    qr/see_also is deprecated/,
    'using see_also as setter emits warning'
);

my $sa;
like(
    warning { $sa = $ni->see_also->residref },
    qr/see_also is deprecated/,
    'using see_also as getter emits warning'
);

is( $sa, "something", 'see_also still works' );

done_testing;
