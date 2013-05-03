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
   { 'perl'                  => '5.8.0',
     'version'               => 0.77,
     'Moose'                 => 0.64,
     'namespace::autoclean'  => 0.05,
     'XML::LibXML'           => 0,
     'DateTime'              => 0,
     'DateTime::Format::XSD' => 0,
   },
   test_requires =>
   { 'Test::More'         => 0,
     'Test::Exception'    => 0,
     'Test::Perl::Critic' => 0,
   },
   add_to_cleanup =>
   [ 'Text-NewsML_G2-*',
   ],
  );

$builder->create_build_script();
