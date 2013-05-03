# $Id$

use strict;
use warnings;
use Module::Build 0.4004;

my $builder = Module::Build->new
  (module_name         => 'Text::NewsML_G2',
   license             => 'gpl',
   dist_author         => 'Philipp Gortan <philipp.gortan@apa.at>',
   dist_abstract       => 'generate NewsML G2 news items',
   dist_version_from   => 'lib/Text/NewsML_G2.pm',
   requires =>
   { 'version' => 0.77,
   },
   configure_requires =>
   { 'Module::Build' => 0.40,
   },
   test_requires =>
   { 'Test::More'         => 0,
     'Test::Perl::Critic' => 0,
   },
   add_to_cleanup =>
   [ 'Text-NewsML_G2-*',
   ],
  );

$builder->create_build_script();
